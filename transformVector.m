function vec_trans = transformVector(T,vec,direction)

% input a 3,1 vector and tranform it based on the transformation matrix, out
% put a 3,1 transformed vector

% direction tells whether a local to global (0) or global to local (1)
% transformation is required. T must indicate a local-global matrix (i.e
% column vectors of the co-ordinate system are in the columns of the
% rotation matrix)

[r,c] = size(vec);
if (r+c) ~= 4 % i.e is not a 3x1 point
    error('Input point has incorrect dimensions. (Error in transformPoint) ')
    
elseif r == 1
    % is a row vector instead of a column vector
    vec = vec';    
end

if nargin == 2
    direction = 0; % set the default if only two inputs are specified
end

if direction == 1
    T = invTranspose(T);
end

pt_temp = T * [vec;0];
vec_trans = pt_temp(1:3);

end


function T_inv = invTranspose(T)

R = T(1:3,1:3);
R_inv = R';
v_inv = -R_inv * T(1:3,4);
T_inv = eye(4,4);

T_inv(1:3,1:3)= R_inv;
T_inv(1:3,4) = v_inv;
end

