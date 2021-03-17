function [mean_data,std_data] = makeStatsDotPlotHorizontal(group,data,names,cols,marker)

% make a dot plot with the data on the graph
% shows the mean and the standard deviation for each group

% group     =   numbered from 1 to n, corresponding with same rows as data
% data      =  two dimensional set of data, datapoint corresponds to row
%               of group, data for that group is contained in the columns
% names     = names of the groups (1,2,3 : n) in a cell array
%cols       = specific colours of the groups
%  marker   = marker type on the plot i.e. 'o' or 'x' or '.' etc
groupnums = sort(unique(group));
ngroups = length(groupnums);
% figure; ha = axes; hold on;
ha = gca; hold on;
if exist('cols','var')
    c = cols;
else
    c = get(gca,'ColorOrder');
end
if ~exist('marker','var')
    marker = 'o';
end
% plot([-0.5,ngroups+0.5],[0 0],'k--')
for i = 1:ngroups
    ind{i} = group == groupnums(i);
    for dp = 1:size(data,2) % for each data point
        scatter(data(ind{i},dp),group(ind{i}),'markerfacecolor',c(i,:),'markeredgecolor',c(i,:),'Marker',marker)
    end
    mean_data(i) = nanmean(data(ind{i},:));
    std_data(i) = nanstd(data(ind{i},:));
    temp_col = c(i,:)-[0.07 0.07 0.07];
    if sum(temp_col < 0) > 0
        temp_col(temp_col < 0) = 0;
    end
        
    errorbar(mean_data(i),groupnums(i),std_data(i),'horizontal','marker','square','markersize',14,'capsize',20,'color',temp_col);
    ylim([min(groupnums)-1 max(groupnums) + 1])
    
end
set(ha,'Ydir','reverse')
set(ha,'Ytick',groupnums)
set(ha,'Yticklabel',names)
% set(ha,'XtickLabelRotation',30)
