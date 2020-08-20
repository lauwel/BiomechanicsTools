function fACS = femurACS(centroid_m, centroid_d, diaphysis_vector, cylinder_fit_axis,cylinder_fit_base_pt,cylinder_fit_height)
% fACS = femurACS(pts_m, pts_d, centroid_m, centroid_d, diaphysis_vector,
% cylinder_fit_axis,cylinder_fit_base_pt,cylinder_fit_height)
%
%   fACS:   4x4 matrix containing the femoral ACS axes and origin
%
%   centroid_m: centroid of 3-D femur model
%   centroid_d: centroid of diaphysis
%   cylinder_fit_axis:  axis through center of fitted cylinder
%   cylinder_fit_base:  base of fitted cylinder
%   cylinder_fit_height:    height of fitted cylinder
%
%   This script script calculates the femoral ACS axes and origin and
%   places it in a 4x4 transformation matrix
%
%   This code was written by Daniel Miranda and Evan Leventhal at Brown
%   University


%% determine center of ACS from the midpoint of the cylinder fit to the condyles
T=cylinder_fit_base_pt+(cylinder_fit_height/2)*unit(cylinder_fit_axis);

%% Make sure diaphysis vector is pointing toward the proximal femur
correct_direction=unit(centroid_d-centroid_m); % determine vector between centroid of diaphysis and centroid of entire femur bone to compare to diaphysis vector
angular_difference1=AngleDiff(correct_direction,diaphysis_vector); % comparison of diaphysis vector and correct direction vector

% if the diaphysis vector and direction are facing in opposite directions, then invert the diaphysis vector
if angular_difference1 > 90
    diaphysis_vector= -diaphysis_vector;
end

%% Create rotation matrix from cylinder fit vector and diaphysis vector
% make sure that the medial lateral axis is pointing in a direction that
% will allow long axis to be pointing proximal and anterior posterior axis
% pointing posterior.  if this is not the case negate the cylinder fit axis
angular_difference2=AngleDiff(correct_direction,unit(cross(unit(diaphysis_vector),unit(cylinder_fit_axis))));
if angular_difference2>90
    cylinder_fit_axis=-cylinder_fit_axis;
end

% assign x-axis as the medial lateral axis based on the cylinder fit vector
% assign y-axis as the anterior posterior axis based on the cross between
% the diaphysis vector and the cylinder fit vector
% assign z-axis as the long axis based on the cross between the medial
% lateral axis and the anterior posterior axis
R=eye(3);
R(:,1)=unit(unit(cylinder_fit_axis));
R(:,2)=unit(cross(unit(diaphysis_vector),R(:,1)));
R(:,3)=unit(cross(R(:,1),R(:,2)));

%% compile ACS as an RT from the R and T
fACS=[R,T';[0 0 0 1]];