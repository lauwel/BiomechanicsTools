 function model = createFootModel(varargin)

% create the pose matrices for Leardini's foot model
% returns the pose matrices for the heel, midfoot, metatarsals, phalanges
% model also includes the medial longitudinal arch angle (MLA) and the
% first metatarsophalangeal angle projected in the sagittal plane of the foot (F2Ps)
% Aug 18/2016 - also returns "elongation" of the plantar fascia, or the distance from CA
% to MH1 added to the distance of MH1 to IP1
% May 25/2017 - added the shank co-ordinate system with ME/LE, MM/LM; also
% fixed the MLA to be computed using the proper formula
if length(varargin) ~=1 
    try 
        marker_data = evalin('base','marker_data');
    catch
      error('Variable named ''marker_data'' is not found in the workspace.')  
    end
    
    clearvars('varargin');
else
    marker_data = varargin{1};
    clearvars('varargin')
end 
   

nframes = length(marker_data.CA_);

% CALCANEAL SEGMENT - Origin - CA_, x_cal to midpoint between CPT and CST
if isfield(marker_data,'CST') ~= 1
    display('Calcaneal ST marker is missing. Replaced with a combination of NT (xz) and calc PT (y) markers.')
    marker_data.CST = [marker_data.NT_(1,:); marker_data.CPT(2,:); marker_data.NT_(3,:)];
end
    
    
O_cal = marker_data.CA_;
CIC = (marker_data.CST + marker_data.CPT)/2;
x_cal = CIC - O_cal;
temp_cal = O_cal - marker_data.CST;

for i = 1:nframes
    
    y_cal(1:3,i) = cross(temp_cal(1:3,i),x_cal(1:3,i));
    z_cal(1:3,i) = cross(x_cal(1:3,i),y_cal(1:3,i));
    
    % normalise the vectors
    x_cal(1:3,i) = x_cal(1:3,i)/norm(x_cal(1:3,i));
    y_cal(1:3,i) = y_cal(1:3,i)/norm(y_cal(1:3,i));
    z_cal(1:3,i) = z_cal(1:3,i)/norm(z_cal(1:3,i));
    
    % make the pose matrix
    pose.cal(1:3,1:4,i) = [x_cal(1:3,i),y_cal(1:3,i),z_cal(1:3,i),O_cal(1:3,i)];
    pose.cal(4,1:4,i) = [0 0 0 1];
end

% MIDFOOT SEGMENT - origin at midpoint between nav tuberosity, lateral apex
% of cuboid tuberosity

O_mid = (marker_data.NT_ + marker_data.MB5)/2; % MB5 coincides with CT
x_mid = marker_data.MB2 - O_mid;
temp_mid = -marker_data.NT_+O_mid;
for i = 1:nframes
    y_mid(1:3,i) = cross(temp_mid(1:3,i),x_mid(1:3,i));
    z_mid(1:3,i) = cross(x_mid(1:3,i),y_mid(1:3,i));
    
    % normalise the vectors
    x_mid(1:3,i) = x_mid(1:3,i)/norm(x_mid(1:3,i));
    y_mid(1:3,i) = y_mid(1:3,i)/norm(y_mid(1:3,i));
    z_mid(1:3,i) = z_mid(1:3,i)/norm(z_mid(1:3,i));
    
    % make the pose matrix
    pose.mid(1:3,1:4,i) = [x_mid(1:3,i),y_mid(1:3,i),z_mid(1:3,i),O_mid(1:3,i)];
    pose.mid(4,1:4,i) = [0 0 0 1];
    
end

% METATARSAL SEGMENT - origin - MB2

O_met = marker_data.MB2;
plane_vec_m2 = marker_data.MH1 - O_met;
plane_vec_m1 = marker_data.MH5 - O_met;
v_proj_met = marker_data.MH2 - O_met;

