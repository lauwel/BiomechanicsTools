
function T_new = LeastSquaresPose_3dim(markers)
% markers is a 3D vector with xyz in rows 1-3, 1 column, marker number in 
% 3rd index

% use the least squares approach to determine [R] and v

% make an initial [R]
n = size(markers,3);

x_v = markers(:,:,2) - markers(:,:,1);
temp_v = markers(:,:,3) - markers(:,:,1);

y_v = cross(x_v,temp_v);
z_v = cross(x_v,y_v);

x_u = x_v/norm(x_v);
y_u = y_v/norm(y_v);
z_u = z_v/norm(z_v);

R = [x_u,y_u,z_u];
v = markers(:,:,4);
 T_init = [R,v];
 T_init(4,1:4)= [0 0 0 1];
 

% now let's determine x_i (local) and y_i (global)
for i = 1:n
    x_i(1:3,i) = markers(:,:,i);
    y_i(1:3,i) = R * x_i(1:3,i) + v ;
end

% determine the mean for the points
x_bar = 1/n * sum(x_i,2);
y_bar = 1/n * sum(y_i,2);

for i = 1:n
    x_prime(1:3,i) = x_i(1:3,i) - x_bar;
    y_prime(1:3,i) = y_i(1:3,i) - y_bar;
    
    
    prime_products(1:3,1:3,i) = y_prime(1:3,i) * x_prime(1:3,i)';
end

C = 1/n * sum(prime_products(1:3,1:3,1:n),3);

[U,~,V_T] = svd(C); % singular value decomposition

R_new = U * V_T';

if round(det(R_new)) == -1 % correction statement for reflected rot matrices
    correct_Mat = eye(3,3);
    correct_Mat(3,3) = det(U * V_T');
    R_new = U * correct_Mat * V_T';
end

v_new = y_bar - R_new * x_bar;

for i = 1:n
    %         sum_product(i) = y_prime(1:3,i)' * R_new * x_prime(1:3,i);
    %       using equation 5
    sum_product2(i) = (R_new * x_i(1:3,i) + v - y_i(1:3,i))' * (R_new * x_i(1:3,i) + v - y_i(1:3,i));
end

min_sum_squares = 1/n * sum(sum_product2);

T_new = [R_new,v_new];
T_new(4,1:4) = [0 0 0 1];

diff = T_new - T_init; % difference between initial pose and final pose
end

