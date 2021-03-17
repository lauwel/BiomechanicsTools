function [mean_data,std_data] = makeGroupedStatsDotPlot(data,group,group_names,condition_names,cols,marker)

% Make a GROUPED dot plot with the mean data and std dev on the graph. Each
% group is a different colour and is plotted at one tick per condition. 

% Outputs the mean and the standard deviation for each group.

% data      =  two dimensional set of data, NXM; 
%               N is the number of observations (there may be groups within those observations)
%               M is the number of conditions

% GIVE EACH ROW OF DATA A GROUP NUMBER
% group         =   array that indicates each row's belonging to a group
% Note, each condition is automatically numbered from 1 to n, corresponding 
%     with same columns as data

% EACH GROUP/CONDITION SHOULD CORRESPOND TO A GROUP NAME AND TRIAL NAME
% group_names     = names of the groups (1,2,3 : n), strings in a cell array
% condition_names = names of the conditions (1,2,3 : n), strings in a cell array

% EACH GROUP HAS A COLOUR
% cols       = specific colours of the groups
%  marker   = marker type on the plot i.e. 'o' or 'x' or '.' etc

nObs = size(data,1); % number of observations
nCondition = size(data,2); % number of x ticks to plot at

groupnums = sort(unique(group));
ngroups = length(groupnums);

for g = 1:ngroups
    ind_g{g} = group == g; % figure out the indices of each group
end


% nt = size(data,1);

figure; ha = axes; hold on;

if exist('cols','var')
    col = cols;
else
    col = get(gca,'ColorOrder');
end
if ~exist('marker','var')
    marker = 'o';
end

for c = 1:nCondition
   
    for g = 1:ngroups
        xpos = c - 1 + (g)/(ngroups*2);
        xpos_rep = repmat(xpos, 1, sum(ind_g{g}));
        h(g,c) = scatter(xpos_rep,data(ind_g{g},c),'marker',marker);
        h(g,c).MarkerFaceColor = col(g,:);
        h(g,c).MarkerEdgeColor = col(g,:);
       
        
        mean_data(g,c) = nanmean(data(ind_g{g},c));
        std_data(g,c) = nanstd(data(ind_g{g},c));
        
        % darken the colour for the error bar
        temp_col = col(g,:)-[0.07 0.07 0.07];
        if sum(temp_col < 0) > 0
            temp_col(temp_col < 0) = 0;
        end
        
        errorbar(xpos,mean_data(g,c),std_data(g,c),'marker','square','capsize',20,'markersize',14,'color',temp_col);
      xpos_save(g,c) = xpos;
    end   
    
    
end

xvals = mean(xpos_save,1);
xlim([xvals(1)-0.5, xvals(end) + 0.5])

set(ha,'Xtick',xvals)
set(ha,'Xticklabel',condition_names)
set(ha,'XtickLabelRotation',30)
legend(h(:,1),group_names)
