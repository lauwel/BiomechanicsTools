function plotPointsAndCoordSys(markers,T,s,c)
% s is the scale of the vectors
% c is the colour of the markers

if nargin == 2
    s = 50;
    c = 'b';
elseif nargin == 3
    c = 'b';    
end
% s is a scaling factor
hold on
if isempty(markers) ~= 1
    n = size(markers,2);
    
    
    for i = 1:n
        h(i) = plot3quick(markers(:,i,:),'k','o'); % changed Feb 29, 2016 to (:,i,:) from (:,:,i) so indexing frames in second index
    end
    
    for i = 1:n
        set(h(i),'Markersize',5,'color',c)
    end
end

plotvector3(T(1:3,4),s*T(1:3,1),'r');
plotvector3(T(1:3,4),s*T(1:3,2),'g');
plotvector3(T(1:3,4),s*T(1:3,3),'b');
axis equal



