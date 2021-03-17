function [phi,n,L,s] = helicalInstantaneousGapFill(TR,T,spc)


nfr = size(TR,3);

Inonan = find(~isnan(squeeze(TR(1,1,:)))); % all the filled data points

sphi = nan(1,nfr);
sL = nan(1,nfr);
sn = nan(3,nfr);
ss = nan(3,nfr);

ind = Inonan(1:spc:end);
if spc == nfr
    error('Frame gap is too large in helicalInstantaneousGapFill')
end
ind_rep =  floor(ind(1)+spc/2:spc:ind(end)-spc/2);
% ind_int = 1+spc/2:nfr+spc/2;
[sphi(ind_rep),sn(:,ind_rep),sL(ind_rep),ss(:,ind_rep)] = helicalInstantaneous(TR(:,:,ind),T(:,:,ind));
sphi = sphi/spc;
sL = sL/spc;

% fix the end_points - measure actual phi and L between frames but stick sn
% and ss as the first frame measured
ind_beg = ceil(ind(1):ind(1)+spc/2);
[sphi(ind_beg(1:end-1)),sn(:,ind_beg(1:end-1)),sL(ind_beg(1:end-1)),ss(:,ind_beg(1:end-1))] = helicalInstantaneous(TR(:,:,ind_beg),T(:,:,ind_beg));

sn(:,ind_beg(1:end-1)) = repmat(sn(:,ind_rep(1)),1,floor(spc/2));
ss(:,ind_beg(1:end-1)) = repmat(ss(:,ind_rep(1)),1,floor(spc/2));


ind_end = ceil(ind(end)-spc/2:(Inonan(end)));
[sphi(ind_end(1:end-1)),sn(:,ind_end(1:end-1)),sL(ind_end(1:end-1)),ss(:,ind_end(1:end-1))] = helicalInstantaneous(TR(:,:,ind_end),T(:,:,ind_end));

sn(:,ind_end) = repmat(sn(:,ind_rep(end)),1,Inonan(end)-ind_rep(end));
ss(:,ind_end) = repmat(ss(:,ind_rep(end)),1,Inonan(end)-ind_rep(end));

phi = nan(1,nfr);
L = nan(1,nfr);
n = nan(3,nfr);
s = nan(3,nfr);

phi(Inonan) = interpolateNaN(sphi(Inonan),Inonan,'makima');
n(:,Inonan) = interpolateNaN(sn(:,Inonan),Inonan,'makima');
L(Inonan) = interpolateNaN(sL(Inonan),Inonan,'makima');
s(:,Inonan) = interpolateNaN(ss(:,Inonan),Inonan,'makima');


% 
% figure; plot(sn','.'); hold on;
% plot(n')
% figure; plot(ss','.'); hold on;
% plot(s')
% figure; plot(sL','.'); hold on;
% plot(L')
% figure; plot(sphi','.'); hold on;
% plot(phi')