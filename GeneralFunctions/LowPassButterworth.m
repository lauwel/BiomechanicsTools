function x_out = LowPassButterworth(X,n,fc,fsample)
% 2022-01-06 Updated to remove the previous flipping because it causes
% ambiguous behaviour; now exclusively filters each row; Also, it now
% calls the filtfilt function once, instead of at each row
% updated 2019-03-20 to handle both dimensions of input X and then pad the
% 
% ends so that there are no end effects

% also checks for nan values 
[r,c]=size(X);
% flip_flag = 0;
npad = 15;
    
% if r < c 

        % filter along columns.
        npts = c;
        nrows = r;
% elseif c < r
% 
%         % 1 column, many rows, flip
%         X = X';
%         flip_flag = 1;
%         npts = r;
%         nrows = c;
%     
% end


f = fsample/2;
Wn = fc/f;
ftype = 'low';

% Transfer Function design
[b,a] = butter(n,Wn,ftype);    
x_out = nan(nrows,npts);
% for each row, filter it after padding the ends to account for end effects
for i = 1:nrows
    nanind = isnan(X(i,:));
    ind_nums = find(~nanind);
    nptfilt = length(ind_nums);
    
    x = X(i,ind_nums);
    n = length(x);
    t1 = [1:1:npad]/fsample;
    t = [npad+1:npad+n]/fsample;
    t2 = [npad+n+1:npad*2+n+1]/fsample;
    
  X_new(i,:) = interp1(t, x, [t1,t,t2], 'linear', 'extrap');

    
%     X_new = [(X(i,ind_nums(1:end-1)))-(X(i,ind_nums(end)))+(X(i,ind_nums(1))) , X(i,ind_nums) ,(X(i,ind_nums(2:end))-(X(i,ind_nums(1)))+(X(i,ind_nums(end))))  ]; % pad it
%     X_new =  X(i,ind_nums);

end

    x = filtfilt(b,a,X_new')';
    
    x = x(:,npad+1:npad+n);
    
    x_out(:,ind_nums) = x;
    
% end
% figure; hold on;
% plot(X(1,:)); plot(x_out(1,:),'--')

% if flip_flag == 1
%     x_out = x_out';
% end



end
