function x_dot = diffn(x,dim)
% L. Welte 2019 Feb
% compute the difference between values but maintain the same number of
% points by reinterpolating
n = length(x);
xdiff = diff(x,1,dim);
x_dot = normaliseNaN(xdiff,dim,n);
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