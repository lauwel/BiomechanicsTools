function [centrs,norms] = calculateMeshCentroidsAndNormals(pts,cns)

% Calculate the centroids and normal vectors of a triangular mesh with
% points (vertices) as pts and connections(faces) as cns. 
% pts should be Nx3 where N is the number of points
% cns should be Mx3 where M is the number of triangles, and each value is
% an indexed point in pts.

ptsA = pts(cns(:,1),:);
ptsB = pts(cns(:,2),:);
ptsC = pts(cns(:,3),:);
centrs = nan(size(cns,1),3);
for d = 1:3 % x y z dimension
    
   centrs(:,d) = mean([ptsA(:,d),ptsB(:,d),ptsC(:,d)],2);

end
   v1 = ptsB-ptsA;
   v2 = ptsC-ptsA;
   vecs = cross(v1,v2);
   norms = vecs./norm3d(vecs);
%    
% figure; visualizeBone(pts,cns,eye(4));
% hold on;
% plot3quick_scatter(centrs')
% h = plotvector3(centrs',500*norms');
% h.LineWidth = 4;