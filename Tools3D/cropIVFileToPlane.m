function [croppedPts, croppedConn] = cropIVFileToPlane(varargin)
% cropIVFileToPlane   Crops the given IV file at a plane closing the
% cropped face. By default will crop in the Z plane.
%
%   cropIVFileToPlane(ivFname), will crop the IV file in the z-plane saving
%       all points with z>0.
%
%   cropIVFileToPlane(ivFname, level) where level is a scalar indicating
%       the value to use as a threshold for z. Saves all points where
%       z>level.
%   cropIVFileToPlane(ivFname, RT) where RT is a transformation matrix. It
%       will crop all points with z>0 in the coordinate system defined by
%       RT. Basically, apply RT to all points, crop the IV files, then
%       apply the inverse of RT to resultant points and save.
%
%   cropIVFileToPlane(pts,conn)
%   cropIVFileToPlane(pts,conn,...) Where pts is N-by-3 and conn is M-by-3 (or
%       M-by-4). This will use the points and connections passed instead of
%       reading from a file.
%
%   cropIVFileToPlane(...,saveFname) after applying the specified crop, it
%       will save the file to the new filename specified and NOT overwrite
%       the input
%
%   [P,C] = cropIVFileToPlane(...) after applying the specified crop,
%       return the new points and connections as parameters. If no
%       saveFname was specified, the original file is NOT overwritten.
%
%   Evan Leventhal - 8/16/08

if (nargin==0)
    error('CropIV:NoParam', 'No parameters specified');
    warning('CropIV:NoParam','No parameters specified, defaulting to test mode');
    varargin{1} = 'F:\LocalCopies\DannyKnee\HUMAN KNEES_226 Tibia_001.iv';
    varargin{2} = -250.394;
    varargin{3} = 'F:\LocalCopies\DannyKnee\cropTest.iv';
end;
% get the input
if (ischar(varargin{1})) %we were passed a filename
    % read in the IV file, and then remove the extra -1 field. Also correct for
    % matlab 1 based index instead of 0 based.
    [pts conn] = read_vrml_fast(varargin{1});
    conn(:,4) = [];
    conn(:) = conn(:)+1;
    varargin(1) = [];
else
    %we should have pts and conn passed then :)
    if (nargin<2 || ~isnumeric(varargin{1}) || ~isnumeric(varargin{2}) || size(varargin{1},2)~=3 || size(varargin{2},2)<3)
        error('CropIV:Arugments', 'No ivFile or pts & conn were passed in');
    end
    pts = varargin{1};
    conn = varargin{2};
    if (size(conn,2)==4) %if we have extra clear it
        conn(:,4)= []; 
    end
    if (min(min(conn))==0) %if the index was not corrected, correct
        warning('CropIV:ConnIndex','Connection matrix appears to be still 0-indexed, adding 1 to all indices');
        conn(:) = conn(:)+1;
    end;
    varargin(1:2) = [];
end

saveFname = '';
%check for an output file, should be the last param
if (size(varargin,2)>=1 && ischar(varargin{end}))
    saveFname = varargin{end};
    varargin(end) = []; %now remove
end;
RT = eye(4);
thresh = 0;
%check for an RT or a threshold
if (size(varargin,2)>=1 && isnumeric(varargin{1}))
    %check for threshold
    if (size(varargin{1},1)==1 && size(varargin{1},2)==1)
        thresh = varargin{1};
        varargin(1) = [];
    elseif (size(varargin{1},1)==4 && size(varargin{1},2)==4)
        RT = [varargin{1}(1:3,1:3); varargin{1}(1:3,4)'];
        varargin(1) = [];
    elseif (size(varargin{1},1)==4 && size(varargin{1},2)==3)
        RT = varargin{1};
        varargin(1) = [];
    end;
end;

%check for extra parameters!
if (size(varargin,2)>0)
    error('CropIV:Arguments', 'Unknown input arguments');
end;

% if we were passed an RT, then we should use it!
if (~isequal(RT,[eye(3); 0 0 0]))
   pts = transformShell(pts,RT,1,1); 
end

% identify all points that are above our threshold that we should be saving
ptsIndex = pts(:,3) > thresh;

%check that we are saving something
if (sum(ptsIndex)==0)
    error('CropIV:NoPoitns', 'No points remain after cropping. Nothing to do!');
end;

% Okay, now lets identify all triangles that we are going to save, and
% those that are partially on the border and will need to be dealt with
% later.
keepConn = ones(length(conn),1);  %pre-alocate arrays for speed
partialConn = ones(length(conn),1);
for i=1:length(conn)
    % loop through every triangle, and check how many of its 3 vertices
    % were marked to be kept. If all 3, then its a keeper; if 1 or 2, then
    % we will deal with it later. Anything with 0 is a gonner!
    numKeep = sum(ptsIndex(conn(i,:)));   
    keepConn(i) = (numKeep==3);
    partialConn(i) = (numKeep==1 || numKeep==2);
end;

% Okay, lets build our new array of points an connections with just the
% keepers. Connections are easy, we just save the ones we want. Points the
% same, but we will need to keep track of how each point's index changes,
% so that the connections will be pointing to the right place.
newConn = conn(keepConn(:)==1,:);
newPts = pts(ptsIndex,:);
numNewPts = length(newPts);
%pre-allocate the translation map to 0's to the length of all the old
%points. Since the order of the points has not changed, just the unused
%points were removed. With that in mind, we can just choose the old index
%for the points we want to keep, and set those to the new indexs which is
%just an ordered list :)
translation = zeros(length(pts),1); 
translation(ptsIndex,1) = 1:numNewPts; 
% finally, we can now go through and translate the indexes of points in the
% old triangles, to their new index using the translation map we already
% made.
newConn(:) = translation(newConn(:));

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The next step is to clean up the jagged edge left by the previous
% cropping. This is where all those partial triangles come in handy. The
% goal is to create a new smaller triangle for each of the existing ones
% that will end exactly on the crop line.

