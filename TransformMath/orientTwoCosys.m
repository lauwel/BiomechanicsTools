
function T_rot = orientTwoCosys(T_ref,T_new)
%orient the co-ordinate systems such that they have the same orientation
% T_ref is the co-ordinate system to be similar to
% T_new is the co-oridnate system to re-orient
% T_rot is the new rotated co-ordinate system
%
% Written lazily by L. Welte 04/2020
% 
% T_ref = [ 0.9429    0.1529    0.2958  139.7546;...
%     -0.1861    0.9786    0.0875  188.9633;...
%     -0.2761   -0.1375    0.9512  -17.4647;...
%     0         0         0    1.0000];
% 
% 
% T_new =  [-0.4835    0.8081    0.3364  136.3024;...
%     -0.0737   -0.4205    0.9043  186.7500;...
%     0.8722    0.4124    0.2629  -26.6885;...
%     0         0         0    1.0000];

% find the axis that most closely aligns with the X by rotating it around
% the Y and the Z

dot_save = [];
thetas = 0:90:270;

for di = 2:3 % for y and z
    
    for th =  1:4% for each axis
        
        T_temp = rotateCoordSys(T_new,thetas(th),di);
        dot_save(di,th) = dot(T_temp(1:3,1),T_ref(1:3,1));
    end
end
[ax_rot,th_ind] = max(dot_save,[],2);
[~,ax_num] = max(ax_rot);


T_rot1 = rotateCoordSys(T_new,thetas(th_ind(ax_num)),ax_num);
% 
% figure; hold on;
% plotPointsAndCoordSys(T_ref(1:3,4),T_ref,'k')
% % plotPointsAndCoordSys(T_new(1:3,4),T_new,'r')
% plotPointsAndCoordSys(T_temp(1:3,4),T_temp,'m')

dot_save = [];

% for di = 2 % for y and z
for th =  1:4% for each axis
    T_temp = rotateCoordSys(T_rot1,thetas(th),1);
    dot_save(2,th) = dot(T_temp(1:3,2),T_ref(1:3,2));
% end
end
[ax_rot,th_ind] = max(dot_save,[],2);
[~,ax_num] = max(ax_rot);

T_rot = T_new;
T_temp = rotateCoordSys(T_rot1,thetas(th_ind(ax_num)),1);
T_rot(1:3,1:3) = T_temp(1:3,1:3);
% %
% figure; hold on;
% plotPointsAndCoordSys(T_ref(1:3,4),T_ref,'k')
% % plotPointsAndCoordSys(T_new(1:3,4),T_new,'r')
% plotPointsAndCoordSys(T_rot(1:3,4),T_rot,'m')
