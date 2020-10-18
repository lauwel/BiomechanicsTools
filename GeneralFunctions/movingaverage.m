function x_ave = movingaverage(x,k)
% x is the array to be averaged
% k is the number of points to be averaged over
% works on one dimensional arrays
N = length(x);
x_ave = zeros(N,1);

k2 = floor(k/2);
for i = 1:N
    if i - k2 < 1
        x_ave(i) = nanmean(x(1:k2),2);
    elseif i + k2 > N
        x_ave(i) = nanmean(x(i:end),2);
    else
        x_ave(i) = nanmean(x(i-k2:i+k2),2);
    end
end




