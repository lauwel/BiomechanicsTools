function [P] = calculateIntersectionLineIVFile(p1,p2,ivFile,conn)
%function [P] = calculateIntersectionLineIVFile(p1,p2,ivFile)
%function [P] = calculateIntersectionLineIVFile(p1,p2,pts,conn)
% Calculates all the intersections of the line segment defined between
% points p1 and p2, and the shell of the ivFile
%
%   Optional - Instead of an IV file, can pass in an array of pts and
%   connections
%
% Returns:
% P = points of intersection [nx3]. Empty if there were no intersections

if (nargin==4)
    pts = ivFile;
else
    [pts conn] = read_vrml_fast(ivFile);
    conn(:,4) = []; %save space
    conn(:,1:3) = conn(:,1:3)+1; %correct for matlab 1-based indexing
end;

P = [];
normals = calculateNormals(pts,conn);
for i=1:size(conn,1),
   [intersect i_point] = intersect_line_facet(p1,p2,pts(conn(i,1),:), pts(conn(i,2),:), pts(conn(i,3),:), normals(i,:));
   if (intersect==1),
       P(end+1,:) = i_point; %add each point to the array
   end;
end

end

function [normals] = calculateNormals(pts,conn)
    %pre-calculate normal of each triangle
    pts1 = pts(conn(:,1),:);
    pts2 = pts(conn(:,2),:);
    pts3 = pts(conn(:,3),:);
    vectorA = pts2 - pts1;
    vectorB = pts3 - pts1;

    %now lets go take the cross product :)
    % [x y z] = [a b c] X [d e f] = [(b*f)-(c*e), (c*d)-(a*f), (a*e)-(b*d)]
    normals = zeros(size(conn,1),3);
    normals(:,1) = vectorA(:,2).*vectorB(:,3) - vectorA(:,3).*vectorB(:,2);
    normals(:,2) = vectorA(:,3).*vectorB(:,1) - vectorA(:,1).*vectorB(:,3);
    normals(:,3) = vectorA(:,1).*vectorB(:,2) - vectorA(:,2).*vectorB(:,1);

    mag = (normals(:,1).^2 + normals(:,2).^2 + normals(:,3).^2).^0.5;
    normals(:,1) = normals(:,1)./mag;    
    normals(:,2) = normals(:,2)./mag;
    normals(:,3) = normals(:,3)./mag;
end