
close all
clear
clc

SMbone = 'tal';
% % Information message
% uiwait(msgbox('Please select the subject''s directory.','Information','modal'))
% 
% % choose the subject directory
% [subjectDir] = uigetdir([],'Select SUBJECT directory');


% Information message
uiwait(msgbox('Please select the bones for which you would like to generate co-ordinate systems.','Information','modal'))

% select the bones to animate
[bone_list,ivDir] = uigetfile([ '\Models\*' SMbone '*.iv'],'Select the BONES','Multiselect','on');


%% make the inertial co-ordinate systems

% load the template foot

file = 'TEMPLATEbonestruct.mat';
path = 'C:\Users\Lauren\Documents\git\BiomechanicsTools\CoordinateSystems\Foot\References\';
% [file,path] = uiputfile('*.mat','Select a file',[ivDir, 'TEMPLATEbonestruct.mat']);
load(fullfile(path,file)) % loads the bonestruct of the template file;

tpltBoneStruct = bonestruct;
clearvars('bonestruct');

% create a directory for the shape based IV files
shapeIvDir = [ivDir 'ShapeBasedCoordinateSystems\'];
if isfolder(shapeIvDir) == 0
    mkdir(shapeIvDir)
end


nbones = length(bone_list);

bonesCell = [];
fprintf('Registering all the bones to the reference bones.\n')
tic

 % Save everything in the structure

for b = 1:nbones
    file_spl = strsplit(bone_list{b},'_');
    boneout = 0; st = 0;
    while boneout == 0 || st > length(file_spl) % while the bone hasn't been found, or the # of split parts of the file is exceeded
        st = st + 1;
        boneout = bonecodeFT(file_spl{st});
        
    end
    
    bonesCell{b} = file_spl{st};
    bone_file{b} = [ivDir bone_list{b}];
    
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
   metadata.date_created = date();
%     bonestruct.(SMbone) = struct('pts',pts,'cnt',cnt,'centroid',cent,'inertiaACS',T_inert_rot,'inertia',I_origin,'T_Aligned',T_inert_align,'T_ACS',[]);
    bonestruct.(SMbone)(b) = struct('metadata',metadata,'pts',pts,'cnt',cnt(:,1:3),'centroid',cent,'inertiaACS',T_inert_rot,'inertia',I_origin,'T_Aligned',[],'T_ACS',[]);

    
    T_inert{b} = eye(4);
    T_inert{b}(1:3,4) = cent';
    pts_inert = transformPoints(T_inert{b},pts,-1);
    
    if b ==1
        Tout{b} = getUserOrientation(ptsT,pts_inert(ind,:));
    else
        Tout{b} = Tout{1};
    end
    
    pts_orient_inert= transformPoints(Tout{b},pts_inert);
    pts_orient{b} = transformPoints(T_inert{b},pts_orient_inert);
end
%
for b = 1:nbones
    cent = bonestruct.(SMbone)(b).centroid;
%     pts = bonestruct.(SMbone)(b).pts;
%     
    npts = length(pts_orient{b});
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
    cpd_struct= cpd_register(pts_orient{b}(ind,:),ptsT(indT,:),opt);
    
    
    
    Tcpd = [[cpd_struct.R,cpd_struct.t];[0 0 0 1]];
    
    
    T_new =  Tcpd * tpltBoneStruct.(bonesCell{b}).T_Aligned;
    pts_aligned = transformPoints(Tcpd,pts_orient{b},-1);
    
%     
%     figure;hold on;
%     pcshow(pointCloud(pts_aligned))
%     pcshow(pointCloud(ptsT))
    
    T_true = T_inert{b} * invTranspose(Tout{b}) * invTranspose(T_inert{b}) * T_new;
    
    % make point clouds for visualization
    tBonePC = pointCloud(tpltBoneStruct.(bonesCell{b}).pts,'color',repmat([1 1 1],length(tpltBoneStruct.(bonesCell{b}).pts),1));
    nBonePC = pointCloud(transformPoints(Tcpd, pts_orient{b},-1));
    
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
    
    T_inert_rot = bonestruct.(SMbone)(b).inertiaACS;
    T_inert_align = orientTwoCosys(T_true,T_inert_rot);
  
   
    bonestruct.(SMbone)(b).T_Aligned = T_inert_align;
    
    
    %----------- shape based coordinate systems -----------------------
    
    switch bonesCell{b}
        case 'tib'
%             pts_aligned_anat = transformPoints(T_Aligned,pts_aligned,-1);
            [T_TC,T_long] = calcTibAnatomicalCoSys(pts_aligned,T_inert_align);
            
            
                T_TC = T_inert{b} * invTranspose(Tout{b}) * invTranspose(T_inert{b}) * T_TC;
                T_long = T_inert{b} * invTranspose(Tout{b}) * invTranspose(T_inert{b}) * T_long;
               
                T_TC(1:3,4) = cent';
                T_long(1:3,4) = cent';
                
            bonestruct.tib(b).T_ACS.T_TC = T_TC;
            bonestruct.tib(b).T_ACS.T_long = T_long;
            
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_TC,100,1)];
            ivstring = [ivstring createInventorLink(bone_file{b},eye(3,3),[0 0 0],[0.7 0.7 0.7],0.5)];
            
            filename = fullfile(shapeIvDir,[bone_list{b}(1:end-3) '_TC.iv']);
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_long,100,1)];
            ivstring = [ivstring createInventorLink(bone_file{b},eye(3,3),[0 0 0],[0.7 0.7 0.7],0.5)];
            filename = fullfile(shapeIvDir,[bone_list{b}(1:end-3) '_long.iv']);
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
            
        case 'tal'
            [T_TC,T_ST] = calcTalusAnatomicalCoSys(pts_aligned);
            
            
                T_TC = T_inert{b} * invTranspose(Tout{b}) * invTranspose(T_inert{b}) * T_TC;
                T_ST = T_inert{b} * invTranspose(Tout{b}) * invTranspose(T_inert{b}) * T_ST;
               
                T_TC(1:3,4) = cent';
                T_ST(1:3,4) = cent';
                
            bonestruct.tal(b).T_ACS.T_TC = T_TC;
            bonestruct.tal(b).T_ACS.T_ST = T_ST;
            
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_TC,100,1)];
            
            ivstring = [ivstring createInventorLink(bone_file{b},eye(3,3),[0 0 0],[0.7 0.7 0.7],0.5)];
            filename = fullfile(shapeIvDir,[bone_list{b}(1:end-3)   '_TC.iv']);
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
            
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_ST,100,1)];
            ivstring = [ivstring createInventorLink(bone_file{b},eye(3,3),[0 0 0],[0.7 0.7 0.7],0.5)];
            
            filename = fullfile(shapeIvDir,[bone_list{b}(1:end-3)   '_ST.iv']);
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
        case 'cal'
            
    end
  
end
toc

% Verify in wrist viz

ivstring = createInventorHeader();

for b = 1:nbones
    
    ivstring = [ivstring createInventorLink(bone_file{b},eye(3,3),zeros(3,1),[0.7 0.7 0.7] ,0.5)];
    
    ivstring = [ivstring createInventorCoordinateSystem( bonestruct.(SMbone)(b).T_Aligned,100,1)];
    ivstring = [ivstring createInventorGlobalAxes];
end

filename = fullfile(ivDir, 'inertialCoordinateSystems.iv');

fid = fopen(filename,'w'); % open the file to write
fprintf(fid,ivstring);
fclose(fid);

fprintf('Visualization is saved in %s.\n',filename)



fprintf('Shape based .iv files of co-ordinate systems are saved in %s.\n',shapeIvDir)


save([ivDir, 'bonestruct' SMbone '.mat'],'bonestruct')

fprintf('Bone structure saved as : %s \n',[ivDir, 'bonestruct' SMbone '.mat'])
