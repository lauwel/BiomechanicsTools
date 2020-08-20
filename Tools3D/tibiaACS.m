function tACS = tibiaACS(centroid_m, centroid_p, inertial_axes_p, anteriorpt)
% tACS = tibiaACS(centroid_m, centroid_p, inertial_axes_p, anteriorpt)
%
%   tACS:   4x4 matrix containing the tibial ACS axes and origin
%
%   centroid_m: centroid of 3-D tibia model
%   centroid_p: centroid of plateau
%   inertial_axes_p:    inertial axes of only the tibial plateau
%   anteriorpt: any point on the anterior half of the tibia
%
%   This script script calculates the tibial ACS axes and origin and
%   places it in a 4x4 transformation matrix
%
%   This code was written by Daniel Miranda and Evan Leventhal at Brown
%   University

%% Determine center of ACS from the plateau crop center of mass
T=centroid_p;

%% Assign diaphysis vector as the largest inertial axis of the cropped plateau
diaphysis_vector=inertial_axes_p(:,3);

% check to make sure long axis is pointing proximal by comparing its
% direction to the direction from the center of mass of the full tibia to
% the center of mass of the cropped tibial plateau
if AngleDiff(unit(centroid_p-centroid_m),diaphysis_vector) > 90
    % if the two vectors are pointing in opposite directions negate the
    % diaphysis vector to make it point upwards
    diaphysis_vector=-diaphysis_vector;
end

%% make sure anterior posterior axis is pointing forward
% check to make sure anterior posterior axis is poinging anterior by
% comparing its direction to the direction from the center of mass of the
% tibial plateau crop to the specified anterior point
anterior_direction=inertial_axes_p(:,2);
if AngleDiff(unit(anteriorpt-centroid_p),anterior_direction) > 90
    % if the two vectors are pointing in opposite directions negate the 2nd
    % inertial axis and make it point anterior
    anterior_direction=-anterior_direction;
end

%% creat rotation matrix from the diaphysis vector and remaining inertial axes
R=eye(3);
R(:,3)=diaphysis_vector;
R(:,2)=anterior_direction;
R(:,1)=unit(cross(anterior_direction,diaphysis_vector));

%% compile ACS as an RT from the R and T
tACS=[R,T';[0 0 0 1]];