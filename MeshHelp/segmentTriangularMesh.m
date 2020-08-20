function [output_pts,output_triangles] = segmentTriangularMesh(input_points,input_triangles,input_plane)

 % Determine the distance of each point to the plane 

% Determine the distance of each point to the plane; output the points in a
% structure that has the positive, negative and original vertices each with
% the vertex co-ordinates, the distance and the original index of the point

% L. Welte (March 2016)

points = PointToPlaneDistance(input_points,input_plane);


%% Make the starting output points variable

if isfield(points,'positive')
    output_pts = points.positive(:,1:3);
    output_triangles = [];
else
    warning('Plane does not intersect the mesh.')
    output_pts = [];
    output_triangles = [];
    return
end

for i = 1:size(points.positive,1)
    % map the original point numbers to the new ones
    %     column 1 is the new, column 2 is old; then sort by old
    mapping_pts(i,:) = [i, points.positive(i,5)];
    mapping_pts_sorted = sortrows(mapping_pts,2);
end

%% Classify the triangles
 % Look at every triangle and determine which of the four cases it fits
 % into (i.e. is it intersected by the plane? and if it is, what is the
 % orientation of the triangles around it?)
 a1b2Triangles = [];
 a2b1Triangles = [];
 
 
 count(1:3) = 1;
for i = 1:size(input_triangles,1)
 
    a = input_triangles(i,1); % vertex 1 at triangle i
    b = input_triangles(i,2); % vertex 2 at triangle i
    c = input_triangles(i,3); % vertex 3 at triangle i
    
    % numsum takes the indicators in column 4 that show whether it was
    % above or below the plane; the sum of these indices has four possible
    % outcomes
    numsum = points.original(a,4) + points.original(b,4) + points.original(c,4);
    if numsum == 3 %all three above
        % save them all into the output triangles
        output_triangles_temp(count(1),1:3) =  input_triangles(i,1:3);
        % now map the old triangle connections to the new points
        for k = 1:3
            
                [x,ind] = find(mapping_pts_sorted(:,2) == output_triangles_temp(count(1),k));
                
                if isempty(x) == 1
                    warning('Connection was not properly mapped to new point. A zero was used instead. ')
                    output_triangles(count(1),k) = 0;
                else
                    output_triangles(count(1),k) = x;
                end
           
        end
        
        count(1) = count(1) + 1;
    elseif numsum == -3 % all three below
        % don't do anything
    elseif numsum == -1 %one vertex above, two below
        % record the affected triangles as 1 above, 2 below
        a1b2Triangles(count(2),1:3) = input_triangles(i,1:3);
        count(2) = count(2) + 1;
        
    elseif numsum == 1 % two above, one below
        a2b1Triangles(count(3),1:3) = input_triangles(i,1:3);
        
        if points.original(a,4) < 0 % there should only be one negative
            a2b1Triangles(count(3),4) = a; % save the negative point
        elseif points.original(b,4) < 0
            a2b1Triangles(count(3),4) = b;
        else
            a2b1Triangles(count(3),4) = c;
        end
        
        
        count(3) = count(3) + 1;
    else
        warning('The triangle of index %i was not properly categorized',i)
    end
        
end
% 

%% Deal with the triangles with one vertex above and two below the plane

% capital letters are indexes of the vertices, small letters are the
% coordinates
% A is the index of the point above the plane, B, C are below
%     i.e.  a is the coordinates of vertex A etc
% b' is the coordinates of the point between A and B on the plane
% c' is the coordinates of the point between A and C that's on the plane
plane = input_plane;
planecentre = plane.Centre;
planeNormal = plane.Normal;

planeUnitVec = planeNormal / norm (planeNormal);

% determine D in the equation of the plane from a point on the plane
D = -(planeUnitVec(1) * planecentre(1) + planeUnitVec(2) * planecentre(2) + planeUnitVec(3) * planecentre(3)); 

for i = 1: size(a1b2Triangles,1)
    n_outputPts = size(output_pts,1);
    n_outputTriangles = size(output_triangles,1);
    
