function [pts_d conn_d] = fDiaph(pts_m, conn_m, pts_i, rt_i, slice_properties, centroid_m, pname, fm)
% [pts_d conn_d] = fDiaph(pts_m, conn_m, pts_i, rt_i, slice_properties,
% centroid_m, pname, fm)
%
%   [pts_d conn_d]:  points and connections comprising only the femoral
%   diaphysis
%
%   pts_m:  points comprising the 3-D femur model
%   conn_m: 3-D femur model point connections
%   pts_i:  points comprising the 3-D femur model registered to it's
%           inertial axes and centroid
%   rt_i:   transformation matrix comprising the 3-D femur models inertial
%           axes and centroid
%   slice_properties:   axial slice properties of the 3-D femur model
%   centroid_m: centroid of 3-D femur iv model
%   pname:  path where 3-D femur iv model is located
%   fm:     file name of 3-D femur iv model (e.g. femur0123.iv)
%
%   This script isolates the femoral diaphysis
%
%   This code was written by Daniel Miranda and Evan Leventhal at Brown
%   University

%% Determine point where shaft begins
[area_max area_max_index]=max(slice_properties.area); % largest cross sectional area
r=range(slice_properties.area)/2;  % half range of the min and max cross sectional area
for i=1:length(slice_properties.area),d(i)=dist(slice_properties.area(i),r);end
[condyle_end condyle_end_index]=min(d(area_max_index:length(slice_properties.area))); condyle_end_index=condyle_end_index+area_max_index; % index where condyles end
shaft_start_index=round(1.3*condyle_end_index); % index where shaft begins

[min_distance min_distance_index]=min(abs(slice_properties.index-slice_properties.index(shaft_start_index)));
bottom_crop_pt=slice_properties.centroid(min_distance_index,:); % point at which to crop condyles
bottom_crop_pt(:,1:2)=centroid_m(:,1:2); % x and y pts can be same as the center of mass' x and y pts

%% Crop the bottom of the femur shaft based on full inertial axes
% lets figure out which way along X of the inertial axes points me towards
% the femur condyles. The centroid (0,0,0) now should be closer to the
% condyles since its larger and has more mass.
if (max(pts_i(:,1)) < abs(min(pts_i(:,1))))
    % if the max value is smaller, then we are pointed the wrong way, flip
    % x & y to keep us straight
    rt_i(1:3,1) = -rt_i(1:3,1);
    rt_i(1:3,2) = -rt_i(1:3,2);
end;

% we now want to change the coordinate system, so that z points in the
% positive z direction. To do so, make z the new x, and x the negated z, we
% are basically rotating around the y axis by 90°
rt_positive_z=rt_i;
X_vec = rt_positive_z(1:3,1);
rt_positive_z(1:3,1) = -rt_positive_z(1:3,3);
rt_positive_z(1:3,3) = X_vec;

% create a 4x4 transformation matrix from rotation matrix and bottom crop
% pt to be used for cropping
tfm_bottom = RT_to_fX4(rt_positive_z(1:3,1:3),bottom_crop_pt);
tfm_bottom_inverted = tfm_bottom^-1;

% create diaphysis filename
fd=fullfile(pname,[fm(1:length(fm)-3),'_shaft_crop.iv']);

% crop bottom of diaphysis
[pts_d conn_d] = cropIVFileToPlane(pts_m,conn_m,tfm_bottom_inverted,fd);
