function [pts_c conn_c] = fCondyles(pts_m, conn_m, rt_i, slice_properties, centroid_m, centroid_d, diaphysis_vector, pname, fm)
% [pts_c conn_c] = fCondyles(pts_m, conn_m, rt_i, slice_properties,
% centroid_m, centroid_d, diaphysis_vector, pname, fm)
%
%   [pts_c conn_c]:  points and connections comprising only the femoral
%   condyles
%
%   pts_m:  points comprising the 3-D femur model
%   conn_m: 3-D femur model point connections
%   rt_i:   transformation matrix comprising the 3-D femur models inertial
%           axes and centroid
%   slice_properties:   axial slice properties of the 3-D femur model
%   centroid_m: centroid of the 3-D femur model
%   centroid_d: centroid of the femoral diaphysis
%   diaphysis_vector:   vector through femoral diaphysis
%   pname:  path where 3-D femur iv model is located
%   fm:     file name of 3-D femur iv model (e.g. femur0123.iv)
%
%   This script isolates the femoral condyles
%
%   This code was written by Daniel Miranda and Evan Leventhal at Brown
%   University

%% Hard coded numbers
maxDeviation=25; % max angle of deviation
pt_multiplication_factor=300;
sample=5;

%% Determine point where condyles begin

[area_max area_max_index]=max(slice_properties.area); % determine largest cross sectional area, slice where condyles is largest
r=range(slice_properties.area)/2;  % half range of the min and max cross sectional area, to determine where the condyles end

% determine the distance from each cross sectional area and the approximation of where the condyles end
for i=1:length(slice_properties.area)
    d(i)=dist(slice_properties.area(i),r);
end

% the cross sectional area that is closest to where the condyles end (r) isused to approximate where the condyles end
[condyle_end condyle_end_index]=min(d(area_max_index:length(slice_properties.area))); condyle_end_index=condyle_end_index+area_max_index;

%% Determine long axis of femur diaphysis from its inertial axes
% make sure diaphysis vector is pointing toward the distal femur
correct_direction=unit(centroid_m-centroid_d); % determine vector between centroid of diaphysis and centroid of entire femur bone to compare to diaphysis vector
angular_difference_diaphysis=AngleDiff(correct_direction,diaphysis_vector); % comparison of diaphysis vector and correct direction vector

% if the diaphysis vector and direction are facing in opposite directions, then invert the diaphysis vector
if angular_difference_diaphysis > 90
    diaphysis_vector= -diaphysis_vector;
end

%% determine where vector through diaphysis intersects bottom of condyles
distal_pt = calculateIntersectionLineIVFile(centroid_d,centroid_d + diaphysis_vector*300, pts_m, conn_m);

%% create rotation matrix using the y- and z-axes from the full inertial coordinate system, and the x-axis as the shaft vector

% set x-axis as the shaft vector pointing distally. z-axis is determined 
% first because it is required to point posterior and the y-axis can 
% point in any direction
R_inertia_with_diaphysis=eye(3);
R_inertia_with_diaphysis(:,1)=diaphysis_vector;
R_inertia_with_diaphysis(:,3)=unit(cross(diaphysis_vector,rt_i(1:3,2)));
R_inertia_with_diaphysis(:,2)=unit(cross(R_inertia_with_diaphysis(:,3),diaphysis_vector));

