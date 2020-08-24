function varargout = plot3quick(pts,colour,mark_style,line_style)



[r,c] = size(pts);
% determine number of points, and assess orientation
if r == 3 % rows have 3
    if c == 3 % ambiguous case
        warning('plot3quick.m is treating input points with columns as individual points.')
        
    end
    
    npts = c;
elseif c == 3
    npts = r;

    pts = pts';

else
    error('Input point has incorrect dimensions. (Error in transformPoints) ')
    return
end

switch nargin
    case 3
    line_style = '-';
    case 2
    line_style = '-';
    mark_style = '.';
    case 1
        
    line_style = '-';
    mark_style = '.';
    colour = 'k';
end

    h = plot3(pts(1,1:npts),pts(2,1:npts),pts(3,1:npts),'color',colour,'Marker',mark_style,'Linestyle',line_style);

if nargout > 0
    varargout = {h};
end