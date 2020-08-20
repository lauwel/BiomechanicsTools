function dist = distBtwPoints3xN(p1,p2)
% distBtwPoints3xN(p1,p2)

% find the distance between two points that are 3xn or nx3

[r1 c1] = size(p1);
[r2 c2] = size(p2);
flip_flag = 0;
if (r1 ~= r2) || (c1 ~= c2)
    error('Input dimensions of points 1 and 2 do not match.')
end
if r1 == 3
    p1 = p1';
    p2 = p2';
    flip_flag = 1;
end

n = size(p1,1);
% x1 = p1(:,1); x2 = p2(:,1);
% y1 = p1(:,2); y2 = p2(:,2);
% z1 = p1(:,3); z2 = p2(:,3);

for i = 1:n
    dist(i,:) = norm(p1(i,:) - p2(i,:));
end


if flip_flag == 1
    dist = dist';
end