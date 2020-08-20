function varargout = helical(T)
% [phi,n,L,s] = helical(T)
% Compute the helical axis parameters using Veldpaus and Spoor (1980)
% Use a pose matrix defined between two segments (e.g. tibia to femur).
% ---------Input variables -----------------
% T = 4x4 pose matrix - [[R- 3x3] [T- 3x1]
%                         0  0 0    1    ]
% ---------Output variables-----------------
% [phi,n,L,s] -> variable, so put phi = helical(T) if only the first
% is wanted, or [phi,n] = helical(T)... if first two are wanted etc
%
% phi   = the rotation about the helical axis
% n     = the unit vector in the direction of the helical axis
% L     = the translation along the helical axis
% s     = a point on the helical axis, referenced to the origin of the
%            reference segment (in that co-ordinate system
% Written by L. Welte, June 23/2017

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

varargout = {phi,n,L,s};


