function Tm = RT_to_fX4(R,T)

if (nargin==1 && size(R,1)==4 && size(R,2)==3)
    Tm = [R(1,:) R(4,1);R(2,:) R(4,2);R(3,:) R(4,3); 0 0 0 1];
else
    Tm = [R(1,:) T(1);R(2,:) T(2);R(3,:) T(3); 0 0 0 1];
end
