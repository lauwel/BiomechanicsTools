function [theta,mag] = vectorCoding(varargin)
% vectorCoding(x_init,y_init)
% vectorCoding(x_init,y_init,stdx, stdy)

% Implementing Hammill/Sparrow's vector coding method. Using two variables
% synced in time, determine the relative pahse between them 

% stdx and stdy are optional arguments to specify the standard deviation in the
% sample

x_init = varargin{1};
y_init = varargin{2};

n = length(x_init) ;
if n ~= length(y_init)
    error('Variables must have the same length. ')
end

if length(varargin) == 4
    stdx = varargin{3};
    stdy = varargin{4};

else
    stdx = nanstd(x_init);
    stdy = nanstd(y_init);
end

x = (x_init)/stdx;%nanmax(x_init);
y = (y_init)/stdy;%y_init/nanmax(y_init);
    
% x = (x_init-nanmean(x_init))/stdx;%nanmax(x_init);
% y = (y_init-nanmean(y_init))/stdy;%y_init/nanmax(y_init);
% figure;
% hold on;
% plot(x,y,'.')

for i = 2:n-1
    
    
   theta(i) = atan2d( (y(i+1) - y(i-1)), x(i+1) - x(i-1));  
   mag(i) = (y_init(i+1) - y_init(i-1))/(x_init(i+1)-x_init(i-1));
%    quiver(x(i-1),y(i-1),cosd(theta(i-1)),sind(theta(i-1)),0.2)
   
%     if theta(i-1) < 0
%         theta(i-1) = theta(i-1) + 360;
% % %     elseif theta(i-1) >= 0
% % %         theta(i-1) = theta(i-1) -180;
%     end
end
theta(1) = atan2d( (y(2) - y(1)), x(2) - x(1));
theta(n) = atan2d( (y(n) - y(n-1)), x(n) - x(n-1));%theta(n-1);
% theta(1) =(y(2) - y(1))/(x(2) - x(1));
% theta(n) = (y(n) - y(n-1))/( x(n) - x(n-1));