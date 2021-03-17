
close all
clear
clc

SMbone = 'mt1';% change this to have only this bone come up when askig to create a bonestruct

%Add to, or buld a new one
ans = questdlg('Would you like to build a new bonestruct or add new bones to an already created bonestruct?','New?','New','Add','New');

if strcmp(ans, 'Add')
    [bone_struct_file,bs_path] = uigetfile();
    if isempty(bone_struct_file)
        return
    else
        load(fullfile(bs_path,bone_struct_file)) % loads the bonestruct
        for bn = 1:length(bonestruct.(SMbone))
        bone_file_list{bn} = bonestruct.(SMbone)(bn).metadata.filename;
        end
    end
    
    
    % Information message
    uiwait(msgbox('Please select the additional bones for which you would like to generate co-ordinate systems.','Information','modal'))
    
elseif strcmp(ans,'New')
     bone_file_list = {};
    % Information message
    uiwait(msgbox('Please select the bones for which you would like to generate co-ordinate systems.','Information','modal'))
end


% select the bones to animate
[bone_list,ivDir] = uigetfile([ '\Models\*' SMbone '*.iv'],'Select the BONES','Multiselect','on');



%% Load the template, make the inertial co-ordinate systems

% load the template foot

file = 'TEMPLATEbonestruct.mat';
path = 'C:\Users\welte\Documents\Code\BiomechanicsTools\AnatomicalCoordinateSystems\FootCoordinateSystem\References\';
% [file,path] = uiputfile('*.mat','Select a file',[ivDir, 'TEMPLATEbonestruct.mat']);
temp_bonestruct = load(fullfile(path,file)); % loads the bonestruct of the template file;

tpltBoneStruct = temp_bonestruct.bonestruct;
clearvars('temp_bonestruct');