% First we can pre-allocate the arrays here. We know that we will be
% creating 2 new points for each triangle (it should really be one, as this
% will create duplicate points, but its easier to create extra and then
% remove the duplicates later). We don't know how many triangles we will
% make, best case, is one for every partial; worst case is two for every
% partial, so we will pre-allocate for that, and then fix it later.
partialConns = conn(partialConn(:)==1,:);
extraPts = zeros(length(partialConns)*2,3); 
extraConn = zeros(length(partialConns)*2,3); 
numSavedPts = length(newPts); %get the number of points we saved, so we know what the index's of the new points will be
numNewPts = 0;
numNewConn = 0;
for i=1:length(partialConns),
    inside = ptsIndex(partialConns(i,:)); %check how many points to keep
    if (sum(inside)==1), 
        % if there was only one, then this is the easier case, we only
        % create one triangle. To make sure that we keep the facet facing
        % the right way, we make certain that the order of points stays the
        % same as it was originaly.
        pt1_index = partialConns(i,inside>0);
        pt1 = pts(pt1_index,:);
        outPoints = pts(partialConns(i,inside==0),:);
        pt2 = createGradientPoint(pt1,outPoints(1,:),thresh);
        pt3 = createGradientPoint(pt1,outPoints(2,:),thresh);
        extraPts(numNewPts+1,:) = pt2;
        extraPts(numNewPts+2,:) = pt3;
        extraConn(numNewConn+1,inside>0) = translation(pt1_index);
        extraConn(numNewConn+1,inside==0) = [numSavedPts+numNewPts+1 numSavedPts+numNewPts+2];
        numNewPts = numNewPts+2;
        numNewConn = numNewConn+1;
    else 
        % Okay, so there are two inside, and we are going to create two new
        % ones, so we need to make two triangles to connect the four points
        inIndeces = partialConns(i,inside>0);
        inPoints = pts(partialConns(i,inside>0),:);
        outPoint = pts(partialConns(i,inside==0),:);
        pt1 = createGradientPoint(inPoints(1,:),outPoint,thresh);
        pt2 = createGradientPoint(inPoints(2,:),outPoint,thresh);
        extraPts(numNewPts+1,:) = pt1;
        extraPts(numNewPts+2,:) = pt2;
        extraConn(numNewConn+1,inside>0) = translation(inIndeces);
        extraConn(numNewConn+1,inside==0) = numSavedPts+numNewPts+1; %new pt1
        extraConn(numNewConn+2,inside>0) = [numSavedPts+numNewPts+1 translation(inIndeces(2))]; %new pt1 & old in pt2
        extraConn(numNewConn+2,inside==0) = numSavedPts+numNewPts+2; %new pt2
        numNewPts = numNewPts+2;
        numNewConn = numNewConn+2;
    end
end
extraConn(numNewConn+1:end,:) = []; %clean up extra space that was not used in the pre-allocated array.

% We want to create an set of edges that make up the new flat surface. We
% know that we have 1 for every partial triangle, and that they were
% entered in pairs. So we want it to be [1 2; 3 4; 5 6]. However, since the
% final index of the poitns will be at the end of the existing ones, we
% need to incriment the index by the number of saved points.
contourConn = ((1:length(partialConns))*2-1+numSavedPts)';
contourConn(:,2) = contourConn(:,1)+1;

