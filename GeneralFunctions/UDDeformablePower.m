function [P_UD,w_UD,v_cm_UD] = UDDeformablePower(T_UD,cm_UD,F_GRF,M_free,cop,Fs )

% T_UD is the transform of the UD segment from CT to capture space
% cm_UD is the centroid of the UD segment in CT space
% F_GRF is the ground reaction force in capture space
% M_free is free moment in capture space
% cop is the centre of pressure in capture space
%Fs is the sample rate in Hz

% Each COLUMN is a FRAME


% number of frames
nfr = size(T_UD,3);
% position, velocity and angular velocity of the UD segment
p_cm_UD = transformPoints(T_UD,cm_UD);
v_cm_UD = calculateVelocity( p_cm_UD, Fs);
w_UD = calculateRotMatAngularVelocity( T_UD(1:3,1:3,:),Fs,'rad');

% position of the centre of mass of the UD segment relative to the centre
% of pressure
r_UD_cop = p_cm_UD - cop;


% for each frame, calculate the power
v_UD_d = [];
P_UD = [];
for fr = 1:nfr
    v_UD_d(:,fr) = v_cm_UD(:,fr) + cross(w_UD(:,fr),r_UD_cop(:,fr));
    
    P_UD(fr) = dot(F_GRF(:,fr),v_UD_d(:,fr)) + dot(M_free(:,fr),w_UD(:,fr));
    
end



%      x_vals = linspace(0,100,nfr);
% figure(1); hold on; plot(x_vals,norm3d(v_cm_UD)','Color',p.col,'marker',p.marker_type,'linestyle',p.line,'MarkerFaceColor',p.marker_fill); ylabel('COM vel (m/s)')
% 
% figure(2); hold on; plot(x_vals,p_cm_UD','Color',p.col,'marker',p.marker_type,'linestyle',p.line,'MarkerFaceColor',p.marker_fill); ylabel('COM pos (m)')
% figure(3); hold on; plot(x_vals,norm3d(w_UD)','Color',p.col,'marker',p.marker_type,'linestyle',p.line,'MarkerFaceColor',p.marker_fill); ylabel('UD ang vel (rad/s)')
% figure(4); hold on; plot(x_vals,F_GRF'/(demo.weight(s_ind)*9.81),'Color',p.col,'marker',p.marker_type,'linestyle',p.line,'MarkerFaceColor',p.marker_fill); ylabel('Force [N]')
