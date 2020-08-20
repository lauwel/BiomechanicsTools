function[intersect p] = intersect_line_facet(p1,p2, pa,pb,pc, n)
% function[intersect p] = intersect_line_facet(p1,p2, pa,pb,pc)
% Tests for the intersection of a line segment with a 3 Vertex facet. 
% The line segment is defined as the line between two points (p1 and p2)
% The facet is defined by its 3 vertices (pa, pb, and pc)
%
% Returns:
% intersect = 1 if intersection exists
% intersect = 0 if no intersection
% p = point of intersection [1x3] (undefined if intersect==0)
%
% Code from Paul Bourke
% http://local.wasp.uwa.edu.au/~pbourke/geometry/linefacet/
%
% Determine whether or not the line segment p1,p2
%    Intersects the 3 vertex facet bounded by pa,pb,pc
%    Return true/false and the intersection point p
% 
%    The equation of the line is p = p1 + mu (p2 - p1)
%    The equation of the plane is a x + b y + c z + d = 0
%                                 n.x x + n.y y + n.z z + d = 0

% calculate the parameters for the plane
% n(1) = (pb(2)-pa(2))*(pc(3)-pa(3)) - (pb(3)-pa(3))*(pc(2)-pa(2));
% n(2) = (pb(3)-pa(3))*(pc(1)-pa(1)) - (pb(1)-pa(1))*(pc(3)-pa(3));
% n(3) = (pb(1)-pa(1))*(pc(2)-pa(2)) - (pb(2)-pa(2))*(pc(1)-pa(1));
% n = unit(n);
% normal = cross prouct of two vectors between any two edges
if (nargin<6)
    % check if n was pre-calculated and passed in
    n = unit(cross(pb-pa,pc-pa));
end;
d = -sum(n.*pa); % = 0- n.x * pa.x - n.y * pa.y - n.z * pa.z;

p = [0 0 0]; %pre-allocate to prevent strange error

% Calcualte the position of the line that intersects teh plane
denom = dot(n,p2-p1);
if (abs(denom)<0.00001)
    intersect=0;  %they don't intersect
    return;
end;

mu = -(d + sum(n.*p1)) / denom; %mu = - (d + n.x * p1.x + n.y * p1.y + n.z * p1.z) / denom;
p = p1 + mu*(p2-p1);

if (mu<0 || mu > 1) %intersectin not allong line segment
    intersect = 0;
    return;
end;

%Determine whether or not the intersection point is bounded by pa,pb,pc
% create three vectors from our intersection point to the 3 facet vertices.
% The sum of the angle between these vectors == 360° if the point is
% inside, otherwise it is <180°. (Clever Mr. Bourke....)
pa1 = unit(pa-p);
pa2 = unit(pb-p);
pa3 = unit(pc-p);
a1 = dot(pa1,pa2);
a2 = dot(pa2,pa3);
a3 = dot(pa3,pa1);
total = acos(a1) + acos(a2) + acos(a3);
if (abs(total - 2*pi) < 0.00001)
    intersect=1;
else
    intersect=0;
end;
