function [s1,s2] = closestPointsBtw2Lines(p1,p2,L1,L2)
% 
%  p1 / p2 = points on lines 1 and 2
%  L1 / L2 = vectors indicating the direction of the line
% 
%  s1/ s2 = two points (one on each line) closes to each other

% lines are of the form s1 = p1 + a * L1 where a is a scalar

% Derivation and equations from : http://geomalgorithms.com/a07-_distance.html

% Implemented 7/2019, L.Welte

w0 = p1-p2;

a = dot(L1,L1);
b = dot(L1,L2);
c = dot(L2,L2);
d = dot(L1,w0);
e = dot(L2,w0);

if (a * c - b^2) ~= 0 % lines are not parallel
    a1 = (b * e - c * d) / (a * c - b^2);
    a2 = (a * e - b * d) / (a * c - b^2);
else % lines are parallel
    a1 = 0;
    a2 = d/b;
end

s1 = p1 + a1 * L1;
s2 = p2 + a2 * L2;

aa = max(abs([a1,a2]))*1.5;

l1{1} =  p1 + aa * L1;
l1{2} =  p1 - aa * L1;
l2{1} =  p2 + aa * L2;
l2{2} =  p2 - aa * L2;

% figure;
% hold on;
% plot3([p1(1),s1(1)],[p1(2) s1(2)],[p1(3) s1(3)],'o')
% plot3([p2(1),s2(1)],[p2(2) s2(2)],[p2(3) s2(3)],'o')
% plot3([l1{1}(1),l1{2}(1)],[l1{1}(2),l1{2}(2)],[l1{1}(3),l1{2}(3)])
% plot3([l2{1}(1),l2{2}(1)],[l2{1}(2),l2{2}(2)],[l2{1}(3),l2{2}(3)])
% axis equal
% 