% Alright, its finally time to go remove the duplicate points that we
% just created, we should be cutting down the number of points in half.
% Matlab's 'unique' function works well for this, and will even return to
% us a looup table for old point indexes to the new ones :)
[extraPts m n] = unique(extraPts,'rows');
% time for another translation table (we can use the same variable, because
% we are done with the old one)
% since the translation will included saved poitns, we need to make sure
% that we have lookups for those points, and that its a 1:1 match.
translation = 1:(numSavedPts + numNewPts);
translation(numSavedPts+1:end) = n + numSavedPts; %correct to offset of new points
extraConn(:) = translation(extraConn(:)); %translate the triangles
contourConn(:) = translation(contourConn(:)); %translate the edge

%sanity check that we have the right number of points, and we caught all of
%the duplicated points
if (size(extraPts,1) ~= size(partialConns,1))
    warning('CropIV:ExtraPoints','More new points were created then expected. Most likely duplicate points were not removed');
end;

% For unknown reasons, I found that I had triangles that had two of the
% same vertices. Very weird, but we can identify and remove those.
%remove triangles that have two vertices at the same place
extraConn(extraConn(:,1)==extraConn(:,2) | extraConn(:,3)==extraConn(:,2) | extraConn(:,1)==extraConn(:,3),:) = [];
contourConn(contourConn(:,1)==contourConn(:,2),:) = [];

%lets try addiing these new points on to the end
newPts = [newPts; extraPts];
newConn = [newConn; extraConn];

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time to build the contour at the top, so we can later fill the hole

% Lets build the order of the new points, so I have a contour for the
% surface that needs to be closed. Starting with the first edge pair, go
% though from one end, and find the second edge that shares the same point
% and add its neightboor to the list. Rinse and repeat.
numContours = 0;
remaining = contourConn;
contourOrder = cell(1);
while(size(remaining,1)>0)
    numContours = numContours + 1;
    contourOrder{numContours} = zeros(length(remaining),1); %preallocate for speed
    contourOrder{numContours}(1:2) = remaining(1,:); %set the first two....
    remaining(1,:) = []; %delete the first entry, we no longer are searching for it
    prev = contourOrder{numContours}(2); %save the last one entered
    currentIndex = 2;
    while(any(any(prev==remaining))) %loop while the current entry is still available
        %find the next one in the loop (should only be one)
        [row column] = find(remaining==prev);
        currentIndex = currentIndex + 1;
        %column is either 1 or 2, we want the other, 
        otherColumn = ~(column-1) + 1;
        contourOrder{numContours}(currentIndex) = remaining(row,otherColumn);
        prev = remaining(row,otherColumn); %update previous counter
        remaining(row,:) = []; %remove from list of remaining
    end;
    % no more, lets free any unused space. Also, delete the last point we
    % added, which should be the same as the first point
    if (contourOrder{numContours}(1) ~= contourOrder{numContours}(currentIndex))
        error('CropIV:UnknownContour','Invalid contour found. Contour (%d) does not loop back',numContours);
    end;
    contourOrder{numContours}(currentIndex:end) = [];
end;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Time to close the hole, hopefully we have a contour that tells us what
% points need to be used in order. Note this whole thing, assumes all the
% points in the contour have the same z-value :)

%do this for each contour we identified
for i=1:length(contourOrder)
    topConn = closeContour(newPts, contourOrder{i});
    % Lets add the connections for the top to our list
    newConn = [newConn; topConn];
end;

%Finally, if we were originaly passed an RT, then we need to move
%everything back before we return
if (~isequal(RT,[eye(3); 0 0 0]))
   newPts = transformShell(newPts,RT,-1,1); 
end

% check if there is an output file, if so, save away!
if (~isempty(saveFname))
    patch2iv(newPts,newConn(:,1:3),saveFname);
end;

if (nargout==2) %output the points and connections if the user wants them
    croppedPts = newPts;
    croppedConn = newConn;
end;


end % end of main function

