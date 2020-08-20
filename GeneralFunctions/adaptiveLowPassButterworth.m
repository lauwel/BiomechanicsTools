function final_sig = adaptiveLowPassButterworth(X,w,Fs,pflag)
% Adaptive Butterworth filter based on Erer (2007)
% The cut-off frequency is based on the frequency content of the signal at
% a specific point. A range of cut-off frequencies is provided, and the
% filtered signal is output.
% ---------INPUT ---------------
% X     =   raw signal, filters each row of a matrix
% w     =   [w1 w2] w1 is minimum cutoff frequency, w1+w2 is the maximum
% Fs    =   sample frequency
% pflag =   [optional] plot flag = 1 for plot, 0 for no plot
% ---------OUTPUT--------------
% final_sig     =   adaptively filtered signal
% ---------------------------
% L. Welte June 2019
%
% Edit history
%
% Jan 2020
% Forced the signals separated by NaNs to be filtered separately as long as
% there are at least 5 data values. Bar graphs will show up in different
% colours to indicate how the data was divided. 


poles = 2;
X_orig = X;
maxIter = 1;
for iter = 1:maxIter
    if iter ~= 1
        X = final_sig;
    end
    nRaw = size(X,2);
    nrows = size(X,1);
    
    nan_ind = false(1,nRaw); % avoid nans
    for nr = 1:nrows
        nan_ind = isnan(X(nr,:)) | nan_ind;
    end
    if ~exist('pflag','var')
        pflag = 0;
    end
    if pflag == 1
        figure;
    end
    % find the number of signals  separated by NaNs that have more than 4
    % values
    if any(nan_ind) %there are any nan values at all
        
        start_ind = strfind(nan_ind,[ 1 0 0 0 0 0])+1;
        end_ind = strfind(nan_ind,[ 0 0 0 0 0 1])+4;
        if length(start_ind)>length(end_ind)
            end_ind(end+1) = nRaw;
        elseif length(start_ind)<length(end_ind)
            start_ind = [1,start_ind];
        end
        if isempty(start_ind)
            error('The function adaptiveLowPassButterworth found less than 5 available data points to filter.')
        end
    else
        start_ind = 1;
        end_ind = nRaw;
    end
    
    
    final_sig = X;%nan(nrows,nRaw);
    nSigs = length(start_ind); % number of signals to filter (from those separated by NaN values)
    for si = 1:nSigs
            
              ind_filt = start_ind(si):end_ind(si);
        for row = 1:nrows
%             if length(find(nan_ind==0))<5 
%                 final_sig(row,~nan_ind) = X(row,~nan_ind);
%                 warning('Not filtering row %i as there are too few values.',row)
%                 continue
%             end
            % prefilter the signal by fp (or w1+w2)
            x = LowPassButterworth(X(row,ind_filt),poles,w(1)+w(2),Fs);
            n = length(ind_filt);%size(x,2);

            % calculate the derivatives of the signal
            vel = diffn(x,2)*Fs;
            acc = abs(diffn(vel,2)*Fs);
            vel = abs(vel);
            vel_norm = (vel-min(vel))/max(vel-min(vel));
            acc_norm = (acc-min(acc))/max(acc-min(acc));
            % determine the proportion of the signal that's high frequency content
            d = vel_norm +  acc_norm;
            c = d/max(d);

            % calculate the frequency of the signal for individual points
            f = w(1) + w(2) * c;

            for fc = floor(min(f)): ceil(max(f)) % for the range of filtering velocities

                filt_sig(fc,:) = LowPassButterworth(x,poles,fc,Fs);
            end

            for fr = 1:n % go through every frame and assign the appropriate frequency
                fc = round(f(fr));
                new_sig(fr) = filt_sig(fc,fr);
            end
            

            final_sig(row,ind_filt) = LowPassButterworth(new_sig,poles,ceil(max(f)),Fs);
            filt_sig = [];
            new_sig = [];
        end
    
    % plot the results if requested
    if pflag == 1
        c = get(gca,'colororder');
        subplot(2,1,1)
        hold on;
        for row = 1:nrows
        plot(X_orig(row,:)','color',c(row,:))
        hold on;
        plot(final_sig(row,:)','-.','color',c(row,:));
        legend('original signal','filtered signal')
        end
        subplot(2,1,2); hold on; bar(ind_filt,f')
        xlabel('data point')
        ylabel('Cut off frequency (Hz)')
    end
    end
end