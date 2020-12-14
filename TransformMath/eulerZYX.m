function [x_ang,y_ang,z_ang] = eulerZYX(T_R,T_A,T_R_ACS,T_A_ACS)

% Calculate the euler angles using a YZX sequence
% Input transforms (4x4xnframes). ACS is 4x4x1
% R is reference, A is bone in question. Euler angles demonstrate the
% anatomical co-ordinate system of bone A relative to bone R over time.

[~,~,nfr] = size(T_R);

for fr = 1:nfr
    
    T_A_i_acs = T_A(:,:,fr) * T_A_ACS;
    T_R_i_acs = T_R(:,:,fr) * T_R_ACS;
    
    T_eul = invTranspose(T_R_i_acs) * T_A_i_acs;
    
    
    y_ang(fr) = -asind(T_eul(3,1));
    x_ang(fr) = atan2d(T_eul(3,2),T_eul(3,3));
    z_ang(fr) = atan2d(T_eul(2,1),T_eul(1,1));
    
    
end
