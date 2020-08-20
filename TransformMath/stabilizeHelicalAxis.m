function [mean_phi,mean_n,mean_L,mean_s] = stabilizeHelicalAxis(TR,T,gap,iter)


nfr = size(TR,3);
for j = 1:iter
      sphi{j}= nan(1,nfr);
      sn{j}= nan(3,nfr);
      sL{j}= nan(1,nfr);
      s{j}= nan(3,nfr);
      %      ind{j} = 1:j:nfr;

     [sphi{j}(j:end),sn{j}(:,j:end),sL{j}(j:end),s{j}(:,j:end)] = helicalInstantaneousGapFill(TR(:,:,j:end),T(:,:,j:end),gap);
        
     
     ind_plot{j} = 1+j/2:j:nfr+j/2;
end

%%%%%%%%%%%%%% phi

% figure;hold on;
for j = 1:iter
% plot(sphi{j}','.')
end

new_phi = nan(iter,nfr);
for j = 1:iter
    new_phi(j,:) = sphi{j};
end

median_phi = nanmedian(new_phi);
mean_phi = movingaverage(median_phi,gap);

std_phi = nanstd(new_phi);
% plot(mean_phi);
% PrettyStdDevGraphs(1:nfr,mean_phi,std_phi,[0 0 0],1)
% title('phi')
%%%%%%%%%%%%%%%%%%%% n
% figure; hold on;


for i = 1:3
    
    
    new_n{i} = nan(iter,nfr);
    for j = 1:iter
        new_n{i}(j,:) = sn{j}(i,:);
        
        
%         hold on;
%         plot(sn{j}(i,:),'.'); 
    end
    
    median_n(i,:) = nanmedian(new_n{i});
    mean_n(i,:) = movingaverage(median_n(i,:),gap);
    
    std_n(i,:) = nanstd(new_n{i});
    
%     plot(mean_n(i,:),'k');
end

% title('n')


%%%%%%%%%%%%%% L 

% figure; 
new_L = nan(iter,nfr);
for j = 1:iter
    new_L(j,:) = sL{j};
%         hold on;
%         plot(sL{j},'.'); 
end

median_L = nanmedian(new_L);
mean_L = movingaverage(median_L,gap);
std_L = nanstd(new_L);
% plot(mean_L,'k')
% PrettyStdDevGraphs(1:nfr,mean_L,std_L,[0 0 0],1)


% title('L')s
%%%%%%%%%%%%%%%%%%%% s

% figure; hold on;


for i = 1:3
    
    
    new_s{i} = nan(iter,nfr);
    for j = 1:iter
        new_s{i}(j,:) = s{j}(i,:);
        
        
        hold on;
%         plot(s{j}(i,:),'.'); 
    end
    
    median_s(i,:) = nanmedian(new_s{i});
    mean_s(i,:) = movingaverage(median_s(i,:),gap);
    
    std_s(i,:) = nanstd(new_s{i});
%     plot(mean_s(i,:),'k')
    
    
end

% title('s')

% figure; hold on;
% for i = 1:3
% 
%     
% new_s = nan(iter,nfr);
% for j = 1:iter
%     new_s(j,floor(ind_plot{j})) = s{j}(i,:);
% end
% 
% mean_s(i,:) = nanmean(new_s);
% std_s = nanstd(new_s);
% 
% PrettyStdDevGraphs(1:nfr,mean_s(i,:),std_s,[0 0 0],1);hold on
% end
%     
%     hold on;
% for j = 1:iter-1
%     plot(ind_plot{j},s{j}','k.')
% end
% title('s')