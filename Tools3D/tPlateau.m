function [pts_p conn_p] = tPlateau(pts_m, conn_m, pts_i, rt_i, centroid_m, slice_properties, pname, tm)
% [pts_p conn_p] = tPlateau(pts_m, conn_m, rt_i, centroid_m,
% slice_properties, pname, tm)
%
%   [pts_p conn_p]:  points and connections comprising only the tibial
%   plateau
%
%   pts_m:  points comprising the 3-D tibia model
%   conn_m: 3-D tibia model point connections
%   pts_i:  points comprising the 3-D tibia model registered to it's
%           inertial axes and centroid
%   rt_i:   transformation matrix comprising the 3-D tibia models inertial
%           axes and centroid
%   centroid_m: centroid of 3-D tibia iv model
%   slice_properties:   axial slice properties of the 3-D femur model
%   pname:  path where 3-D tibia iv model is located
%   fm:     file name of 3-D tibia iv model (e.g. tibia0123.iv)
%
%   This script isolates the tibial plateau
%
%   This code was written by Daniel Miranda and Evan Leventhal at Brown
%   University

[max_area widest_slice_index] = max(slice_properties.area);
widest_pt = slice_properties.centroid(widest_slice_index,:); % this is the point at the widest cross sectional area

% lets figure out which way along X of the inertial axes points me towards
% the tibial platau. The centroid (0,0,0) now should be closer to the
% plautau since its larger and has more mass.
if (max(pts_i(:,1)) > abs(min(pts_i(:,1))))
    % if the max value is greater, then we are pointed the wrong way, flip
    % X & Y to keep us straight
    rt_i(1:3,1) = -rt_i(1:3,1);
    rt_i(1:3,2) = -rt_i(1:3,2);
end

% we now want to change the coordinate system, so that z points in the
% positive z direction. To do so, make z the new x, and x the negated z, we
% are basically rotating around the y axis by 90°
RT_positive_z=eye(3);
RT_positive_z(:,3)=rt_i(1:3,1);
RT_positive_z(:,1)=-rt_i(1:3,3);
RT_positive_z(:,2)=rt_i(1:3,2);

%% crop tibial plateau
% create a 4x4 transformation matrix from rotation matrix and bottom crop
% pt to be used for cropping
RT_crop = RT_to_fX4(RT_positive_z(1:3,1:3),widest_pt);
RT_crop_inverted = RT_crop^-1;
% crop plane at RT_crop_inverted
[pts_p_initial conn_p_initial]=cropIVFileToPlane(pts_m,conn_m,RT_crop_inverted);

%% determine centroid and inertial axes of cropped tibial plateau
[centroid.p,sa.p,v.p,evals.p,inertial_axes.p,I1.p,I2.p,CoM.p,I_origin.p,patches.p] = mass_properties(pts_p_initial,conn_p_initial);

%% create transformation matrix from the inertial axes and center of mass
%  and then orient it in the positive z direction in order to make second
%  crop upwards
RT_plateau=[inertial_axes.p; centroid.p];
pts_plateau_inertia=transformShell(pts_p_initial,RT_plateau,-1,1);

% lets figure out which way along Z of the inertial axes points me towards
% the tibial platau. the full centroid should be below the tibial plateau
% centroid
correct_direction=unit(centroid.p-centroid_m);
if AngleDiff(correct_direction,RT_plateau(1:3,3))>90
    % if the the z-axis is pointing distal, then invert it and the y-axis
    % (to keep right handed coordinate system)
    RT_plateau(1:3,2:3)=-RT_plateau(1:3,2:3);
end

%% crop tibial plateau again using the inertial axes of the tibial plateau
% create a 4x4 transformation matrix from rotation matrix and bottom crop
% pt to be used for cropping
RT_plateau_crop = RT_to_fX4(RT_plateau(1:3,1:3),widest_pt);
RT_plateau_crop_inverted = RT_plateau_crop^-1;
% crop plane at RT_plateau_crop_inverted

[pts_p, conn_p] = cropIVFileToPlane(pts_m,conn_m,RT_plateau_crop_inverted,fullfile(pname,[tm(1:length(tm)-3),'_plateau_crop.iv']));