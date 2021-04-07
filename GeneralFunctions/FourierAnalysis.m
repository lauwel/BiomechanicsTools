function FourierAnalysis(X, Fs)



ind_nan = isnan(X);
if sum(ind_nan) > 0
    warning('NaNs are being ignored. If there are NaNs within the data set (and not just on endpoints), this could affect the results.')
end
Y = fft(X(~ind_nan));


L = length(Y);


P2 = abs(Y/L);
P1 = P2(1:round(L/2)+1);
P1(2:end-1) = 2*P1(2:end-1);

f = Fs*(0:round(L/2))/L;
bar(f,P1)
title('Single-Sided Amplitude Spectrum of X(t)')
xlabel('f (Hz)')
ylabel('|P1(f)|')


sumP1 = sum(P1);
temp = 0;
for ii = 1: length(P1)
    temp = temp+P1(ii);
   P1_cum(ii) = temp; 
    
end
yyaxis right; hold on; plot(f,P1_cum/sumP1);
ylabel('% of cumulative signal content')

i60 = find(P1_cum/sumP1 > 0.6,1);
i80 = find(P1_cum/sumP1 > 0.8,1);
i90 = find(P1_cum/sumP1 > 0.9,1);
fprintf('60%% of signal is captured at %0.0f Hz, 80%% of signal is captured at %0.0f Hz, 90%% of the signal is captured at %0.0f Hz \n',f(i60),f(i80),f(i90)  )