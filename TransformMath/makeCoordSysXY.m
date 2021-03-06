% Make a coordinate system that uses the first two markers to make X, the first and third to make y 
function T = makeCoordSysXY(markers,origin)

% put markers in as column vectors so 
%[x1,x2,x3,x4;
% y1,y2,y3,y4;
% z1,z2,z3,z4]
% origin should be a column vector
% the first and second marker make up the primary vector.

[r,c] = size(origin);
if c > r 
    warning('Check that the markers used to make the coordinate system are column vectors.')
end

    x_v = markers(:,2) - markers(:,1);
    temp_v = markers(:,3)- markers(:,1);
    
    z_v = cross(x_v,temp_v);
    y_v = cross(z_v,x_v);
    
    x_u = x_v/norm(x_v);
    y_u = y_v/norm(y_v);
    z_u = z_v/norm(z_v);
    
    R = [x_u,y_u,z_u];
    
    T = eye(4,4);
    T(1:3,1:3) = R;
    T(1:3,4) = origin;
    
end
