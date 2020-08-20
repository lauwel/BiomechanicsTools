close all 
clear
clc
% Information message
uiwait(msgbox('Please select the subject''s directory.','Information','modal'))

% choose the subject directory
[subjectDir] = uigetdir([],'Select SUBJECT directory');


% Information message
uiwait(msgbox('Please select the bones for which you would like to generate co-ordinate systems.','Information','modal'))

% select the bones to animate
[bone_list,ivDir] = uigetfile([subjectDir '\Models\*.iv'],'Select the BONES','Multiselect','on');


%% make the template

nbones = length(bone_list);
bonesCell = [];

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
    
    
    [cent,~,~,CoM_ev123,CoM_eigenvectors,I1,I2,I_CoM,I_origin,patches] = mass_properties(pts,cnt);
    
    T_init = eye(4);
    T_init(1:3,1:3) = CoM_eigenvectors;
    T_init(1:3,4) = cent';
    
    
    % set up the template foot
    switch bonesCell{b}
        case 'tib'
            
            T_new = rotateCoordSys(T_init,90,2);
            T_new = rotateCoordSys(T_new,-90,3);
            
        case 'fib'
            T_new = rotateCoordSys(T_init,90,2);
            
        case 'tal'
            T_new = rotateCoordSys(T_init,-90,3);
            T_new = rotateCoordSys(T_new,180,1);
        case 'cal'
            
            T_new = rotateCoordSys(T_init,90,1);
            T_new = rotateCoordSys(T_new,90,3);
        case 'nav'
            
            T_new = rotateCoordSys(T_init,-90,1); 
        case 'cub'
      
            T_new = rotateCoordSys(T_init,90,3);
        case 'cmm'
            
            T_new = rotateCoordSys(T_init,-90,2);
        case 'cmi'
            
            T_new = rotateCoordSys(T_init,-90,2);
        case 'cml'
            
            T_new = rotateCoordSys(T_init,-90,1);
            T_new = rotateCoordSys(T_new,90,3);
        case 'mt1'
            T_new = rotateCoordSys(T_init,-90,1);
            T_new = rotateCoordSys(T_new,90,3);
            T_new = rotateCoordSys(T_new,180,2);
            
        case 'mt2'
            
            T_new = rotateCoordSys(T_init,-90,1);
            T_new = rotateCoordSys(T_new,90,3);
            T_new = rotateCoordSys(T_new,180,2);
        case 'mt3'
            
            T_new = rotateCoordSys(T_init,-90,1);
            T_new = rotateCoordSys(T_new,90,3);
            T_new = rotateCoordSys(T_new,180,2);
        case 'mt4'
            
            T_new = rotateCoordSys(T_init,-90,1);
            T_new = rotateCoordSys(T_new,90,3);
%             T_new = rotateCoordSys(T_new,90,2);
        case 'mt5'
            
            T_new = rotateCoordSys(T_init,-90,1);
            T_new = rotateCoordSys(T_new,90,3);
            T_new = rotateCoordSys(T_new,90,2);
            
        case 'ph1'
            T_new = rotateCoordSys(T_init,180,1);
            T_new = rotateCoordSys(T_new,90,3);
        case 'ph2'
            T_new = rotateCoordSys(T_init,180,1);
            T_new = rotateCoordSys(T_new,90,3);
        case 'ph3'
            T_new = rotateCoordSys(T_init,180,1);
            T_new = rotateCoordSys(T_new,90,3);
        case 'ph4'
            T_new = rotateCoordSys(T_init,180,1);
            T_new = rotateCoordSys(T_new,90,3);
        case 'ph5'
            T_new = rotateCoordSys(T_init,180,1);
            T_new = rotateCoordSys(T_new,90,3);
        otherwise
            fprintf('missing bone: % s\n',bonesCell{b})
            T_new = T_init;
       
    end
    
    bonestruct.(bonesCell{b}) = struct('metadata',[],'pts',pts,'cnt',cnt,'centroid',cent,'inertiaACS',T_init,'inertia',I_origin,'T_Aligned',T_new,'T_ACS',[]);
    
    bonestruct.(bonesCell{b}).metadata.orig_file = bone_file{b};
    bonestruct.(bonesCell{b}).metadata.date_created = date();
    
    clearvars('T_new')
end

% file = 'TEMPLATEbonestruct.mat';
% path = 'C:\Users\Lauren\Documents\git\BiomechanicsTools\CoordinateSystems\Foot\';
[file,path] = uiputfile('*.mat','Select a file',[ivDir, 'TEMPLATEbonestruct.mat']);
save(fullfile(path,file),'bonestruct')
% Verify in wrist viz

ivstring = createInventorHeader();

for b = 1:nbones
    
    ivstring = [ivstring createInventorLink(bone_file{b},eye(3,3),zeros(3,1),[0.7 0.7 0.7] ,0.5)];
    
    ivstring = [ivstring createInventorCoordinateSystem( bonestruct.(bonesCell{b}).T_Aligned,100,1)];
    ivstring = [ivstring createInventorGlobalAxes];
end

filename = fullfile(ivDir, 'coordinateSystems.iv');

fid = fopen(filename,'w'); % open the file to write
fprintf(fid,ivstring);
fclose(fid);

fprintf('Visualization is saved in %s.\n',filename)
fprintf('Template is saved in %s.\n',[path,file])