for i = 1:nframes
    plane_norm_m(1:3,i) = cross(plane_vec_m1(1:3,i),plane_vec_m2(1:3,i));
    plane_norm_m(1:3,i) = plane_norm_m(1:3,i)/norm(plane_norm_m(1:3,i));
    % x axis is projection of MB2-MH2 on the plane of MB2, MH5, MH1
    x_met(1:3,i) = vecProjOn2VecPlane(v_proj_met(1:3,i),plane_norm_m(1:3,i));
    z_met(1:3,i) = cross(x_met(1:3,i),plane_norm_m(1:3,i));
    y_met(1:3,i) = cross(z_met(1:3,i),x_met(1:3,i));
    
    x_met(1:3,i) = x_met(1:3,i)/norm(x_met(1:3,i));
    y_met(1:3,i) = y_met(1:3,i)/norm(y_met(1:3,i));
    z_met(1:3,i) = z_met(1:3,i)/norm(z_met(1:3,i));
    
    % make the pose matrix
    pose.met(1:3,1:4,i) = [x_met(1:3,i),y_met(1:3,i),z_met(1:3,i),O_met(1:3,i)];
    pose.met(4,1:4,i) = [0 0 0 1];
end

% TOE SEGMENT - origin - MB2

O_toe = marker_data.MH2;
plane_vec_t2 = marker_data.IP1 - O_toe;
plane_vec_t1 = marker_data.IP4 - O_toe;
v_proj_toe   = marker_data.IP2 - O_toe;

for i = 1:nframes
    plane_norm_t(1:3,i) = cross(plane_vec_t1(1:3,i),plane_vec_t2(1:3,i));
    plane_norm_t(1:3,i) = plane_norm_t(1:3,i)/norm(plane_norm_t(1:3,i));
    
    x_toe(1:3,i) = vecProjOn2VecPlane(v_proj_toe(1:3,i),plane_norm_t(1:3,i));
    z_toe(1:3,i) = cross(x_toe(1:3,i),plane_norm_t(1:3,i));
    y_toe(1:3,i) = cross(z_toe(1:3,i),x_toe(1:3,i));
    
    x_toe(1:3,i) = x_toe(1:3,i)/norm(x_toe(1:3,i));
    y_toe(1:3,i) = y_toe(1:3,i)/norm(y_toe(1:3,i));
    z_toe(1:3,i) = z_toe(1:3,i)/norm(z_toe(1:3,i));
    
    % make the pose matrix
    pose.toe(1:3,1:4,i) = [x_toe(1:3,i),y_toe(1:3,i),z_toe(1:3,i),O_toe(1:3,i)];
    pose.toe(4,1:4,i) = [0 0 0 1];
end


% WHOLE FOOT SEGMENT + SHANK
O_foot = marker_data.CA_;
plane_vec_f2 = marker_data.MH1 - O_foot;
plane_vec_f1 = marker_data.MH5 - O_foot;
v_proj_foot = marker_data.MH2 - O_foot;


O_shank = (marker_data.MM_  + marker_data.LM_)/2;
y1_shank = (marker_data.ME_  + marker_data.LE_)/2 - O_shank;
% y1_shank = (marker_data.ME_  ) - O_shank;
z_shank = marker_data.LM_ - O_shank;



for i = 1:nframes
    plane_norm_f(1:3,i) = cross(plane_vec_f1(1:3,i),plane_vec_f2(1:3,i));
    plane_norm_f(1:3,i) = plane_norm_f(1:3,i)/norm(plane_norm_f(1:3,i));
  
    x_foot(1:3,i) = vecProjOn2VecPlane(v_proj_foot(1:3,i),plane_norm_f(1:3,i));
    z_foot(1:3,i) = cross(x_foot(1:3,i),plane_norm_f(1:3,i));
    y_foot(1:3,i) = cross(z_foot(1:3,i),x_foot(1:3,i));
    
    x_foot(1:3,i) = x_foot(1:3,i)/norm(x_foot(1:3,i));
    y_foot(1:3,i) = y_foot(1:3,i)/norm(y_foot(1:3,i));
    z_foot(1:3,i) = z_foot(1:3,i)/norm(z_foot(1:3,i));
    
    % make the pose matrix
    pose.foot(1:3,1:4,i) = [x_foot(1:3,i),y_foot(1:3,i),z_foot(1:3,i),O_foot(1:3,i)];
    pose.foot(4,1:4,i) = [0 0 0 1];
    
    % find the shank co-ordinate system
    
    x_shank(1:3,i) = cross(y1_shank(1:3,i),z_shank(1:3,i));
    y_shank(1:3,i) = cross(z_shank(1:3,i),x_shank(1:3,i));
    
    
    x_shank(1:3,i) = x_shank(1:3,i)/norm(x_shank(1:3,i));
    y_shank(1:3,i) = y_shank(1:3,i)/norm(y_shank(1:3,i));
    z_shank(1:3,i) = z_shank(1:3,i)/norm(z_shank(1:3,i));
    
    pose.shank(1:3,1:4,i) = [x_shank(1:3,i),y_shank(1:3,i),z_shank(1:3,i),O_shank(1:3,i)];
    pose.shank(4,1:4,i) = [0 0 0 1];
    
