% eulerAnglesSymbolic

syms x y z
Rx = [ 1, 0,  0;...
    0, cos(x), -sin(x);...
    0, sin(x), cos(x)];
Ry = [cos(y), 0, sin(y);...
    0 ,1,0;...
    -sin(y), 0, cos(y)];
Rz = [cos(z), - sin(z), 0;...
    sin(z), cos(z), 0;...
    0 0 1];

R = Rx*Ry*Rz;
 
[                        cos(y)*cos(z),                       -cos(y)*sin(z),         sin(y)]
[ cos(x)*sin(z) + cos(z)*sin(x)*sin(y), cos(x)*cos(z) - sin(x)*sin(y)*sin(z), -cos(y)*sin(x)]
[ sin(x)*sin(z) - cos(x)*cos(z)*sin(y), cos(z)*sin(x) + cos(x)*sin(y)*sin(z),  cos(x)*cos(y)]
 
R = Rz*Ry*Rx;

[ cos(y)*cos(z), cos(z)*sin(x)*sin(y) - cos(x)*sin(z), sin(x)*sin(z) + cos(x)*cos(z)*sin(y)]
[ cos(y)*sin(z), cos(x)*cos(z) + sin(x)*sin(y)*sin(z), cos(x)*sin(y)*sin(z) - cos(z)*sin(x)]
[       -sin(y),                        cos(y)*sin(x),                        cos(x)*cos(y)]

R = Ry*Rz*Rx


[  cos(y)*cos(z), sin(x)*sin(y) - cos(x)*cos(y)*sin(z), cos(x)*sin(y) + cos(y)*sin(x)*sin(z)]
[         sin(z),                        cos(x)*cos(z),                       -cos(z)*sin(x)]
[ -cos(z)*sin(y), cos(y)*sin(x) + cos(x)*sin(y)*sin(z), cos(x)*cos(y) - sin(x)*sin(y)*sin(z)]