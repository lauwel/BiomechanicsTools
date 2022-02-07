function makeNicePlotsFunction


line_width = 2;% for plotting
axis_width = 1; % for the actual line width of the x and y axes
font_name = 'Arial';
font_size = 9;
font_weight = 'normal'; %'bold'
marker_size = 8; % note that scatter uses a different metric, so ifyou have a scatter plot, it will be 10x this value


set(gcf,'color','w')

fig_axes = get(gcf,'children'); % if there are subplots

% set(gcf,'Position',[0 0 800 400])
% set(gcf,'Position',[0 0 1100 525])
% set(gcf,'Position',[1700 -50 1000 600])
% set(gcf,'Position',[1700 -50 1000 700])
% set(gcf,'Position',[1700 -50 1094 1317])
% set(gcf,'Position',[500 500 100 100])

for ax = 1:length(fig_axes)
    if strcmp(fig_axes(ax).Type,'axes')
        
        % if there are two y axes
        if length(fig_axes(ax).YAxis) == 2
            rep = 1:2;
        else
            rep = 1;
        end
        for r = rep
            if r == 1
                if length(rep)  == 2
                    yyaxis left;
                end
            else
                yyaxis right;
            end
            c = get(fig_axes(ax),'ColorOrder');
            set(fig_axes(ax),'LineWidth',axis_width)
            set(fig_axes(ax),'FontSize',font_size);
            set(fig_axes(ax),'Box','off');
            set(fig_axes(ax),'FontWeight',font_weight)
            set(fig_axes(ax),'FontName',font_name);
            
            fig_child = get(fig_axes(ax),'Children');
            
            for i = 1:length(fig_child)
                if strcmp(fig_child(i).Type, 'text') % text
                    set(fig_child(i),'FontSize',font_size);
                    set(fig_child(i),'FontName',font_name);
                    set(fig_child(i),'FontWeight',font_weight)
                    
                elseif strcmp(fig_child(i).Type, 'line') % line or marker
                    
                    set(fig_child(i),'LineWidth',line_width)
                    %         if i < 4
                    %                         set(fig_child(i),'Color',c(6,:))
                    %         else
                    %
                    %         set(fig_child(i),'Color',c(1,:))
                    %         end
                    if ~strcmp(fig_child(i).Marker, 'none') % if it has a marker
                        %                     set(fig_child(i),'Marker','x')
                        set(fig_child(i),'MarkerSize',marker_size)
                    end
                elseif strcmp(fig_child(i).Type,'scatter')
                    set(fig_child(i),'SizeData',marker_size*10)
                    set(fig_child(i),'LineWidth',line_width)
                elseif strcmp(fig_child(i).Type, 'bar')
                    set(fig_child(i),'LineWidth',line_width)
                    %         set(fig_child(i),'BarWidth',0.8)
                elseif strcmp(fig_child(i).Type, 'errorbar')
                    set(fig_child(i),'LineWidth',line_width)
                elseif strcmp(fig_child(i).Type, 'quiver')
                    set(fig_child(i),'LineWidth',line_width)
                    set(fig_child(i),'MaxHeadSize',1)
                end
            end
        end
        
    end
end