function w = calculateRotMatAngularVelocity(R,Fs,out)

% Calculate the angular velocity from a rotation matrix. Rotation matrix
% must represent LOCAL to GLOBAL transformation (i.e. column unit vectors 
% of the co-ordinate system)
% 
% Beware, this method becomes less valid for larger rotations. 
% At 5 deg/s, error is +- 0.006 deg/s
% At 10 deg/s, error is +- 0.05 deg/s
% At 15 deg/s, error is +- 0.17 deg/s
% At 20 deg/s, error is +- 0.40 deg/s
% Continues exponentially.
% 
% L.Welte Feb 2019. Cope's Method from Dr. Richards.
%  Edit history:
%   - 2019/06 Added option for radian output
% 
% ----------------------------Input variables ----------------------------
% 
% R         =       3x3xn rotation matrix
% 
% Fs        =       Frame rate in Hz
% 
% out       =       'deg' or 'rad' Optional argument. Default is degrees.
% 
% ----------------------------Output variables----------------------------
% 
% w         =       (3x1xn) angular velocity in global, in degrees/s
% 
% ------------------------------------------------------------------------


nfr = size(R,3);
if size(R,1) ~= 3 || size(R,2) ~= 3 
    error('The input rotation matrix is incorrectly sized. It should be 3 x 3 x n.')
elseif size(R,3) < 2
    error('The input rotation matrix needs more than one frame of data.')
end

if nargin < 3
   outType = 'deg';
else 
    outType = out;
end

dt = 1/Fs; 

% Define the derivative rotation matrix
R_dot = nan(3,3,nfr);
R_G2L = nan(3,3,nfr);
w_L = nan(3,nfr);
w = nan(3,nfr);
for i = 1:nfr
    if i == 1 % deal with start and end frames with forwards/backwards finite difference
        R_dot(:,:,i) = (R(:,:,i+1)-R(:,:,i)) / (dt);
    elseif i == nfr
        R_dot(:,:,i) = (R(:,:,i)-R(:,:,i-1)) / (dt);
    elseif i == 2% do central finite difference
        R_dot(:,:,i) = (R(:,:,i+1) - R(:,:,i-1)) / (2*dt);
    elseif i == nfr-1% do central finite difference
        R_dot(:,:,i) = (R(:,:,i+1) - R(:,:,i-1)) / (2*dt);
    else
        R_dot(:,:,i) = (-1/12 * R(:,:,i+2) +2/3 * R(:,:,i+1) - 2/3 * R(:,:,i-1)+1/12 * R(:,:,i-2)) / (dt);
    end
    R_G2L(:,:,i) = R(:,:,i)';
    w_L_full =  R_G2L(:,:,i)*R_dot(:,:,i);
% calculate omega in the local co-ordinate system
    w_L(1:3,i) = [w_L_full(3,2); w_L_full(1,3);w_L_full(2,1)];

%    calculate omega global
    
w(1:3,i) = R(:,:,i) * w_L(1:3,i);

if strcmp(outType,'deg')
    
    w(1:3,i) = w(1:3,i)*180/pi();
    
end
    
    
end


    