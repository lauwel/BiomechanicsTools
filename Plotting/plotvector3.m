function varargout = plotvector3(o,a,colour)
% a is a 1x3 or 3x1 array specifying the vector to be plotted
% o is the origin

[r,c] = size(o);

if r == 3;
    
    if c==3;
        warning('Ambiguous case (origin vector is 3x3), treating vectors as if they are in columns.')
    end
elseif c == 3;
    o = o';
    a = a';
end
if size(o,1) ~= size(a,1)
error('Input dimensions to plotvector3 do not match')
end

if nargin == 3
    h = quiver3(o(1,:),o(2,:),o(3,:),a(1,:),a(2,:),a(3,:),'Color',colour);
else
    h = quiver3(o(1,:),o(2,:),o(3,:),a(1,:),a(2,:),a(3,:));
end
if nargout > 0
    varargout = {h};
end