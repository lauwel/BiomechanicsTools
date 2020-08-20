function Tp = rotateCoordSys(T,theta,dim)

% Tp    =  rotateCoordSys(T,theta,dim) gives the rotation about the axis
% given by dim (1  - x, 2 - y, 3 -z) by theta degrees, in accordance with
% the right hand rule

switch dim
    case 1 % rotate about the x axis
        R = [ 1, 0,  0;...
             0, cosd(theta), -sind(theta);...
             0, sind(theta), cosd(theta)];
    case 2
        R = [cosd(theta), 0, sind(theta);...
            0 ,1,0;...
            -sind(theta), 0, cosd(theta)];
    case 3 
        R = [cosd(theta), - sind(theta), 0;...
            sind(theta), cosd(theta), 0;...
            0 0 1];
end

% Tp = eye(4,4);
TR = T(1:3,1:3);

Rnew = TR * R;

Tp = T;
Tp(1:3,1:3) = Rnew;



%for visual verification
% figure;
% hold on;
% plotPointsAndCoordSys1([],T,100,'r')
% 
% plotPointsAndCoordSys1([],Tp,100,'b')