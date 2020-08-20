%% animate a trial

% Written by L. Welte

% Updated: August 20/2020
% Most recent update fixed some minor indexing issues.
% Modified so that you can use bone transforms OR autoscoper
% Renamed the function to show that the bones used are foot related.


clear
clc
% Select all the necessary directories and the bones to animate

uiwait(msgbox('Please look at the header of the following file explorer boxes to know which folder to select.','Information','modal'))

% choose the subject directory
[subjectDir] = uigetdir('E:\','Select SUBJECT directory');
if subjectDir == 0
    return
end
subjectDir = fullfile(subjectDir,filesep);


% choose the trial directory
[trialDir] = uigetdir(subjectDir,'Select TRIAL directory');
if trialDir == 0
    return
end
trialDir = fullfile(trialDir,filesep);

% choose transforms or autoscoper:
tran_flag = questdlg('Would you like to load autoscoper .tra files, or bone transform files (.mat)?','Choose file type','Autoscoper','BoneTransforms','None','Autoscoper');
if strcmp(tran_flag,'None')
    return
end


if strcmp(tran_flag,'BoneTransforms')
    [btfile,btDir] = uigetfile([trialDir '\BoneTransforms\'],'Select BONE TRANSFORM file');
    if btDir == 0
        return
    end
    btDir = fullfile(btDir,filesep);
    load([btDir,btfile]) % load bone transforms variable T
    
else % load autoscoper files
    traDir = fullfile(trialDir,'Autoscoper',filesep);
    traFiles = dir([traDir, '*.tra']);
end

% choose the animation directory

[animDir] = uigetdir(trialDir,'Select ANIMATION directory');
if animDir == 0
    return
end
animDir = fullfile(animDir,filesep);
%%
% select the bones to animate
[bone_list,ivDir] = uigetfile([subjectDir '\Models\*.iv'],'Select the BONES','Multiselect','on');
if ischar(bone_list)
    bl_temp = bone_list;
    clearvars('bone_list');
    bone_list{1} = bl_temp;
end
   
%% get the files to animate

tr_loc = strsplit(trialDir,filesep);
trialName = tr_loc{end-1};
nm_loc = strsplit(subjectDir,filesep);
bone_temp = nm_loc{end};
bone_temp = strsplit(bone_temp,'_');
subjectName = bone_temp{1};

nbones = length(bone_list);
bonesCell = [];

for b = 1:nbones
    file_spl = strsplit(bone_list{b},'_');
    boneout = 0; st = 0;
    while boneout == 0 && st < length(file_spl) % while the bone hasn't been found,and the # of split parts of the file is exceeded
        st = st + 1;
        boneout = bonecodeFT(file_spl{st});
        
    end
    
    bonesCell{b} = lower(file_spl{st});
    
    if contains(tran_flag,'Autoscoper')
        file_ind = findInStruct(traFiles,'name',bonesCell{b});
        
        if length(file_ind) > 1
            for f = 1:length(file_ind)
                if contains(traFiles(file_ind(f)).name,'interp')
                    file_ind = file_ind(f);
                    break
                end
            end
        end
        if isempty(file_ind)
            error('Bone (%s) selected does not have a .tra Autoscoper file.',bone_list{b})
        end
        traFilesCell{b} = traFiles(file_ind).name;
    end
end


%% animate the files




rigidivDir = fullfile(animDir,'rigidiv',filesep);

if exist(rigidivDir,'dir')==0;  mkdir(rigidivDir);  end


first_fr = 100000;
end_fr = 0;




for bn = 1:nbones
    
    % load the .tra files
    
    if contains(tran_flag,'BoneTransforms')
        Tanim.(bonesCell{bn}) = T.(bonesCell{bn});
        nanind = isnan(Tanim.(bonesCell{bn}));
        Tanim.(bonesCell{bn})(nanind) = 1;
        % to keep consistent with non bone transform option
        Tauto = convertRotation(Tanim.(bonesCell{bn}),'4x4xn','autoscoper');
        nanind = isnan(Tauto);
    else
        Tauto = dlmread(fullfile(traDir,traFilesCell{bn}));
        nanind = isnan(Tauto);
        Tauto(nanind) = 1;
        Tanim.(bonesCell{bn}) = convertRotation(Tauto,'autoscoper','4x4xn');
    end
    % find where there's data in the autoscoped .tra file

    frs = find(nanind(:,1)~=0 |  diff(Tauto([1:end,end],1)) ~= 0);   % the interp option sets all the transforms to be the same;
    % set the first and last frame to be as wide as the bone with the most
    % tracked data -> add an extra frame on either side (the end needs 2
    % because of the diff function)
    if frs(1) < first_fr
        if frs(1) ~= 1
            first_fr = frs(1)-1;
        else
            first_fr = 1;
        end
    end
    if frs(end) > end_fr
        if frs(end)+2 >= length(Tauto(:,1))
            end_fr = frs(end);
        else
            end_fr = frs(end)+2;
        end
    end
    
    
    % make the linked IV files
    ivstring = createInventorHeader();
    % make the linked iv file
    ivstring = [ivstring createInventorLink([ivDir bone_list{bn}],eye(3,3),zeros(3,1),[0.7 0.7 0.7],0.5)];
    
    fid = fopen(fullfile(rigidivDir,[bonesCell{bn} '.iv']),'w');
    fprintf(fid,ivstring);
    fclose(fid);
    
    
    
    
end


for bn = 1:nbones
    % write the RTp files
    write_RTp(bonesCell{bn} , Tanim.(bonesCell{bn})(:,:,first_fr:end_fr) , animDir)
end


iniDir = fullfile(animDir,'frameNumbers');
if ~exist(iniDir,'dir')
    mkdir(iniDir);
else
    delete(fullfile(iniDir,'*.iv'))
end
ind = 0;
frNum_style = 'frNum_F%i_O%i.iv';

for fr = first_fr:end_fr
    ind = ind+1;
    ini_filename = fullfile(iniDir,sprintf(frNum_style,ind,1));
    
    ivstring = createInventorHeader();
    %     (text,fontsize, position,color,transparency)
    ivstring = [ivstring createInventorText(num2str(fr-1),20,[0 0 0],[0,0.4,0.4],0.5) ];
    fid = fopen(ini_filename,'w');
    fprintf(fid,ivstring);
    fclose(fid);
end

create_ini(0,0,1,1,iniDir,strrep(frNum_style,'%i','%d'),[animDir trialName '.ini'])


pos_text = write_pos(bonesCell,animDir,trialName);

filename = fullfile(animDir, [trialName '.pos']);

fid = fopen(filename,'w'); % open the file to write
fprintf(fid,pos_text);
fclose(fid);

fprintf('Animation created successfully in %s \n', filename)

%% write the bone transform file
if ~strcmp(tran_flag,'BoneTransforms')
    boneT_dir = fullfile(trialDir,'BoneTransforms',filesep);
    if exist(boneT_dir,'dir') == 0
        mkdir(boneT_dir);
    end
    
    % save the transforms in a nice MAT file
    T = Tanim;
    boneTfile = fullfile(boneT_dir,[trialName '_transforms.mat']);
    save(boneTfile,'T')
    
    
    fprintf('Bone transform file created successfully in %s \n', boneTfile)
end