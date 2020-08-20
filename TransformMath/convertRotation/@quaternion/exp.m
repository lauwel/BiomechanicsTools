function q = exp(q1),

% exp(q) = (exp(t)*cos(mag(v)),exp(t)*(sin(mag(v))*v)/mag(v))
%
% scalar = exp(q1.s)*cos(norm(q1.v));
% vec = exp(q1.s)*(sin(norm(q1.v))*q1.v);%/norm(q1.v);
% 
% q = unit(quaternion([scalar,vec]));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example C++ code to compute the log of a quaternion from libgfx1.0
% Quat exp(const Quat& q)
% {
%     double theta = norm(q.vector());
%     double c = cos(theta);
% 
%     if( theta > FEQ_EPS )
%     {
% 	double s = sin(theta) / theta;
% 	return Quat( s*q.vector(), c);
%     }
%     else
% 	return Quat(q.vector(), c);
% }

theta = norm(q1.v);
c = cos(theta);
if(theta > .000001),
    s = sin(theta)/theta;
    q = quaternion([c,s*q1.v]);
else,
   q = quaternion([c,q1.v]);
end;