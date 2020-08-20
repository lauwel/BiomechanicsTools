function grouped_ind = findGroupsOfLogicals(logic_array)
% this function finds groupings of 1s separated by 0's. It will also
% consider the first set of 1's to be a group, even if the first frame is
% not 0. It will also find groups at the end.
% Output: grouped_ind has groups in each row, with the first index in the
% first column and the end of the group in the second column. 

ind_1 = strfind(logic_array,[0 1]) + 1;
ind_end = strfind(logic_array,[1 0]);
nVals = length(logic_array);
if ind_end(1) < ind_1(1) % if the end is before the beginning
    ind_1 = [1 ind_1]; % include the first frame
end

if ind_end(end) < ind_1(end) % it must end with 1's
    ind_end = [ind_end nVals];
end

    grouped_ind = [ind_1',ind_end'];

    