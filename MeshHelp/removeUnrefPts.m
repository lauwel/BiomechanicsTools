% Remove unreferenced points from mesh

function [p,c] = removeUnrefPts(pts,cns)

% cns = cns(:,1:3)+1;
cns = cns(:,1:3);

p = pts;
c = nan(size(cns));

ptlist = unique(cns);

I = setdiff(1:size(pts,1),ptlist)';

p(I,:) = [];

for i = 1:size(cns,1)
    for j = 1:3
        c(i,j) = find(ptlist==cns(i,j));
    end
end

end