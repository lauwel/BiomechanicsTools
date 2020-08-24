function makeNicePlotsFunction

set(gcf,'color','w')

fig_axes = get(gcf,'children'); % if there are subplots

set(gcf,'Position',[0 0 1200 750])

for ax = 1:length(fig_axes)
    if strcmp(fig_axes(ax).Type,'axes')
% %         
%         if length(fig_axes(ax).YAxis) == 2
%             rep = 1:2;
%         else
%             rep = 1;
%         end
%         for r = rep
%             if r == 1
%                 yyaxis left;
%             else
%                 yyaxis right;
%             end
            c = get(fig_axes(ax),'ColorOrder');
            set(fig_axes(ax),'LineWidth',2)
            set(fig_axes(ax),'FontSize',20);
            set(fig_axes(ax),'Box','off');
            set(fig_axes(ax),'FontWeight','bold')
            set(fig_axes(ax),'FontName','Helvetica');
            
            fig_child = get(fig_axes(ax),'Children');
            
            for i = 1:length(fig_child)
                if strcmp(fig_child(i).Type, 'text') % text
                    set(fig_child(i),'FontSize',24);
                    set(fig_child(i),'FontWeight','bold')
                    %        set(fig_child(i),'color',)
                elseif strcmp(fig_child(i).Type, 'line') % line or marker
                    
%                     set(fig_child(i),'LineWidth',2)
                    %         if i < 4
                    %                         set(fig_child(i),'Color',c(6,:))
                    %         else
                    %
                    %         set(fig_child(i),'Color',c(1,:))
                    %         end
                    if ~strcmp(fig_child(i).Marker, 'none') % if it has a marker
                        %                     set(fig_child(i),'Marker','x')
                        set(fig_child(i),'MarkerSize',25)
                    end
                elseif strcmp(fig_child(i).Type,'scatter')
                    set(fig_child(i),'SizeData',100)
                    
                elseif strcmp(fig_child(i).Type, 'bar')
                    set(fig_child(i),'LineWidth',2)
                    %         set(fig_child(i),'BarWidth',0.8)
                elseif strcmp(fig_child(i).Type, 'errorbar')
                    set(fig_child(i),'LineWidth',2)
                elseif strcmp(fig_child(i).Type, 'quiver')
                    set(fig_child(i),'LineWidth',5)
                    set(fig_child(i),'MaxHeadSize',1)
                end
            end
        end
        
%     end
end