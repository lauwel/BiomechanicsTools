function [mean_data,std_data] = makeGroupedStatsDotPlot(data,group,trial,group_names,trial_names,cols,marker)

% Make a GROUPED dot plot with the mean data and std dev on the graph. Each
% group is a different colour and is plotted at each trial. 

% Outputs the mean and the standard deviation for each group.

% data      =  two dimensional set of data, datapoint corresponds to row
%               of group, data for that group is contained in the columns

% GIVE EACH ROW OF DATA A GROUP NUMBER AND TRIAL NUMBER
% group     =   numbered from 1 to n (number of groups), corresponding with same rows as data
% trial     =   numbered from 1 to n, corresponding with same rows as data

% EACH GROUP/TRIAL SHOULD CORRESPOND TO A GROUP NAME AND TRIAL NAME
% group_names     = names of the groups (1,2,3 : n) in a cell array
% trial_names = names of the groups (1,2,3 : n) in a cell array

% EACH GROUP HAS A COLOUR
% cols       = specific colours of the groups

%  marker   = marker type on the plot i.e. 'o' or 'x' or '.' etc

groupnums = sort(unique(group));
ngroups = length(groupnums);

trialnums = sort(unique(trial));
ntrials = length(trialnums);

nt = size(data,1);

figure; ha = axes; hold on;

if exist('cols','var')
    c = cols;
else
    c = get(gca,'ColorOrder');
end
if ~exist('marker','var')
    marker = 'o';
end

for i = 1:nt
        for dp = 1:size(data,2) % for each data point
            if dp == 1
                h(1,group(i)) = scatter(trial(i)-1+group(i)/(ngroups+1), data(i,dp),'markerfacecolor',c(group(i),:),'markeredgecolor',c(group(i),:),'Marker',marker);
            else
                scatter(trial(i)-1+group(i)/(ngroups+1), data(i,dp),'markerfacecolor',c(group(i),:),'markeredgecolor',c(group(i),:),'Marker',marker)
            end
        end
        
        mean_data(i) = nanmean(data(i,:));
        std_data(i) = nanstd(data(i,:));
        temp_col = c(group(i),:)-[0.07 0.07 0.07];
        if sum(temp_col < 0) > 0
            temp_col(temp_col < 0) = 0;
        end
        
        errorbar(trial(i)-1+group(i)/(ngroups+1),mean_data(i),std_data(i),'marker','square','capsize',20,'markersize',14,'color',temp_col);
        xlim([min(trial)-1 max(trial)])
%     end
end

set(ha,'Xtick',trialnums-.5)
set(ha,'Xticklabel',trial_names)
set(ha,'XtickLabelRotation',30)
legend(h(1:3),group_names)