%     for each triangle, look at the individual indices and find the
%     positive point by looking it up in the mapping array
    for k = 1:3
        
        [x,ind] = find(mapping_pts_sorted(:,2) == a1b2Triangles(i,k));
        
        if isempty(x) == 0
            A_index = x;
            A_location = k; % should only be 1 value
            output_triangles(n_outputTriangles + 1,A_location) = A_index;
        end
    end
    
    a_pt = output_pts(A_index,:);
        
    if A_location == 1
        B_index = a1b2Triangles(i,2);
        b_pt = points.original(B_index,1:3);
        
        C_index = a1b2Triangles(i,3);
        c_pt = points.original(C_index,1:3);
    elseif A_location == 2
         B_index = a1b2Triangles(i,3);
        b_pt = points.original(B_index,1:3);
        
        C_index = a1b2Triangles(i,1);
        c_pt = points.original(C_index,1:3);
        
    elseif A_location == 3
        
        B_index = a1b2Triangles(i,1);
        b_pt = points.original(B_index,1:3);
        
        C_index = a1b2Triangles(i,2);
        c_pt = points.original(C_index,1:3);
    end
%     determine the new points on the plane (b', c') 

    
        u(1) = dot((planecentre - a_pt),planeNormal) / dot((b_pt-a_pt),planeNormal);
        u(2) = dot((planecentre - a_pt),planeNormal) / dot((c_pt-a_pt),planeNormal);
        b_prime = a_pt + u(1) * (b_pt - a_pt); % new dummy points  
        c_prime = a_pt + u(2) * (c_pt - a_pt); 

        
        B_prime_index = n_outputPts+1;
        C_prime_index = n_outputPts+2;
        
    output_pts(B_prime_index,:) = b_prime; 
    output_pts(C_prime_index,:) = c_prime;

    
    if A_location == 1
       output_triangles(n_outputTriangles + 1,2:3) = [B_prime_index,C_prime_index];
    elseif A_location == 2
        output_triangles(n_outputTriangles + 1,3) = B_prime_index;
        output_triangles(n_outputTriangles + 1,1) = C_prime_index;
    elseif A_location == 3
        output_triangles(n_outputTriangles + 1,1:2) = [B_prime_index,C_prime_index];
    end
    
end
    

 %% Code the two above, one below triangles
 
%  A and B are indices of the positive points and C is the negative;

% determine two points - a', b' that are linear interpolations to the plane

 for i = 1:size(a2b1Triangles,1)
     

  n_outputPts = size(output_pts,1);
    n_outputTriangles = size(output_triangles,1);
    for k = 1:3
        
        if a2b1Triangles(i,k) == a2b1Triangles(i,4)
            C_location = k;
        end
        
    end
    
    
    
    if C_location == 1
        A_index = a2b1Triangles(i,2);
        a_pt = points.original(A_index,1:3);
        
        B_index = a2b1Triangles(i,3);
        b_pt = points.original(B_index,1:3);
        
        C_index = a2b1Triangles(i,1);
        c_pt = points.original(C_index,1:3);
    elseif C_location == 2
        A_index = a2b1Triangles(i,3);
        a_pt = points.original(A_index,1:3);
        
        B_index = a2b1Triangles(i,1);
        b_pt = points.original(B_index,1:3);
        
        C_index = a2b1Triangles(i,2);
        c_pt = points.original(C_index,1:3);
        
    elseif C_location == 3
        A_index = a2b1Triangles(i,1);
        a_pt = points.original(A_index,1:3);
        
        B_index = a2b1Triangles(i,2);
        b_pt = points.original(B_index,1:3);
        
        C_index = a2b1Triangles(i,3);
        c_pt = points.original(C_index,1:3);
    end
    
%     reindex the positive points to correspond with the output points

    [x,ind] = find(mapping_pts_sorted(:,2) == A_index);
    A_index_new = x;
    [x,ind] = find(mapping_pts_sorted(:,2) == B_index);
    B_index_new = x;
    
    
%     determine the new points on the plane (b', a') 

    
        u(1) = dot((planecentre - b_pt),planeNormal) / dot((c_pt-b_pt),planeNormal);
        u(2) = dot((planecentre - a_pt),planeNormal) / dot((c_pt-a_pt),planeNormal);
        b_prime = b_pt + u(1) * (c_pt - b_pt); % new dummy points  
        a_prime = a_pt + u(2) * (c_pt - a_pt); 

        
        B_prime_index = n_outputPts+1;
        A_prime_index = n_outputPts+2;
    
    % Store the newly generated points
    output_pts(B_prime_index,:) = b_prime; 
    output_pts(A_prime_index,:) = a_prime;

    % Store the connections for the two new triangles (since it was a
    % quadrilateral, two triangles are made
    
    output_triangles(n_outputTriangles + 1,1:3) = [A_index_new,B_index_new,B_prime_index];
    output_triangles(n_outputTriangles + 2,1:3) = [B_prime_index,A_prime_index,A_index_new];

    
end










