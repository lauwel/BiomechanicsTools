function [u,v,w] = pointsToBarycentric(P,pts)
% P is the test point
% pts should define the vertices of a triangle, individual points in rows,
% x y z in columns
% converts the triangle to barycentric coordinates: 
% https://www.scratchapixel.com/lessons/3d-basic-rendering/ray-tracing-rendering-a-triangle/barycentric-coordinates


A = pts(1,:);
B = pts(2,:);
C = pts(3,:);

% P = mean(pts,1); % origin
% figure; hold on;
% plot3quick([A;B;C]','r','o')
% plot3quick(P,'k','o')
tot_area = triangleArea3D(pts);

u = triangleArea3D([C;A;P])/tot_area;
v = triangleArea3D([A;B;P])/tot_area;
w = triangleArea3D([B;C;P])/tot_area;
