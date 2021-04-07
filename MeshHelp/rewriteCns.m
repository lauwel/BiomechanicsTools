function [new_pts,new_cns] = rewriteCns(orig_pts,orig_cns,ind_subset)
% orig_pts  =   the original pts
% orig_cns  =   the connections for the original points
% ind_subset=   the indices of the points to keep 

% outputs--- the outputted new pts and cns, re-indexed to new values
% new_pts   =   the subset of points selected from the original mesh
% new_cns   =   the relevant connections for that subset of points
% 
% % 
% orig_pts = [2,2,1;3,3,0;4,2,.5;3,1,0;1,1,0.2;5.2,1.1,0.2;5.2,2.1,0.2;8,1.2,1];
% orig_cns = [ 1 2 3; 1 3 4; 1 4 5; 3 4 6; 2 3 7; 3 6 7; 6 7 8];
% ind_subset = [1 2 4 5 6 7 8]';
% ind_subset = sort(ind_subset);
% figure; patch('faces',orig_cns,'vertices',orig_pts,'facealpha',0.2);
% first, remove the rows of connections with unreferenced points
new_cns = [];
npts_orig = size(orig_pts,1);
ind_subset = sort(ind_subset);
pts_RM = setdiff(1:npts_orig,ind_subset);%find the unref points

cnt = 1;
for c = 1:length(orig_cns)
    if any(ismember(orig_cns(c,:) ,pts_RM))
    else
        new_cns(cnt,:) = orig_cns(c,:);
        cnt = cnt+1;
        
    end
end


% figure; patch('faces',new_cns,'vertices',orig_pts,'facealpha',0.2);

new_pts = orig_pts(ind_subset,:);

npts_new = size(new_pts,1);
% then renumber all the points
for p = 1:npts_new
    
%     p is the index
    ind_rep = new_cns == ind_subset(p);
    new_cns(ind_rep) = p;
    
end

[new_pts,new_cns] = removeUnrefPts(new_pts,new_cns);
% figure; patch('faces',new_cns,'vertices',new_pts,'facealpha',0.2);
end