% create a directory for the shape based IV files
shapeIvDir = [ivDir 'ShapeBasedCoordinateSystems\'];
if isfolder(shapeIvDir) == 0
    mkdir(shapeIvDir)
end


nbones = length(bone_list);

bonesCell = [];
fprintf('Registering all the bones to the reference bones.\n')
tic

ans_all = 'No answer'; % initialize
bones_to_process = [];


 %% Save everything in the structure, load in the files
 
 for b = 1:nbones % the b index is to loop through all the bones to add; b_ind will be used to put it in the structure
     if exist('bonestruct','var')
         b_ind = length(bonestruct.(SMbone))+1; % always add new values to the end
     else
         b_ind = 1; % unless it hasn't been made yet
     end
     
     file_spl = strsplit(bone_list{b},'_');
     boneout = 0; st = 0;
     while boneout == 0 || st > length(file_spl) % while the bone hasn't been found, or the # of split parts of the file is exceeded
         st = st + 1;
         boneout = bonecodeFT(file_spl{st});
         
     end
     
     bonesCell{b} = file_spl{st};
     bone_file{b} = [ivDir bone_list{b}];
     
     % determine if the subject's bone is already in the bonestructure
     ind_present = find(strcmp(bone_file_list,bone_list{b})); % if the bone is found
     if ~isempty(ind_present)
         
         if contains(ans_all,'No') % the first time through, it will ask the question about the duplicates because the initial value is "No answer", but once the question has been asked, it will be changed to "No", and will not ask again
             % it requires the double level because if the answer is "No"
             % you will need to ask the replace question every time
             ans_replace = questdlg(sprintf('The bone %s is already in the bonestruct. Would you like to skip or replace it?',bone_list{b}),'Replace?','Skip','Replace','Skip');
             
             if strcmp(ans_all,'No answer')
                 ans_all = questdlg(sprintf('Would you like to %s all duplicates?',lower(ans_replace)),'How would you like to treat duplicates?','Yes','No','No');
             end
         end
         
         switch ans_replace
             case 'Replace'
                 warning('Replacing %s in the bonestructure',bone_list{b})
                 b_ind = ind_present;
             case 'Skip'
                 continue
         end
     end
     
     bones_to_process(end+1) = b_ind;
     
     % load the points and connections
     [pts,cnt] = read_vrml_fast(bone_file{b});
     cnt = cnt + 1;
     
     npts = length(pts);
     npts_fit = 3000;
     if npts<npts_fit
         npts_fit = npts;
     end
     ind = round(linspace(1,npts,npts_fit));
     ptsT = tpltBoneStruct.(bonesCell{b}).pts;
     nptsT = length(ptsT);
     indT = round(linspace(1,nptsT,3000));
     
     
     [cent,~,~,~,cs,~,~,~,I_origin,~] = mass_properties(pts,cnt);
     
     T_inert_rot = eye(4);
     T_inert_rot(1:3,1:4) = [cs, cent'];
     metadata.orig_file = bone_file{b};
     metadata.filename = bone_list{b};
     metadata.date_created = date();
     %     bonestruct.(SMbone) = struct('pts',pts,'cnt',cnt,'centroid',cent,'inertiaACS',T_inert_rot,'inertia',I_origin,'T_Aligned',T_inert_align,'T_ACS',[]);
     bonestruct.(SMbone)(b_ind) = struct('metadata',metadata,'pts',pts,'cnt',cnt(:,1:3),'centroid',cent,'inertiaACS',T_inert_rot,'inertia',I_origin,'T_Aligned',[],'T_ACS',[]);
     
     
     T_inert{b_ind} = eye(4);
     T_inert{b_ind}(1:3,4) = cent';
     pts_inert = transformPoints(T_inert{b_ind},pts,-1);
     
     Tout{b_ind} = getUserOrientation(ptsT,pts_inert(ind,:));
    
     
     pts_orient_inert= transformPoints(Tout{b_ind},pts_inert);
     pts_orient{b_ind} = transformPoints(T_inert{b_ind},pts_orient_inert);
 end
 

%% for all the bones to process
nbones = length(bones_to_process);

for b_ind = bones_to_process
    cent = bonestruct.(SMbone)(b_ind).centroid;
%     pts = bonestruct.(SMbone)(b).pts;
%     
    npts = length(pts_orient{b_ind});
    npts_fit = 3000;
    if npts<npts_fit
        npts_fit = npts;
    end
    ind = round(linspace(1,npts,npts_fit));
    % align by CPD
    beta = 2; lambda = 3; maxIter = 150; tole = 1e-3;
    %
    opt.max_it = maxIter; opt.tol = tole; opt.corresp = 1; opt.beta = beta; opt.lambda = lambda; opt.method= 'rigid';
    opt.viz = 0;
    opt.scale = 0;opt.normalize = 0;
    cpd_struct= cpd_register(pts_orient{b_ind}(ind,:),ptsT(indT,:),opt);
    
    
    
    Tcpd = [[cpd_struct.R,cpd_struct.t];[0 0 0 1]];
    
    
    T_new =  Tcpd * tpltBoneStruct.(bonesCell{b_ind}).T_Aligned;
    pts_aligned = transformPoints(Tcpd,pts_orient{b_ind},-1);
    
%     
%     figure;hold on;
%     pcshow(pointCloud(pts_aligned))
%     pcshow(pointCloud(ptsT))
    
    T_true = T_inert{b_ind} * invTranspose(Tout{b_ind}) * invTranspose(T_inert{b_ind}) * T_new;
    
    % make point clouds for visualization
    tBonePC = pointCloud(tpltBoneStruct.(bonesCell{b_ind}).pts,'color',repmat([1 1 1],length(tpltBoneStruct.(bonesCell{b_ind}).pts),1));
    nBonePC = pointCloud(transformPoints(Tcpd, pts_orient{b_ind},-1));
    
    %     % visualise in template CT system
    %     figure; hold on;
    %     pcshow(tBonePC)
    %     plotPointsAndCoordSys1([],tpltBoneStruct.(bonesCell{b}).T_Aligned)
    %
    %     % visualise in rotated co sys
    %     figure; hold on;
    %     pcshow(pointCloud(pts_orient))
    %     plotPointsAndCoordSys1([], T_new)
    %
    %     % visualise in new bone's CT co sys.
    %     figure; hold on;
    %     pcshow(pointCloud(pts))
    %     plotPointsAndCoordSys1([], T_true)
    %    
    
    T_inert_rot = bonestruct.(SMbone)(b_ind).inertiaACS;
    T_inert_align = orientTwoCosys(T_true,T_inert_rot);
  
   
    bonestruct.(SMbone)(b_ind).T_Aligned = T_inert_align;
    
    
    %----------- shape based coordinate systems -----------------------
    
    switch bonesCell{b_ind}
        case 'tib'
%             pts_aligned_anat = transformPoints(T_Aligned,pts_aligned,-1);
            [T_TC,T_long] = calcTibAnatomicalCoSys(pts_aligned,T_inert_align);
            
            
                T_TC = T_inert{b_ind} * invTranspose(Tout{b_ind}) * invTranspose(T_inert{b_ind}) * T_TC;
                T_long = T_inert{b_ind} * invTranspose(Tout{b_ind}) * invTranspose(T_inert{b_ind}) * T_long;
               
                T_TC(1:3,4) = cent';
                T_long(1:3,4) = cent';
                
            bonestruct.tib(b_ind).T_ACS.T_TC = T_TC;
            bonestruct.tib(b_ind).T_ACS.T_long = T_long;
            
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_TC,100,1)];
            ivstring = [ivstring createInventorLink(bone_file{b_ind},eye(3,3),[0 0 0],[0.7 0.7 0.7],0.5)];
            
            filename = fullfile(shapeIvDir,[bone_list{b_ind}(1:end-3) '_TC.iv']);
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_long,100,1)];
            ivstring = [ivstring createInventorLink(bone_file{b_ind},eye(3,3),[0 0 0],[0.7 0.7 0.7],0.5)];
            filename = fullfile(shapeIvDir,[bone_list{b_ind}(1:end-3) '_long.iv']);
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
            
        case 'tal'
            [T_TC,T_ST] = calcTalusAnatomicalCoSys(pts_aligned);
            
            
                T_TC = T_inert{b_ind} * invTranspose(Tout{b_ind}) * invTranspose(T_inert{b_ind}) * T_TC;
                T_ST = T_inert{b_ind} * invTranspose(Tout{b_ind}) * invTranspose(T_inert{b_ind}) * T_ST;
               
                T_TC(1:3,4) = cent';
                T_ST(1:3,4) = cent';
                
            bonestruct.tal(b_ind).T_ACS.T_TC = T_TC;
            bonestruct.tal(b_ind).T_ACS.T_ST = T_ST;
            
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_TC,100,1)];
            
            ivstring = [ivstring createInventorLink(bone_file{b_ind},eye(3,3),[0 0 0],[0.7 0.7 0.7],0.5)];
            filename = fullfile(shapeIvDir,[bone_list{b_ind}(1:end-3)   '_TC.iv']);
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
            
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_ST,100,1)];
            ivstring = [ivstring createInventorLink(bone_file{b_ind},eye(3,3),[0 0 0],[0.7 0.7 0.7],0.5)];
            
            filename = fullfile(shapeIvDir,[bone_list{b_ind}(1:end-3)   '_ST.iv']);
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
        case 'cal'
            
    end
  
end
toc

% Verify in wrist viz

ivstring = createInventorHeader();

for b_ind = 1:nbones
    
    ivstring = [ivstring createInventorLink(bone_file{b_ind},eye(3,3),zeros(3,1),[0.7 0.7 0.7] ,0.5)];
    
    ivstring = [ivstring createInventorCoordinateSystem( bonestruct.(SMbone)(b_ind).T_Aligned,100,1)];
    ivstring = [ivstring createInventorGlobalAxes];
end

filename = fullfile(ivDir, ['inertialCoordinateSystems_' SMbone '.iv']);

fid = fopen(filename,'w'); % open the file to write
fprintf(fid,ivstring);
fclose(fid);

fprintf('Visualization is saved in %s.\n',filename)

fprintf('Shape based .iv files of co-ordinate systems are saved in %s.\n',shapeIvDir)
%% Save

save([ivDir, 'bonestruct' SMbone '.mat'],'bonestruct')

fprintf('Bone structure saved as : %s \n',[ivDir, 'bonestruct' SMbone '.mat'])
