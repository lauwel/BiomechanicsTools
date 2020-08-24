function col_map = makeColourMap(col,n,show_map)

% col is a column vector of the colours that are needed in the map 
% n is the number of colours needed (i.e. interpolated between)
% show_map is optional 1 to show the map, 0 to not

%  col = [[29, 94, 26]/256;...
%         1 1 1;...
%         [88, 24, 112]/256];
%     n = 80;
if nargin == 2
    show_map = 0;
end

col_map = interp1(linspace(0,1,size(col,1)),col,linspace(0,1,n));

if show_map == 1
showColorMap(col_map)
end