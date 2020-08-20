
function w = calculateHelicalAxisAngularVelocity(TR,T,Fs,out)
% The transforms in TR and T should be CT to x-ray space of different bones
% 
% ---------Input variables -----------------
% T,TR  =    4x4xn pose matrix - [[R- 3x3] [T- 3x1]
%                         0  0 0    1    ]
%           TR is the transform of the reference bone. T is the transform of the
%           bone being investigated. n is number of frames over time
% Fs    =   is the sampling frequency in Hz
% out   =   'deg' or 'rad' Optional argument to specify output units.
%           Default to degrees
% ---------Output Variables ------------------
% w     =   Angular velocity in specified units, output in x-ray space(3 x n)
% 

if nargin < 4
   outType = 'deg';
else 
    outType = out;
end
    [phi,n,~,~] = helicalInstantaneous(TR,T); % calculate instantaneous helical axis
    
    n_xr = transformVectors(TR,n,0); % convert to xray space
    
    w_xr = phi .* n_xr * Fs; % compute angular velocity
    
    w = normaliseNaN(w_xr,2,size(w_xr,2)+1); % reinterpolate to get the number of points the same as the input value
if strcmp(outType,'rad')
    w = w*pi()/180;
end

end



function varargout = helicalInstantaneous(TR,T)
% [phi,n,L,s] = helicalInstantaneous(TR,T);

% Compute the helical axis parameters using Veldpaus and Spoor (1980) for
% the instantaneous helical axis - TR (reference) relative to T over time
%

% ---------Output variables-----------------
% [phi,n,L,s] -> variable, so put phi = helical(T) if only the first
% is wanted, or [phi,n] = helical(T)... if first two are wanted etc
%
% phi   = the rotation about the helical axis
% n     = the unit vector in the direction of the helical axis
% L     = the translation along the helical axis
% s     = a point on the helical axis in CT space
% Written by L. Welte, Dec 18/2018


for k = 1:size(T,3)-1

T_i(:,:,k) = invTranspose(TR(:,:,k)) * T(:,:,k); % Register both frames to the reference bone
T_ip1(:,:,k) = invTranspose(TR(:,:,k+1)) * T(:,:,k+1);
T_hel(:,:,k) =  T_ip1(:,:,k)*invTranspose(T_i(:,:,k)); % convert the helical axis matrix
[phi(k),n(1:3,k),L(k),s(1:3,k)] = helical(T_hel(:,:,k));


end
varargout = {phi,n,L,s};
end

function [phi,n,L,s] = helical(T)
R = T(1:3,1:3);
t = T(1:3,4);

temp = [R(3,2)-R(2,3),R(1,3)-R(3,1),R(2,1)-R(1,2)];

rot_val = 1/2 * sqrt((R(3,2)-R(2,3))^2 + (R(1,3) - R(3,1))^2 + (R(2,1)- R(1,2))^2);

phi = asind(rot_val);

if rot_val  > sqrt(2)/2
    rot_val = 1/2 * (R(1,1) + R(2,2) + R(3,3) -1);
    phi = acosd(rot_val);
end

n(1:3,1) = temp/(2*sind(phi));

L = n(1:3)'*t(1:3); % translation along the normal

s = -0.5 * cross(n(1:3),cross(n(1:3),t(1:3))) + sind(phi)/(2*(1-cosd(phi))) * cross(n(1:3),t(1:3)); % radius vector of point on the axis

end

function vec_trans = transformVectors(T,vec,direction)

% input a 3xn or nx3 set of vectors and tranform it based on the transformation matrix, out
% put the same orientation transformed vector

% T is either 4x4x1, in which case all vectors will be transformed with
% that transform, OR 4x4xn, in which case it must have the same number n as
% number of vectors to transform

% optional argument direction tells whether the inverse of T is required ->
% direction = 0, no inverse
% direction = 1 or -1 , inverse

% Feb 2019 transformVector ( no s) has been replaced with this function and retired
% 2019 Feb - changed notation to handle -1 as inverse for clarity
%             - also handle when transforms line up with points - i.e.
%             T(:,:,10) corresponds with frame pts(10,:)

