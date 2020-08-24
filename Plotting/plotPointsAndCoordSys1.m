function plotPointsAndCoordSys1(markers,T,s,c)
% s is the scale of the vectors
% c is the colour of the markers

if nargin == 2
    s = 50;
    c = 'b';
elseif nargin == 3
    c = 'b';    
end

hold on
if isempty(markers) ~= 1
    n = size(markers,3);
    for i = 1:n
        h(i) = plot3quick(markers(1:3,:,i),'k','o'); 
    end
    
    for i = 1:n
        set(h(i),'Markersize',5,'color',c)
    end
end

plotvector3(T(1:3,4),s*T(1:3,1),'r');
plotvector3(T(1:3,4),s*T(1:3,2),'g');
plotvector3(T(1:3,4),s*T(1:3,3),'b');
axis equal
hold off