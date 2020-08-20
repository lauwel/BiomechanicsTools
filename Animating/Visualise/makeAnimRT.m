function AnimRT = makeAnimRT(RT)
% bring in a normal RT matrix [[R] [T]; 0 0 0 1] and move the translation
% to where the zeros are

AnimRT(1:3,1:3) = RT(1:3,1:3);
AnimRT(4,1:3) = RT(1:3,4)';

end


