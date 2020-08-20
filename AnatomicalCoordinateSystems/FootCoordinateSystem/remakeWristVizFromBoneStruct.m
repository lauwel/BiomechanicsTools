
% If any coordinate systems need to be manually fixed, remake animation:
ivDir = 'E:\XBSP00011\Models\IV\3Aligned Reduced\';
load([ivDir,'bonestruct.mat'])

bone = 'ph1';
T = rotateCoordSys(bonestruct.(bone).T_Aligned,180,1);


% bonestruct needs to be in the workplace 

bonestruct.(bone).T_Aligned =  T;

bonesCell = fields(bonestruct);
nbones = length(bonesCell);
ivstring = createInventorHeader();

for b = 1:nbones
    
    ivstring = [ivstring createInventorLink(bonestruct.(bonesCell{b}).metadata.orig_file,eye(3,3),zeros(3,1),[0.7 0.7 0.7] ,0.5)];
    
    ivstring = [ivstring createInventorCoordinateSystem( bonestruct.(bonesCell{b}).T_Aligned,100,1)];
    ivstring = [ivstring createInventorGlobalAxes];
end

filename = fullfile(ivDir, 'inertialCoordinateSystems.iv');

fid = fopen(filename,'w'); % open the file to write
fprintf(fid,ivstring);
fclose(fid);

save([ivDir, 'bonestruct.mat'],'bonestruct')