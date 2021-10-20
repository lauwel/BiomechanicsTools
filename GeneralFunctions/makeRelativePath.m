function rel_pA2PB = makeRelativePath(pathA,pathB)
% make the paths relative -> from path A get to path B
iA = repmat({''},100,1);% initialize
iB = repmat({''},100,1);
i1 = strsplit(pathA,filesep); % split based on file separators
i2 = strsplit(pathB,filesep);
iA(1:length(i1)) = i1;% fit them into the initialize matrices
iB(1:length(i2)) = i2;
common_paths = strcmp(iA,iB);% find the parts of the paths that match -> because it's initialized to be way longer than a path, there should always be 1's sandwiching 0's
if common_paths(1) == 0 % no common paths
    updateStatus(app,'Error: Relative path not possible.')
    return
end
numAlvls = find(~cellfun(@isempty,iA),1,'last'); % number of levels of files to go down
L1 = find(~common_paths,1,'first'); % first common level
str1 = repmat(['..' filesep],1,numAlvls - L1+2); % takes us up from anim

rel_pA2PB = strcat(str1, strjoin( iB(~common_paths),filesep),filesep); % add the files "up" (../) and then add the files forward

end