function varargout = helicalInstantaneous(TR,T)
% function varargout = helicalInstantaneous(TR,T)
% [phi,n,L,s] = helicalInstantaneous(TR,T);

% Compute the helical axis parameters using Veldpaus and Spoor (1980) for
% the instantaneous helical axis - TR (reference) relative to T over time
%
% The transforms in TR and T should be CT to x-ray space of different bones
% ---------Input variables -----------------
% T,TR = 4x4xn pose matrix - [[R- 3x3] [T- 3x1]
%                         0  0 0    1    ]
% ---------Output variables-----------------
% [phi,n,L,s] -> variable, so put phi = helical(T) if only the first
% is wanted, or [phi,n] = helical(T)... if first two are wanted etc
%
% phi   = the rotation about the helical axis
% n     = the unit vector in the direction of the helical axis
% L     = the translation along the helical axis
% s     = a point on the helical axis in CT space
% Written by L. Welte, Dec 18/2018


for k = 1:size(T,3)-1

T_i(:,:,k) = invTranspose(TR(:,:,k)) * T(:,:,k); % Register both frames to the reference bone
T_ip1(:,:,k) = invTranspose(TR(:,:,k+1)) * T(:,:,k+1);
T_hel(:,:,k) =  T_ip1(:,:,k)*invTranspose(T_i(:,:,k)); % convert the helical axis matrix
[phi(k),n(1:3,k),L(k),s(1:3,k)] = helical(T_hel(:,:,k));


end
varargout = {phi,n,L,s};
end

function [phi,n,L,s] = helical(T)
R = T(1:3,1:3);
t = T(1:3,4);

temp = [R(3,2)-R(2,3),R(1,3)-R(3,1),R(2,1)-R(1,2)];

rot_val = 1/2 * sqrt((R(3,2)-R(2,3))^2 + (R(1,3) - R(3,1))^2 + (R(2,1)- R(1,2))^2);

phi = asind(rot_val);

if rot_val  > sqrt(2)/2
    rot_val = 1/2 * (R(1,1) + R(2,2) + R(3,3) -1);
    phi = acosd(rot_val);
end

n(1:3,1) = temp/(2*sind(phi));

L = n(1:3)'*t(1:3); % translation along the normal

s = -0.5 * cross(n(1:3),cross(n(1:3),t(1:3))) + sind(phi)/(2*(1-cosd(phi))) * cross(n(1:3),t(1:3)); % radius vector of point on the axis

end

function T_inv = invTranspose(T)

R = T(1:3,1:3);
R_inv = R';
v_inv = -R_inv * T(1:3,4);
T_inv = eye(4,4);

T_inv(1:3,1:3)= R_inv;
T_inv(1:3,4) = v_inv;
end


