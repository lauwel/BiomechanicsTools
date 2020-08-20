%Log    Take the natural log of a unit quaternion
%
% q = log(q1)
%
% Calculate the natural logarithm using trigonometric functions 
%
% See also:  exp

% Copyright James Coburn 2003

function q = log(q1);

% Example C++ code to compute the log of a quaternion from libgfx1.0
% Quat log(const Quat& q)
% {
%     double scale = norm(q.vector());
%     double theta = atan2(scale, q.scalar());
% 
%     if( scale > 0.0 )  scale=theta/scale;
% 
%     return Quat(scale*q.vector(), 0.0);
%     
    
	scale = norm(q1.v);
	theta = atan2(scale,q1.s);
	if( scale > 0.0 )  
        scale=theta/scale;
    end;
        
	test = quaternion([0,scale*q1.v]);
    
    theta = acos(q1.s);

	u = q1.v/norm(q1.v);
    q = quaternion([0,theta*u]);

%ln(q) = {.5*ln(t^2+v.v),atan2(mag(v),t)*v/mag(v)}

% scalar = .5*log(q1.s^2 + dot(q1.v,q1.v));
% vector = (atan2(norm(q1.v),q1.s)*q1.v)/norm(q1.v);
% 
% q = quaternion([scalar,vector]);
