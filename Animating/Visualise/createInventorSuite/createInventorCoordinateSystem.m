function ivstring =  createInventorCoordinateSystem(varargin)
%    ivstring =  createInventorCoordinateSystem(base,x,y,z,scale,width)
%    ivstring =  createInventorCoordinateSystem(T,scale,width)

if nargin == 6
    base = varargin{1};
    x = varargin{2};
    y = varargin{3};
    z = varargin{4};
    scale = varargin{5};
    width = varargin{6};
elseif nargin == 3
    T = varargin{1};
    scale = varargin{2};
    width = varargin{3};
   x = T(1:3,1);
   y = T(1:3,2);
   z = T(1:3,3);
   base = T(1:3,4);
else
    error('Wrong number of arguments to createInventorCoordinateSystem.m.')
end


ivstring = createInventorArrow(base,x,scale,width,[1 0 0],0.5);
ivstring = [ivstring createInventorArrow(base,y,scale,width,[0 1 0],0.5)];
ivstring = [ivstring createInventorArrow(base,z,scale,width,[0 0 1],0.5)];
