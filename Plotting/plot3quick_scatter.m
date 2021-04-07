function h = plot3quick_scatter(b,colour)

n = size(b,2);
if nargin == 2
    h = scatter3(b(1,1:n),b(2,1:n),b(3,1:n),colour);
else
    h = scatter3(b(1,1:n),b(2,1:n),b(3,1:n));
end
h.Marker = '.';