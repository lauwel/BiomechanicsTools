function surface_area = surface_area_iv(points,connection);
%% This works for closed or open iv surfaces.
%% Based on Heron's formula
%% ************************************************************************
%% Written by Anwar M. Upal
%% Last Modified April 30th, 2003
%% ************************************************************************


n = size(connection);

%pre-allocate for speed
area = zeros([n(1,1) 1]);

for i = 1:n(1,1)
    
    vertex1 = points(connection(i,1),:); 
    vertex2 = points(connection(i,2),:);
    vertex3 = points(connection(i,3),:);
    
    a = (norm(vertex1-vertex2));
    b = (norm(vertex2-vertex3));
    c = (norm(vertex1-vertex3));
    s = (a+b+c)/2;

    t_area = sqrt(s*(s-a)*(s-b)*(s-c));
    
    area(i) = t_area;  
end;
surface_area = sum(area);
