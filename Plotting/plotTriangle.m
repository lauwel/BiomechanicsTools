function varargout = plotTriangle(x,y,l,col)
% plots a triangle on the current plot
%---INPUTS--------------
% plotTriangle(x,y,col) plots a triangle with corners at
%   [x1,y1],[x2,y2],[x3,y3]
% plotTriangle(x,y,col) where x and y define the base of the triangle and
%   the apex i.e. x = [baseX,apexX] y = [baseY,apexY] makes an equilateral
%   triangle with the base and apex at those points
% h = plotTriangle(
% if output argument is specified, returns the handle



if length(x) == 3 % if the three corners are provided
    h = fill([x(1) x(2) x(3)],[y(1) y(2) y(3)],col);
elseif length(x) == 2 % if the centre of the base and the apex is provided
    base = [x(1) y(1)];
    apex = [x(2) y(2)];
    vec = apex - base;
    vec_scale = vec(2)/vec(1);
    vecu = vec/2;%/vec_scale;
%     vec90 = cross([vecu 0],[0 0 1]);
    c1 = base + l * [vecu(1)  -vecu(2)];
    c2 = base +  l * [-vecu(1) vecu(2)];
    c3 = base + l * vecu;
    
%     
%     vec_scale = vec(1)/vec(2);
%     
%     vec_length = norm(vec);
%     vecu = vec/vec_length;
%     
%     vec90 = cross([vecu 0],[0 0 1]);
%     vec90norm = vec90(1:2)/norm(vec90(1:2));
%     c1 = base + vec90(1:2).*vec/2; % corner 1
%     c2 = base - vec90(1:2).*vec/2; % corner 2
    h = fill([c1(1),c2(1),c3(1)],[c1(2),c2(2),c3(2)],col);
else
    error('Wrong dimensions provided. Please review acceptable input arguments. ')
end

varargout = {h};
% 
% figure; plot(base(1),base(2),'o')
% hold on; plot(apex(1),apex(2),'o')
% ylim([1 8])
% xlim([100 900])