function [pts_clean,cns_clean] = removeDuplicatepts(pts,cns)
% remove any duplicated points and re-orient the connections
% L.Welte Dec 2018

% pts = all_pts_str;

[C,ia,~] = unique(pts,'stable','rows'); % determine all the unique points and conserved positions
npts = size(pts,1);
cns_clean = cns;
pts_clean = nan(length(ia),3);
cnt = 1;
for i = 1:npts % for each point
    if ismember(i,ia) % is a unique point
        
        pts_clean(cnt,:) = C(cnt,:);
        cn_ind = find(cns == i);
        cns_clean(cn_ind) = cnt;
        cnt = cnt+1;
    else % is a duplicate point
        cn_ind = find(cns == i);
        
        x_ind = (C(:,1) == pts(i,1));
        y_ind = (C(:,2) == pts(i,2));
        z_ind = (C(:,3) == pts(i,3));
        ind_clean = find( x_ind & y_ind & z_ind );
        cns_clean(cn_ind) = ind_clean;
    end
    
    
end
cns_clean = unique(cns_clean,'stable','rows');