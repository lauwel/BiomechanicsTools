function point_new = closestPointonPlanealongVector(point,plane_norm,plane_point,vec)
% *Find the closest point on a plane of a point along a specific vector*

% INPUTS
% point         =       original point
% plane_norm    =       normal vector of the plane
% plane_point   =       point on the plane
% vec           =       vector from point to intersection of plane

% OUTPUT
% point_new     =       the point on the plane 

if dot(vec,plane_norm) == 0
    error('Line and plane are parallel. Infinite available solutions.')
end

if (size(point,1)~= size(plane_norm,1)) || (size(plane_point,1)~= size(plane_norm,1)) || (size(vec,1)~= size(plane_norm,1))
    error('Input variables are different sizes. Please make them the same size')
end

a = -1* dot((point - plane_point),plane_norm) / dot(vec, plane_norm);

point_new = a * vec + point;


