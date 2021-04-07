function visualizeBone(bone_pts,bone_cns,T,col)

if ~exist('col','var')
    col = [0.1 0 0.5];
end

% bone points and connections are provided with a single Transform frame to
% plot

patch('Faces',bone_cns,'vertices',transformPoints(T,bone_pts),'facecolor',col,'facealpha',0.3,'EdgeAlpha',0.3,'EdgeColor',col)
axis equal;

