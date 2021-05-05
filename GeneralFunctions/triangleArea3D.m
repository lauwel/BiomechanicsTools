function tri_area = triangleArea3D(pts)
% pts are npts x [xyz] (pts in rows, x in first column, y in second, z in
% third)
% computes the area

v1 = pts(1,:) - pts(2,:);
v2 = pts(3,:) - pts(2,:);

tri_area = norm(cross(v1,v2))/2;