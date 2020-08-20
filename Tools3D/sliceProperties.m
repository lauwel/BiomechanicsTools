function output=sliceProperties(pts_m, pts_i, rt_i, slice_thickness)
% output = sliceProperties(pts_i, rt_i, slice_thickness)
%
%   output: slice area (output.area), slice centroid (output.centroid),
%           slice index (output.index), minimum medial-lateral pt
%           (output.min_ML_pt), maximum medial-lateral pt
%           (output.max_ML_pt), medial-lateral vector (output.ML_vector)
%
%   pts_m:  points comprising the 3-D bone model
%   pts_i:  points comprising the 3-D bone model registered to it's
%           inertial axes and centroid
%   rt_i:   transformation matrix comprising the 3-D bone models inertial
%           axes and centroid
%   slice_thickness:    slice thickness value
%
%   This script determines the properties of each slice
%
%   This code was written by Daniel Miranda and Evan Leventhal at Brown
%   University


% lets figure out which way along X of the inertial axes points me towards
% the femur condyles. The centroid (0,0,0) now should be closer to the
% condyles since its larger and has more mass.
if (max(pts_i(:,1)) < abs(min(pts_i(:,1))))
    
    % if the max value is smaller, then we are pointed the wrong way, flip
    % X & Y to keep us straight
    rt_i(1:3,1) = -rt_i(1:3,1);
    rt_i(1:3,2) = -rt_i(1:3,2);
    pts_i=transformShell(pts_m,rt_i,-1,1);
    
end

% max x-coordinate
[max_x max_x_index] = max(pts_i(:,1));
% min x-coordinate
[min_x min_x_index] = min(pts_i(:,1));

for i = 1:ceil(abs(min_x-max_x)/slice_thickness)
    
    % Find slice points
    poly_pts_index = find((pts_i(:,1) >= (min_x + (i-1)*slice_thickness) & pts_i(:,1) < (min_x + i*slice_thickness)));
    
    % Find length and width of bounding box
    r_y(i,1) = range(pts_i(poly_pts_index,2));
    r_z(i,1) = range(pts_i(poly_pts_index,3));
    
    area(i,1) = r_y(i,1)*r_z(i,1); % calculate area of bounding box
    centroid(i,1)=mean(pts_i(poly_pts_index,1)); % calculate x coordinate centroid
    centroid(i,2)=min(pts_i(poly_pts_index,2)) + range(pts_i(poly_pts_index,2))/2; % calculate y coordinate centroid
    centroid(i,3)=min(pts_i(poly_pts_index,3)) + range(pts_i(poly_pts_index,3))/2; % calculate z coordinate centroid
    
    [min_y_pt(i,2) min_index]=min(pts_i(poly_pts_index,2));
    min_y_pt(i,1)=centroid(i,1);
    min_y_pt(i,3)=centroid(i,3);
    
    [max_y_pt(i,2) max_index]=max(pts_i(poly_pts_index,2));
    max_y_pt(i,1)=centroid(i,1);
    max_y_pt(i,3)=centroid(i,3);
    
end

min_y_pt_TF=transformShell(min_y_pt,rt_i,1,1);
max_y_pt_TF=transformShell(max_y_pt,rt_i,1,1);
[max_r_y max_r_y_index]=max(r_y);

% move centroid pts back to CT space
output.area=area;
output.centroid=transformShell(centroid,rt_i,1,1);
output.index=1:length(area);
output.min_ML_pt=min_y_pt_TF(max_r_y_index,:);
output.max_ML_pt=max_y_pt_TF(max_r_y_index,:);
output.ML_vector=unit(output.max_ML_pt-output.min_ML_pt); % insure ML_vector is a unit vector