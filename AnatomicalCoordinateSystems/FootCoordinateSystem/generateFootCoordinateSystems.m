
close all
clear
clc



% Information message
uiwait(msgbox('Please select the subject''s directory.','Information','modal'))

% choose the subject directory
[subjectDir] = uigetdir([],'Select SUBJECT directory');

ans = questdlg('Would you like to build a new bonestruct or add new bones to an already created bonestruct?','New?','New','Add','New');

if strcmp(ans, 'Add')
    [bone_struct_file,bs_path] = uigetfile(subjectDir);
    if isempty(bone_struct_file)
        return
    else
        load(fullfile(bs_path,bone_struct_file))
    end
    
end


% Information message
uiwait(msgbox('Please select the bones for which you would like to generate co-ordinate systems.','Information','modal'))

% select the bones to animate
[bone_temp,ivDir] = uigetfile([subjectDir '\Models\IV\*.iv'],'Select the BONES','Multiselect','on');
if ischar(bone_temp)
    bone_list{1} = bone_temp;
else
    bone_list = bone_temp;
end

% %%
% subjectDir = 'E:\XBSP00009\';
% ivDir = [subjectDir '\Models\IV\3Aligned Reduced\'];
% list_files = dir([ivDir '*.iv']);
%  
% bone_list = {list_files(:).name}';

%% make the inertial co-ordinate systems

% load the template foot

file = 'TEMPLATEbonestruct.mat';
% path = 'C:\Users\Lauren\Documents\git\BiomechanicsTools\CoordinateSystems\Foot\References\';
% [file,path] = uiputfile('*.mat','Select a file',[ivDir, 'TEMPLATEbonestruct.mat']);
b = load(fullfile(file)); % loads the bonestruct of the template file;

tpltBoneStruct = b.bonestruct;


% create a directory for the shape based IV files
shapeIvDir = [ivDir 'ShapeBasedCoordinateSystems\'];
if isfolder(shapeIvDir) == 0
    mkdir(shapeIvDir)
end

nbones = length(bone_list);

    
    
% bonesCell = [];
tic
for b = 1:nbones
    file_spl = strsplit(bone_list{b}(1:end-3),'_');
    boneout = 0; st = 0;
    while boneout == 0 && st < length(file_spl) % while the bone hasn't been found, or the # of split parts of the file is exceeded
        st = st + 1;
        boneout = bonecodeFT(file_spl{st});
        
    end
    if boneout == 0
        continue
    end
    bonesCell{b} = lower(file_spl{st});
    bone_file{b} = [ivDir bone_list{b}];
end


fprintf('Registering all the bones to the reference bones.\n')
for b = 1:nbones
    [pts,cnt] = read_vrml_fast(bone_file{b});
    cnt = cnt + 1;

    npts = length(pts);
    ind = round(linspace(1,npts,3000));
    ptsT = tpltBoneStruct.(bonesCell{b}).pts;
    nptsT = length(ptsT);
    indT = round(linspace(1,nptsT,3000));
    
    
    [cent,~,~,~,cs,~,~,~,I_origin,~] = mass_properties(pts,cnt);
    
    T_inert = eye(4);
    T_inert(1:3,4) = cent';
    pts_inert = transformPoints(T_inert,pts,-1);
    if b == 1
        [Tout] = getUserOrientation(ptsT,pts_inert(ind,:));
        
    end
    
    pts_orient_inert = transformPoints(Tout,pts_inert);
    pts_orient = transformPoints(T_inert,pts_orient_inert);
    
    % align by CPD
    beta = 2; lambda = 3; maxIter = 150; tole = 1e-3;
    %
    opt.max_it = maxIter; opt.tol = tole; opt.corresp = 1; opt.beta = beta; opt.lambda = lambda; opt.method= 'rigid';
    opt.viz = 0;
    opt.scale = 0;opt.normalize = 0;
    cpd_struct= cpd_register(pts_orient(ind,:),ptsT(indT,:),opt);
    Tcpd = [[cpd_struct.R,cpd_struct.t];[0 0 0 1]];
    
    
    T_new =  Tcpd * tpltBoneStruct.(bonesCell{b}).T_Aligned;
    pts_aligned = transformPoints(Tcpd,pts_orient,-1);
    
%     
%     figure;hold on;
%     pcshow(pointCloud(pts_aligned))
%     pcshow(pointCloud(ptsT))
    
    T_true = T_inert * invTranspose(Tout) * invTranspose(T_inert) * T_new;
    
    % make point clouds for visualization
    tBonePC = pointCloud(tpltBoneStruct.(bonesCell{b}).pts,'color',repmat([1 1 1],length(tpltBoneStruct.(bonesCell{b}).pts),1));
    nBonePC = pointCloud(transformPoints(Tcpd, pts_orient,-1));
    
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
    %     % update this to include the rotation and not just translation
        T_inert_rot = eye(4);
        T_inert_rot(1:3,1:4) = [cs, cent'];
    T_inert_align = orientTwoCosys(T_true,T_inert_rot);
  
    % Save everything in the structure
%     bonestruct.(bonesCell{b}) = struct('metadata',[],'pts',pts,'cnt',cnt,'centroid',cent,'inertiaACS',T_inert_rot,'inertia',I_origin,'T_Aligned',T_inert_align,'T_ACS',[]);
%     
    bonestruct.(bonesCell{b}).metadata.orig_file = bone_file{b};
    bonestruct.(bonesCell{b}).metadata.date_created = date();
    bonestruct.(bonesCell{b}).pts = pts;
    bonestruct.(bonesCell{b}).cnt = cnt;
    bonestruct.(bonesCell{b}).centroid = cent;
    bonestruct.(bonesCell{b}).inertiaACS = T_inert_rot;
    bonestruct.(bonesCell{b}).inertia = I_origin;
    bonestruct.(bonesCell{b}).T_Aligned = T_inert_align;
    bonestruct.(bonesCell{b}).T_ACS = [];
    
    %----------- shape based coordinate systems -----------------------
    
    switch bonesCell{b}
        case 'tib'
%             pts_aligned_anat = transformPoints(T_Aligned,pts_aligned,-1);
            [T_TC,T_long] = calcTibAnatomicalCoSys(pts_aligned,T_inert_align);
            
            
                T_TC = T_inert * invTranspose(Tout) * invTranspose(T_inert) * T_TC;
                T_long = T_inert * invTranspose(Tout) * invTranspose(T_inert) * T_long;
               
                T_TC(1:3,4) = cent';
                T_long(1:3,4) = cent';
                
            bonestruct.tib.T_ACS.T_TC = T_TC;
            bonestruct.tib.T_ACS.T_long = T_long;
            
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_TC,100,1)];
            
            filename = fullfile(shapeIvDir, 'tib_TC.iv');
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_long,100,1)];
            filename = fullfile(shapeIvDir, 'tib_long.iv');
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
            
        case 'tal'
            [T_TC,T_ST] = calcTalusAnatomicalCoSys(pts_aligned);
            
            
                T_TC = T_inert * invTranspose(Tout) * invTranspose(T_inert) * T_TC;
                T_ST = T_inert * invTranspose(Tout) * invTranspose(T_inert) * T_ST;
               
                T_TC(1:3,4) = cent';
                T_ST(1:3,4) = cent';
                
            bonestruct.tal.T_ACS.T_TC = T_TC;
            bonestruct.tal.T_ACS.T_ST = T_ST;
            
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_TC,100,1)];
            
            filename = fullfile(shapeIvDir, 'tal_TC.iv');
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
            
            
            ivstring = createInventorHeader();
            ivstring = [ivstring createInventorCoordinateSystem( T_ST,100,1)];
            
            filename = fullfile(shapeIvDir, 'tal_ST.iv');
            
            fid = fopen(filename,'w'); % open the file to write
            fprintf(fid,ivstring);
            fclose(fid);
        case 'cal'
            
    end
  
end
toc

% Verify in wrist viz

ivstring = createInventorHeader();
bonesCell = fields(bonestruct);
nbones = length(bonesCell);
for b = 1:nbones
    
    ivstring = [ivstring createInventorLink(bonestruct.(bonesCell{b}).metadata.orig_file,eye(3,3),zeros(3,1),[0.7 0.7 0.7] ,0.5)];
    
    ivstring = [ivstring createInventorCoordinateSystem( bonestruct.(bonesCell{b}).T_Aligned,100,1)];
    ivstring = [ivstring createInventorGlobalAxes];
end

filename = fullfile(ivDir, 'inertialCoordinateSystems.iv');

fid = fopen(filename,'w'); % open the file to write
fprintf(fid,ivstring);
fclose(fid);

fprintf('Visualization is saved in %s.\n',filename)



fprintf('Shape based .iv files of co-ordinate systems are saved in %s.\n',shapeIvDir)


save([ivDir, 'bonestruct.mat'],'bonestruct')

fprintf('Bone structure saved as : %s \n',[ivDir, 'bonestruct.mat'])
