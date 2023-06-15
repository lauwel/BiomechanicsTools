function I = kmeansSortDepth(data,num)
% sort the kmeans output such that the number appear in order of the
% columns

[Iraw,~] = kmeans(data,num);

ord = unique(Iraw,'stable');
I = NaN(length(Iraw),1);
for In = 1:num
I(Iraw == ord(In),1) = In;
end

