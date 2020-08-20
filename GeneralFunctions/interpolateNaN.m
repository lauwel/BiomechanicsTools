function x_interp = interpolateNaN(x,t,method)
% Interpolates over NaNs along the columns for various rows.
% Does not interpolate NaNs at the beginning or ends of data.
% method : any interpolation methods given in interp1 'spline' is default.

if ~exist('method','var')
    method = 'spline';
end


[nrows,npts] = size(x);
if isempty(t)
    t    = linspace(0,npts-1,npts); % new points to interpolate over
end


x_interp = nan(nrows,npts);
for r = 1:nrows
    x_temp = x(r,:);
    
    nanx = isnan(x_temp);
    if nanx(1) == 1
        ind = find(nanx == 0);
        nanx(1:ind(1)) = 0;
    end
    if nanx(end) == 1
        ind = find(nanx == 0);
        nanx(ind(end):end) = 0;
    end
    
    
    x_temp(nanx) = interp1(t(~nanx), x_temp(~nanx), t(nanx),method);
%     x_interp(r,1:npts) = interp1(t,x_temp,t,'pchip');
    x_interp(r,:) = x_temp;
    
end
