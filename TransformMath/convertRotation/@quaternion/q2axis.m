%Q2Axis 	Convert unit-quaternion to rotation axis and angle 
%
%	[phi,n] = q2Axis(Q);
%
%	Return the rotational axis and the angle about that axis corresponding 
%	to the unit quaternion Q.
%

% Copyright James Coburn 2003

function [phi, n] = q2Axis(q);

angle = q.s;
axis = q.v;

phi = 2*acos(angle)*180/pi;
if norm(axis) ~= 0,
    n = axis/norm(axis);
else,
    n = [0,0,0];
end;