end
% figure()
% plotPointsAndCoordSys([marker_data.MH1(1:3,1),marker_data.MH5(1:3,1),marker_data.MB2(1:3,1),marker_data.MH2(1:3,1),marker_data.MB1(1:3,1)],pose.met(:,:,1),20,'b');
% plotPointsAndCoordSys([marker_data.IP1(1:3,1),marker_data.IP2(1:3,1),marker_data.IP4(1:3,1)],pose.toe(:,:,1),20,'r');
% plotPointsAndCoordSys([marker_data.MB5(1:3,1),marker_data.NT_(1:3,1)],pose.mid(:,:,1),20,'k');
% plotPointsAndCoordSys([marker_data.CA_(1:3,1),marker_data.CA2(1:3,1),marker_data.CPT(1:3,1),marker_data.CST(1:3,1),CIC(1:3,1)],pose.cal(:,:,1),20,'c');
% plotPointsAndCoordSys([],pose.foot(:,:,1),20,'c');
% % plotvector3(O_met,temp1_met(1:3,1),'m');
% % plotvector3(O_met,temp2_met(1:3,1),'r');
% % plotvector3(O_met,temp3_met(1:3,1),'p');
% % plotvector3(O_met,temp4_met(1:3,1),'g')
% % plotvector3(O_met,temp5_met(1:3,1),'k')
% axis equal


% determine the joint pose matrices
pose.MP = zeros(4,4,nframes);
pose.cal_met = zeros(4,4,nframes);
pose.shank_foot = zeros(4,4,nframes);

for i = 1:nframes
    pose.MP(:,:,i) = invTranspose(pose.met(:,:,i)) * pose.toe(:,:,i);
    pose.cal_met(:,:,i) = invTranspose(pose.cal(:,:,i)) * pose.met(:,:,i);
    pose.shank_foot(:,:,i) = invTranspose(pose.shank(:,:,i)) * pose.foot(:,:,i);
    
    % test to see if there are NaN values
    nan_test = isnan( pose.shank_foot(:,:,i) );
    nan_sum = sum(nan_test(:));
    if nan_sum > 0
        flex_ankle(i) = NaN;
        pose.shank_foot(:,:,i) = nan(4,4);
    else
%     Using a ZYX Tait Bryan sequence, determine +ankle plantarflexion (z) angle
        flex_ankle(i) = -atan2d(pose.shank_foot(3,2,i),pose.shank_foot(3,3,i));
    end
    
    % MLA angle - projection of CA-CST and CST-MH1 onto the sagittal plane
    % of the foot
    ca_cst(:,i) = marker_data.CA_(:,i)-marker_data.CST(:,i);
    mh1_cst(:,i) = marker_data.MH1(:,i)-marker_data.CST(:,i);
    
    mh1_ca(:,i) = marker_data.MH1(:,i)-marker_data.CA_(:,i); % add for reference
    
    sag_plane_foot(1:3,i) = pose.foot(1:3,3,i);%cross(pose.foot(1:3,1,i),pose.foot(1:3,2,i));
    sag_plane_foot(1:3,i) = sag_plane_foot(1:3,i)/norm(sag_plane_foot(1:3,i));
    
    ca_cst_proj(:,i) = vecProjOn2VecPlane(ca_cst(:,i),sag_plane_foot(1:3,i));
    ca_cst_proj_norm(:,i) = ca_cst_proj(:,i)/norm(ca_cst_proj(:,i));
    mh1_cst_proj(:,i) = vecProjOn2VecPlane(mh1_cst(:,i),sag_plane_foot(1:3,i));
    mh1_cst_proj_norm(:,i) = mh1_cst_proj(:,i)/norm(mh1_cst_proj(:,i));

    mh1_ca_proj(:,i) = vecProjOn2VecPlane(mh1_ca(:,i),sag_plane_foot(1:3,i));
    mh1_ca_proj(:,i) = mh1_ca_proj(:,i)-mh1_cst_proj(:,i); % projected from CA to MH1;
