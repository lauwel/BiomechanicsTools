function T_filt = filterTransforms(T,wc,Fs,pflag)
% filter transforms using quaternion filters. Based on E. Lee's original
% version but modified to be able to select adaptive or regular filtering.
% --------Inputs ---------------
%
%

% T = trialStruct(1).Tm_mm.cal;
[r,c,nfr] = size(T);
if r ~= 4 || c ~= 4
    error('First two dimensions of T should be 4.')
elseif nfr < 4
    error('Number of frames is smaller than 4. Filtering is not recommended.')
    
    
end

if length(wc) == 1
    filter_flag = 'LowPass';
elseif length(wc) == 2
    filter_flag = 'AdaptiveLowPass';
else
    error('Variable wc has the wrong dimensions.');
end

qua = convertRotation(T,'4x4xn','quaternion'); % produces nfrx7 quaternion

switch filter_flag % choose how to filter the quaternion
    case 'LowPass'
        qua_filt = LowPassButterworth(qua(:,1:7)',4,wc,Fs)';
    case 'AdaptiveLowPass'
        qua_filt = adaptiveLowPassButterworth(qua(:,1:7)',wc,Fs,0)';
end
% FourierAnalysis(qua,Fs)
for fr = 1:nfr % convert the quaternion into a unit quaternion
    qua_filtU(fr,1:4) = unit(qua_filt(fr,1:4));
    qua_filtU(fr,5:7) = qua_filt(fr,5:7);
end

T_filt = convertRotation(qua_filtU,'quaternion','4x4xn');


if pflag == 1
    figure;
    for i = 1:7
        subplot(4,2,i)
        plot(qua(:,i),'-')
        hold on;
        plot(qua_filtU(:,i),':')
    end
end