% make sure that the z-axis determined above is pointing posterior by
% comparing its direction to the vector going from the shaft centroid to
% the full model centroid
z_is_posterior=0;
angular_difference_ap=AngleDiff(correct_direction,R_inertia_with_diaphysis(:,3)');
if angular_difference_ap < 90
    z_is_posterior=1;
end

% negate y- and z-axes if the original z-axis is pointing anterior
if ~z_is_posterior
    R_inertia_with_diaphysis(:,2:3)= -R_inertia_with_diaphysis(:,2:3);
end

%% determine most proximal point where condyles should be cropped (on surface) the point on the surface in the direction of the z-axis
proximal_pt = calculateIntersectionLineIVFile(slice_properties.centroid(condyle_end_index,:),slice_properties.centroid(condyle_end_index,:)+R_inertia_with_diaphysis(:,3)'*pt_multiplication_factor,pts_m,conn_m);

% create a crop rotation matrix with the x-axis being the vector connecting
% the proximal point to the distal point. again, the z-axis is determined
% first because it is required to point posterior and the y-axis can point
% in any direction.
R_crop_inertia_=eye(3);
R_crop_inertia(:,1)=unit(distal_pt-proximal_pt);
R_crop_inertia(:,3)=unit(cross(R_crop_inertia(:,1),R_inertia_with_diaphysis(:,2)));
R_crop_inertia(:,2)=unit(cross(R_crop_inertia(:,3),R_crop_inertia(:,1)));
RT_crop_inertia_proximal_pt = [R_crop_inertia; proximal_pt];

% transform ct pts into proximal point coordinate system to perform first condyle crop
pts_proximal_inertia = transformShell(pts_m,RT_crop_inertia_proximal_pt,-1,1);

%% 1st condyles crop based on inertial RT at proximal point
condyles_inertia_indices = pts_proximal_inertia(:,3)>0;  % indices of all condyle points
pts_condyles_inertia = pts_m(condyles_inertia_indices,:); % find all condyle points
translation_inertia = ones(length(pts_m),1);
translation_inertia(:) = -1;

translation_inertia(condyles_inertia_indices,:) = 1:length(pts_condyles_inertia);

conn_num_condyles_inertia = size(conn_m,1);
conn_condyles_inertia = zeros(size(conn_m,1),4);

numNewConn_inertia=0;
for i=1:conn_num_condyles_inertia,
    if (translation_inertia(conn_m(i,1))~=-1 && translation_inertia(conn_m(i,2))~=-1 && translation_inertia(conn_m(i,3))~=-1),
        numNewConn_inertia = numNewConn_inertia+1;
        conn_condyles_inertia(numNewConn_inertia,:) = [translation_inertia(conn_m(i,1)) translation_inertia(conn_m(i,2)) translation_inertia(conn_m(i,3)) -1];
    end    
end;
conn_condyles_inertia(conn_condyles_inertia(:,1)==0,:)=[];

%% cylinder fit to 1st condyles crop
% determine condyle bounding box dims
dim(1)=max(pts_condyles_inertia(:,1))-min(pts_condyles_inertia(:,1));
dim(2)=max(pts_condyles_inertia(:,2))-min(pts_condyles_inertia(:,2));
dim(3)=max(pts_condyles_inertia(:,3))-min(pts_condyles_inertia(:,3));
% determine index's for dims
dim_max=find(dim==max(dim));
dim_mid=find(dim==median(dim));
dim_min=find(dim==min(dim));
% determine index of pts_condyles that refer to the most medial pt and most lateral pt
a0pt1_=find(pts_condyles_inertia(:,dim_max)==max(pts_condyles_inertia(:,dim_max)));
a0pt2_=find(pts_condyles_inertia(:,dim_max)==min(pts_condyles_inertia(:,dim_max)));

x0 = mean(pts_condyles_inertia)'; % estimate pt on axis
a0 = unit(pts_condyles_inertia(a0pt2_,:)-pts_condyles_inertia(a0pt1_,:))'; % estimate axis direction
r0 = (((max(pts_condyles_inertia(:,dim_mid))-min(pts_condyles_inertia(:,dim_mid)))/2)+((max(pts_condyles_inertia(:,dim_min))-min(pts_condyles_inertia(:,dim_min)))/2))/2; % estimate radius
tolp = 0.1;
tolg = 0.1;

% cylinder fit
[x0n, an, rn, d, sigmah, conv, Vx0n, Van, urn, GNlog,a, R0, R] = lscylinder(pts_condyles_inertia(1:sample:end,:), x0, a0, r0, tolp, tolg);

%% repeat finding the crop planes based on the axis through the cylinder fit of the original condyle cropping
% make sure both inertia medial lateral axis and cylinder medial lateral axis are pointing in the same direction
if AngleDiff(unit(an),unit(R_crop_inertia(:,2)))>90
    an=-an; % if directions are not the same negate cylinder axis
end

% create a new crop rotation matrix with the x-axis being the vector
% connecting the proximal point to the distal point. again, the z-axis is 
% determined first because it is required to point posterior and the y-axis
% can point in any direction. instead of using the inertial axis to 
% determine the z-axis, the vector through the cylinder fit is used.
R_crop_cylinder=eye(3);
R_crop_cylinder(:,1)=unit(distal_pt-proximal_pt);
R_crop_cylinder(:,3)=unit(cross(R_crop_cylinder(:,1),an));
R_crop_cylinder(:,2)=unit(cross(R_crop_cylinder(:,3),R_crop_cylinder(:,1)));
RT_crop_cylinder_proximal_pt = [R_crop_cylinder; proximal_pt];

% transform ct pts into proximal point coordinate system to perform second condyle crop
pts_proximal_cylinder = transformShell(pts_m,RT_crop_cylinder_proximal_pt,-1,1);

%% 2nd condyles crop based on cylinder fit or original condyles crop
condyles_cylinder_indices = pts_proximal_cylinder(:,3)>0;  % indices of all condyle points
pts_condyles_cylinder = pts_m(condyles_cylinder_indices,:); % find all condyle points
translation_cylinder = ones(length(pts_m),1);
translation_cylinder(:) = -1;

translation_cylinder(condyles_cylinder_indices,:) = 1:length(pts_condyles_cylinder);

conn_num_condyles_cylinder = size(conn_m,1);
conn_condyles_cylinder = zeros(size(conn_m,1),4);

numNewConn_cylinder=0;
for i=1:conn_num_condyles_cylinder,
    if (translation_cylinder(conn_m(i,1))~=-1 && translation_cylinder(conn_m(i,2))~=-1 && translation_cylinder(conn_m(i,3))~=-1),
        numNewConn_cylinder = numNewConn_cylinder+1;
        conn_condyles_cylinder(numNewConn_cylinder,:) = [translation_cylinder(conn_m(i,1)) translation_cylinder(conn_m(i,2)) translation_cylinder(conn_m(i,3)) -1];
    end    
end;
conn_condyles_cylinder(conn_condyles_cylinder(:,1)==0,:)=[];

% write iv file with only condyles
pts_c = pts_condyles_cylinder;
conn_c = conn_condyles_cylinder;
fc = fullfile(pname,[fm(1:length(fm)-3),'_condyles_crop.iv']);
patch2iv(pts_c,conn_c(:,1:3),fc);
