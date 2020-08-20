function vertices = PointToPlaneDistance(varargin)
% vertices = PointToPlaneDistance(input_vertices, plane,tol)
% This function determines the position of vertices relative to the plane
% and returns them as either negative (under the plane) or positive
% vertices (on top of the plane)

% input_vertices  = [x y z] where x, y and z are equal length column vectors
% denoting the vertices of an object
% plane = structure containing sub structures of the plane normal and position
% tol is an optional argument where you can select points close to the
% plane

input_vertices = varargin{1};
plane = varargin{2};
if nargin == 2
    tol = 0;
else
    tol = varargin{3};
end
planecentre = plane.Centre;
planeNormal = plane.Normal;

planeUnitVec = planeNormal / norm (planeNormal);

A = planeUnitVec(1);
B = planeUnitVec(2);
C = planeUnitVec(3);

% determine D from the centre point on the plane
D = -(A * planecentre(1) + B * planecentre(2) + C * planecentre(3)); 

% equation of a plane
z = @(x,y) - (A * x + B * y + D )/C;



[numvertices,~] = size(input_vertices);

for i = 1:numvertices
    x1 = input_vertices(i,1);
    y1 = input_vertices(i,2);
    z1 = input_vertices(i,3);
    % determine the distance to the plane for each vertex
    d(i,1) = (A * x1 + B * y1 + C * z1 + D) / sqrt(A^2 + B^2 + C^2);
    d(i,2) = i; % store the index along with each distance measurement
end

count(1:4) = 1;

% create a variable for storing all of the vertices based on the distance
% to the plane
for i = 1:numvertices
    
    if d(i,1) < -tol % below the plane
        vertices.negative(count(1),:) = [input_vertices(d(i,2),:) d(i,:)];
        vertices.original(count(4),:) = [input_vertices(d(i,2),:) -1 d(i,1)];
        count(1) = count(1)+1;
    elseif d(i,1) > tol % above the plane
        vertices.positive(count(2),:) = [input_vertices(d(i,2),:) d(i,:)];
        vertices.original(count(4),:) = [input_vertices(d(i,2),:) 1 d(i,1)];
        count(2) = count(2)+1;
    else%if d(i,1) == 0 % on the plane
        vertices.plane(count(3),:) = [input_vertices(d(i,2),:) d(i,:)];
        vertices.original(count(4),:) = [input_vertices(d(i,2),:) 0 d(i,1)];
        count(3) = count(3)+1;
    end
    
    count(4) = count(4) + 1;
    
end

