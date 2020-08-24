function [mean_data,std_data] = makeStatsDotPlot(group,data,names,cols,marker)

% make a dot plot with the data on the graph
% shows the mean and the standard deviation for each group

% group     =   numbered from 1 to n, corresponding with same rows as data
% data      =  two dimensional set of data, datapoint corresponds to row
%               of group, data for that group is contained in the columns
% names     = names of the groups (1,2,3 : n) in a cell array
% cols       = specific colours of the groups
%  marker   = marker type on the plot i.e. 'o' or 'x' or '.' etc
groupnums = sort(unique(group));
ngroups = length(groupnums);
figure; ha = axes; hold on;

if exist('cols','var')
    c = cols;
else
    c = get(gca,'ColorOrder');
end
if ~exist('marker','var')
    marker = 'o';
end
plot([-0.5,ngroups+0.5],[0 0],'k--')
for i = 1:ngroups
    ind{i} = group == groupnums(i);
    for dp = 1:size(data,2) % for each data point
%         if ~ismember(dp, 1:3)
%         scatter(group(ind{i}), data(ind{i},dp),'markerfacecolor','none','markeredgecolor',c(i,:),'Marker',marker)
%         else
%                 data(ind{i},dp)
scatter(group(ind{i}), data(ind{i},dp),'markerfacecolor',c(i,:),'markeredgecolor',c(i,:),'Marker',marker)
%         end
    end
    mean_data(i) = nanmean(data(ind{i},:));
    std_data(i) = nanstd(data(ind{i},:));
    temp_col = c(i,:)-[0.07 0.07 0.07];
    if sum(temp_col < 0) > 0
        temp_col(temp_col < 0) = 0;
    end
        
    errorbar(groupnums(i),mean_data(i),std_data(i),'marker','square','capsize',20,'markersize',14,'color',temp_col);
    xlim([min(groupnums)-1 max(groupnums) + 1])
    
end

set(ha,'Xtick',groupnums)
set(ha,'Xticklabel',names)
set(ha,'XtickLabelRotation',30)
