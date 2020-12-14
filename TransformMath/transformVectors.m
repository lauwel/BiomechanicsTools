function vec_trans = transformVectors(T,vec,direction)

% input a 3xn or nx3 set of vectors and tranform it based on the transformation matrix, out
% put the same orientation transformed vector

% T is either 4x4x1, in which case all vectors will be transformed with
% that transform, OR 4x4xn, in which case it must have the same number n as
% number of vectors to transform

% optional argument direction tells whether the inverse of T is required ->
% direction = 0, no inverse
% direction = 1 or -1 , inverse

% Feb 2019 transformVector ( no s) has been replaced with this function and retired
% 2019 Feb - changed notation to handle -1 as inverse for clarity
%             - also handle when transforms line up with points - i.e.
%             T(:,:,10) corresponds with frame pts(10,:)

[r,c] = size(vec);
% [r,c] = size(pts);
flag_trans = 0;
nT = size(T,3);
% determine number of points, and assess orientation
if r == 3 % rows have 3
    if c == 3 % ambiguous case
        warning('transformVectors.m is treating input points with columns as individual vectors.')
    end
    
    n = c;
    
    if n == 1 && nT > 1 % i.e there are transforms for every point, but only one point
        n = nT;
    end
elseif c == 3
    n = r;
    vec = vec';
    flag_trans = 1;
    if n == 1 && nT > 1 % i.e there are transforms for every point, but only one point
        n = nT;
    end
else
    error('Input point has incorrect dimensions. (Error in transformVectors) ')
    return
end

if nargin == 2
    direction = 0; % set the default if only two inputs are specified
end

if ismember(direction,[-1 1])
    for i = 1:size(T,3)
        T(:,:,i) = invTranspose(T(:,:,i));
    end
end


vec_trans = zeros(3,n);
for i = 1:n % for each point
     if size(T,3) > 1
        Ta = T(:,:,i);
        if size(vec,2) == 1
            vec = repmat(vec,1,n);
        end
    else
        Ta = T;
    end
    vec_temp = Ta * [vec(:,i);0];
    vec_trans(1:3,i) = vec_temp(1:3);
end

if flag_trans == 1 % return the same format as was entered
    vec_trans = vec_trans';
end


end


function T_inv = invTranspose(T)

R = T(1:3,1:3);
R_inv = R';
v_inv = -R_inv * T(1:3,4);
T_inv = eye(4,4);

T_inv(1:3,1:3)= R_inv;
T_inv(1:3,4) = v_inv;
end

