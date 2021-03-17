function visualizeBone(bone_pts,bone_cns,T)

% bone points and connections are provided with a single Transform frame to
% plot

patch('Faces',bone_cns,'vertices',transformPoints(T,bone_pts),'facealpha',0.5)
axis equal;

