function normm = norm3d(vec)

% get the magnitude of an array of 3d vectors
% vec is nx3 or 3xn array


[r,c] = size(vec);

if r == 3
    normm = sqrt(vec(1,:).^2 + vec(2,:).^2 + vec(3,:).^2);
elseif c == 3
    normm = sqrt(vec(:,1).^2 + vec(:,2).^2 + vec(:,3).^2);
else
    error('Input array is the wrong dimensions for norm3d.')
end



