function diff=AngleDiff(vector1,vector2)
% calculates the angular difference between vector 1 and vector 2

if size(vector1,1)~=size(vector2,1)
    vector2=vector2';
end

diff=real(acosd(dot(vector1,vector2,2)./(vnorm(vector1,2).*vnorm(vector2,2))));