[r,c] = size(vec);
% [r,c] = size(pts);
flag_trans = 0;
nT = size(T,3);
% determine number of points, and assess orientation
if r == 3 % rows have 3
    if c == 3 % ambiguous case
        warning('transformVectors.m is treating input points with columns as individual vectors.')
    end
    
    n = c;
    
    if n == 1 && nT > 1 % i.e there are transforms for every point, but only one point
        n = nT;
    end
elseif c == 3
    n = r;
    vec = vec';
    flag_trans = 1;
    if n == 1 && nT > 1 % i.e there are transforms for every point, but only one point
        n = nT;
    end
else
    error('Input point has incorrect dimensions. (Error in transformVectors) ')
    return
end

if nargin == 2
    direction = 0; % set the default if only two inputs are specified
end

if ismember(direction,[-1 1])
    T = invTranspose(T);
end


vec_trans = zeros(3,n);
for i = 1:n % for each point
     if size(T,3) > 1
        Ta = T(:,:,i);
        if size(vec,2) == 1
            vec = repmat(vec,1,n);
        end
    else
        Ta = T;
    end
    vec_temp = Ta * [vec(:,i);0];
    vec_trans(1:3,i) = vec_temp(1:3);
end

if flag_trans == 1 % return the same format as was entered
    vec_trans = vec_trans';
end


end

function x_interp = normaliseNaN(x_in, dim, npts )
% x_interp = normaliseNaN(x_in, dim, npts)

% The function normaliseNaN can be used to interpolate over NaN points, as
% well as to interpolate to a set number of points.
%  -> note: NaN values at the beginning and end will be kept regardless, as
%  a percentage of the data that was originally provided in x_in.
%
% ---------------INPUTS-------------------------------------------------
% x_in              = input data - interpolates over dimension in dim
% dim               = the dimension to interpolate 1 - interpolate over all
%                   the rows; 2- interpolate over the columns
%                       -> if unspecified, over rows
% npts              = (Optional) How many points to re-sample the data
%                       over. Default is 101.
% --------------OUTPUT--------------------------------------------------
% x_interp          = Interpolated input data
%
% Created by L. Welte (Nov 2018)
% ----------------------------------------------------------------------

% Error Checking

if ~exist('dim','var') % if the dimension is not specified, take it over all rows
    dim = 1;
end

if ~exist('npts','var')
    npts = 101; % default number of points to interpolate over
end

flip_flag = 0;
[r,c,L] = size(x_in);

if L > 1
    error('The normaliseNaN function does not handle data with more than two dimensions.')
end

switch dim
    case 1
        n = r; % original number of points
        nInts = c; % number of interpolations to do
        flip_flag = 1; % we are transposing it to make it easy to work with
        x_raw = x_in';
    case 2
        n = c;
        nInts = r;
        flip_flag = 0;
        x_raw = x_in;
end

x_interp = zeros(nInts,npts);
for i = 1:nInts
    x = x_raw(i,1:n); % original data
    
    nanx = isnan(x);
    t    = linspace(0,npts-1,n); % new points to interpolate over
    
    
    x(nanx) = interp1(t(~nanx), x(~nanx), t(nanx),'spline');
    x_interp(i,1:npts) = interp1(t,x,0:npts-1,'pchip');
%     
%     figure;
%     plot(t(~nanx),x(~nanx),'x'); hold on;
%     plot(0:npts-1,x_interp,'-.')
%     legend('raw','interpolated')
    
    if nanx(1) == 1
        first_nan = find(nanx == 0);
        first_nan = first_nan(1)-1; % keep the initial nans
        perc_first = first_nan/n; % percentage of the trial that has nans at the beginning
        nan_ind = 1:floor(perc_first*npts);
        x_interp(i,nan_ind) = NaN;
    end
    if nanx(end) == 1
        last_nan = find(nanx == 0);
        last_nan = last_nan(end); % keep the last nan position
        perc_last = last_nan/n; % percentage of the trial that has nans at the beginning
        nan_ind = ceil(perc_last*npts):npts;
        x_interp(i,nan_ind) = NaN;
    end
    
      
    
end

if flip_flag == 1
    x_interp = x_interp';
end
end

function T_inv = invTranspose(T)

R = T(1:3,1:3);
R_inv = R';
v_inv = -R_inv * T(1:3,4);
T_inv = eye(4,4);

T_inv(1:3,1:3)= R_inv;
T_inv(1:3,4) = v_inv;
end