%     dot is proportional to cos, ensure the
%     angles are in the correct quadrant.
    dot_MLA(i) = dot(ca_cst_proj(:,i),mh1_cst_proj(:,i))/(norm(ca_cst_proj(:,i))*norm(mh1_cst_proj(:,i)));
    
        MLA(i) = acosd(dot_MLA(i));
        z1 = ca_cst_proj_norm(3,i); % get the y coordinate of calc vec
        z2 = mh1_cst_proj_norm(3,i);
        % cases where the dot product gives us an angle smaller than 180
        % but it should be larger than 180
        if z1 < 0 && z2 > 0 && z2 > -z1 
            MLA(i) = 360- MLA(i);
        elseif z1 > 0 && z2 > 0
            MLA(i) = 360 - MLA(i);
        elseif z1 > 0 && z2 <0 && z2 > -z1
            MLA(i) = 360- MLA(i);
        end
       
%    % PARAMETERS FOR MODELLING ARCH AS AN OBTUSE TRIANGLE
%    a(:,i) = norm(ca_cst_proj(:,i));
%    b(:,i) = norm(mh1_cst_proj(:,i));
%    c(:,i) = norm(ca_cst_proj(:,i)-mh1_cst_proj(:,i));
   
    % F2Ps - first met-first phal angle -> projection on sagittal plane of
    % metatarsal
    ip1_mh1(:,i) = marker_data.IP1(:,i)-marker_data.MH1(:,i);
    mh1_mb1(:,i) = marker_data.MH1(:,i)-marker_data.MB1(:,i);
    
    sag_plane_met(1:3,i) = cross(pose.met(1:3,1,i),pose.met(1:3,2,i));
    sag_plane_met(1:3,i) = sag_plane_met(1:3,i)/norm(sag_plane_met(1:3,i));
    
    ip1_mh1_proj(:,i) = vecProjOn2VecPlane(ip1_mh1(:,i),sag_plane_met(1:3,i));
    mh1_mb1_proj(:,i) = vecProjOn2VecPlane(mh1_mb1(:,i),sag_plane_met(1:3,i));
    
    F2Ps(i) = acosd(dot(mh1_mb1_proj(:,i),ip1_mh1_proj(:,i))/norm(mh1_mb1_proj(:,i))/norm(ip1_mh1_proj(:,i)));
    % determine if it's plantarflexion or dorsiflexion
    test1 = cross(mh1_mb1_proj(:,i),ip1_mh1_proj(:,i)); 
    % test if these are in the same direction
   test2 = dot(test1,z_met(1:3,i));
%    if test2 is negative, then it's plantarflexion
   if test2 < 0 
       F2Ps(i) = -F2Ps(i);
   end
   
   
   % determine the "elongation" of the plantar fascia
    elongation(i) = norm(marker_data.CA_(:,i)-marker_data.MH1(:,i))+ norm(marker_data.IP1(:,i)-marker_data.MH1(:,i));
    elong_change(i) = elongation(i) - elongation(1);
end
model.MLA = MLA;
model.F2Ps = F2Ps;
model.pose = pose;
model.elongation = elongation;
model.elong_change = elong_change;
model.marker_data = marker_data;
model.sagittal_arch.flex_ankle = flex_ankle;
model.sagittal_arch.ca_cst_proj = ca_cst_proj;
model.sagittal_arch.mh1_cst_proj = mh1_cst_proj;
model.sagittal_arch.mh1_ca_proj = mh1_ca_proj;
model.sagittal_arch.sag_plane_foot = sag_plane_foot; % adds the normal of the foot sagittal plane
end


function T_inv = invTranspose(T)

R = T(1:3,1:3);
R_inv = R';
v_inv = -R_inv * T(1:3,4);
T_inv = eye(4,4);

T_inv(1:3,1:3)= R_inv;
T_inv(1:3,4) = v_inv;
end

function plane_vec = vecProjOn2VecPlane(v_proj,plane_normal)
% find the vector projection of v_proj on a plane (based on normal of a plane)
proj_perp = dot(v_proj,plane_normal) * plane_normal; % project the vector in plane normal direction
plane_vec = v_proj - proj_perp; % proj_perp + plane_vec = v_proj as they are the two components in that plane; solve for plane_vec
end