function [newConn] = closeContour(pts, contourOrder)
    % Need to check if contour is clockwise or counter-clockwise, and
    % standardize on counter-clockwise. The order we get is random based on
    % the first partial triangle. If this is wrong it won't be able to make the
    % top triangles.
    % Positive area indicates counter-clockwise contour, negative indicates
    % clockwise.
    area = calculateAreaContour(pts(contourOrder,1:2));
    if (area>0),
        contourOrder = flipud(contourOrder);
    end;

    % The algorithm for closing the top is as follows. Starting with the first
    % point. Try and make a triangle with the two points to the left, if it
    % works, then add the triangle, and remove the point to the left from the
    % list because its no longer needed. If we can't go left, try  the same
    % thing using the two points to the right (which are the last points in the
    % list). If we can't go right either, then we need to change the current
    % point, so take the first point, and move it to the end of the list, then
    % try again.

    % Pre-allocate. We know that the number of new triangles should be equal to
    % the number of edges - 2 (the first triangle uses 3 :)
    newConn = zeros(size(contourOrder,1)-2,3);
    currentTriangle = 0;
    while(length(contourOrder)>=3) % stop after the last triangle, 2 points left

        %try going left first
        p1 = pts(contourOrder(1),:);
        p2 = pts(contourOrder(2),:);
        p3 = pts(contourOrder(3),:);

        %check that the hull is convex between the two points, to do so we
        %need to get the z component of the cross product. 0 indicates that the
        %lines are colinear, the sign indicates convex or concave. If the hull
        %is concave, then our new edge would be outside the contour.
        % See:
        % http://local.wasp.uwa.edu.au/~pbourke/geometry/clockwise/index.html#clockwise
        crossProduct = cross(p2-p1,p3-p1);

        % after checking the corss product, make certain that this new triangle
        % does not contain the vertices of any remaining points, doing so would
        % mean that this triangle is too big, and is overlaping partialy with
        % something outside the contour.
        valid = crossProduct(3)<0 && sum(isPointsInsideTriangle(p1(1:2),p2(1:2),p3(1:2), pts(contourOrder(4:end),1:2)))==0;
        if (valid)
            %lets create a new triangle shall we
            currentTriangle = currentTriangle+1;
            newConn(currentTriangle,1:3) = contourOrder(1:3);
            contourOrder(2) = []; % remove that point, to mark as being done
            continue; %move on now
        end;

        %If we got here, then going left was unsuccessfull, so lets try going
        %right. P1 is the same, but we need a new p2 & p3.
        p2 = pts(contourOrder(end-1),:);
        p3 = pts(contourOrder(end),:);

        %check that the angle is concave between the two points, to do so we
        %need to get the z component of the cross product. 0 indicates that the
        %lines are colinear, the sign indicates convex or concave.
        crossProduct = cross(p2-p1,p3-p1);

        %check for a valid line. None of the remaining vertices can be
        %contained by the potential triangle that we are forming.
        valid = crossProduct(3)<0 && sum(isPointsInsideTriangle(p1(1:2),p2(1:2),p3(1:2), pts(contourOrder(2:end-2),1:2)))==0;
        if (valid)
            %lets create a new triangle shall we
            currentTriangle = currentTriangle+1;
            newConn(currentTriangle,1:3) = contourOrder([1 end-1 end]);
            contourOrder(end) = []; % remove that point, to mark as being done
            continue; %move on now
        end;

        %if we got here, then we can't go left or right, so lets move the
        %current first point to the end, so we can rotate around a bit
        contourOrder = [contourOrder(2:end); contourOrder(1)];
    end;
end



%checks what points are inside of the triangle
% a linear version of the code/algorithm found here:
% http://www.blackpawn.com/texts/pointinpoly/default.html
function [inside] = isPointsInsideTriangle(pa,pb,pc,p)
    paa(1:size(p,1),1) = pa(1);
    paa(:,2) = pa(2);
    v0 = pc-pa;
    v1 = pb-pa;
    v2 = p - paa;
    dot00 = dot(v0,v0);
    dot01 = dot(v0, v1);
    dot11 = dot(v1,v1);
    dot02 = v2(:,1).*v0(1) + v2(:,2).*v0(2);
    dot12 = v2(:,1).*v1(1) + v2(:,2).*v1(2);
    invDenom = 1/(dot00 * dot11 - dot01 * dot01);
    u = (dot11.*dot02 - dot01.*dot12) .* invDenom;
    v = (dot00.*dot12 - dot01.*dot02) .* invDenom;
    inside = (u>0 & v>0 & u+v<1);    
end


function [pt] = createGradientPoint(pt1, pt2, target_z)
    percent = (target_z - pt1(3)) / (pt2(3) - pt1(3));
    pt = pt1(:) + percent*(pt2(:)-pt1(:));
end

function [area] = calculateAreaContour(pts)
    %make sure the last points is the same as the first
    pts(end+1,:) = pts(1,:);
    x = (pts(1:end-1,1) + pts(2:end,1))./2;
    y = (pts(1:end-1,2) + pts(2:end,2))./2;
    dxy = pts(2:end,:) - pts(1:end-1,:);
    areas = -y.*dxy(:,1)./2 + x.*dxy(:,2)./2;
    area = sum(areas);
end