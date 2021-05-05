function pt_intersect = vectorIntersectMesh(pts,cns,x0,vec)
% This function will look along the vector (vec) originating at the point
% x0, to see if it intersects the mesh defined by pts and cns.
% pts   = npts x 3 - mesh points
% cns   = ncns x 3 - point connections
% x0    = vector origin (1x3)
% vec   = vector direction (1x3)

[ct,ns] = calculateMeshCentroidsAndNormals(pts,cns);
ii = 1;
pt_intersect = nan(1,3);
c_save = [];
for c = 1:size(cns,1) % number of faces
    
    pt_plane =  closestPointonPlanealongVector(x0,ns(c,:),ct(c,:),vec); % closest point on the plane made by the face
    
    % see if the point is contained within the triangle
    [u,v,w] = pointsToBarycentric(pt_plane, pts(cns(c,:),:));
    
    if all(([u v w] < 1) & ([u v w] > 0) & (sum([u v w])- 1 < 0.001)) % means point is in the triangle
        pt_intersect(ii,:) = pt_plane;
        %         c_save(ii,:) = cns(c,:);
        
        ii = ii +1;
    end
end

figure;
patch('vertices',pts,'faces',cns,'facealpha',0.1); hold on;
axis equal

plotvector3(x0,vec*100,'k')
plotvector3(x0,-vec*100,'k')
plot3quick(pt_intersect,'r','o','none')
%
% figure;
% patch('vertices',pts,'faces',  c_save,'facealpha',0.1); hold on;
% axis equal
% plotvector3(x0,vec*100,'k')
% plotvector3(x0,-vec*100,'k')
% plot3quick(pt_intersect,'r','o','none')