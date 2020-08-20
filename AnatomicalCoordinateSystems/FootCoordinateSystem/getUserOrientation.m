function [Tout,pts_new] = getUserOrientation(tplt_pts,pts)

% tplt_pts = tpltBoneStruct.(bonesCell{b}).pts;


for i = 1%:3
    if i == 1
        T90 = rotateCoordSys(eye(4),90,3);
        
        pts0 = pts;
        pts90 = transformPoints(T90,pts);
        pts180 = transformPoints(T90*T90,pts);
        pts270 = transformPoints(T90*T90*T90,pts);
    elseif i == 2
        
        T90 = rotateCoordSys(eye(4),90,2);
    elseif i == 3
        T90 = rotateCoordSys(eye(4),90,1);
    end
    
    if i ~=1
        switch answer
            case 1
%                 pts0 = pts0;
                pts90 = transformPoints(T90,pts0);
                pts180 = transformPoints(T90*T90,pts0);
                pts270 = transformPoints(T90*T90*T90,pts0);
            case 2
                pts0 = pts90;
                pts90 = transformPoints(T90,pts0);
                pts180 = transformPoints(T90*T90,pts0);
                pts270 = transformPoints(T90*T90*T90,pts0);
                
            case 3
                
                pts0 = pts180;
                pts90 = transformPoints(T90,pts0);
                pts180 = transformPoints(T90*T90,pts0);
                pts270 = transformPoints(T90*T90*T90,pts0);
            case 4
                
                pts0 = pts270;
                pts90 = transformPoints(T90,pts0);
                pts180 = transformPoints(T90*T90,pts0);
                pts270 = transformPoints(T90*T90*T90,pts0);
        end
    end
    


    hf = figure;
    hf.Units = 'normalized';
    hf.Position(1:2) = [0.1 0.1];
        
    ha = axes(hf,'Position',[0.35 0.65 0.3 0.3]);
    h = plot3(ha,tplt_pts(1:5:end,1),tplt_pts(1:5:end,2),tplt_pts(1:5:end,3),'b');
    h.Marker = '.';
    h.LineStyle = 'none';
%     h.
    axis equal
    view([-90 0])
    axis off
        
    x1 = 0.2;
    y1 = 0.05;
    x2 = 0.55;
    y2 = 0.35;
    ht = 0.25;
    wt = 0.25;
    
    ha = axes(hf,'Position',[x1 y2 ht wt]);
    h = plot3(ha,pts0(:,1),pts0(:,2),pts0(:,3),'.r');
    axis equal
    view([-90 0])
      axis off
      
    ha = axes(hf,'Position',[x2 y2 ht wt]);
    h = plot3(ha,pts90(:,1),pts90(:,2),pts90(:,3),'.r');
    axis equal
    view([-90 0])
    axis off

    ha = axes(hf,'Position',[x1 y1 ht wt]);
    h = plot3(ha,pts180(:,1),pts180(:,2),pts180(:,3),'.r');
    axis equal
    view([-90 0])
      axis off
      
    ha = axes(hf,'Position',[x2 y1 ht wt]);
    h = plot3(ha,pts270(:,1),pts270(:,2),pts270(:,3),'.r');
    axis equal
    view([-90 0])
    axis off
    
    ha = axes(hf,'Position',[x1-0.05 y2+ht 0.05 0.05]);
    text(0,0,'A')
     axis off   
     
     ha = axes(hf,'Position',[x2-0.05 y2+ht 0.05 0.05]);
    text(0,0,'B')
     axis off
    
     ha = axes(hf,'Position',[x1-0.05 y1+ht 0.05 0.05]);
    text(0,0,'C')
     axis off
    
    ha = axes(hf,'Position',[x2-0.05 y1+ht 0.05 0.05]);
    text(0,0,'D')
     axis off
 
     
   answer = listdlg('PromptString','Which view is the most similarly oriented?',...
   'SelectionMode','single','ListSize',[220 100],'ListString',{'A','B','C','D'});  
   close(hf)
   if isempty(answer)
       return
   end
   if i == 1
    Tout = T90^(answer-1);
   elseif i == 2
       Tout = Tout*(T90^(answer-1));
   elseif i == 3
       Tout = Tout * (T90^(answer-1));
   end    
end

pts_new = transformPoints(Tout,pts);
% 
% figure;
% hold on;
% plot3(tplt_pts(1:5:end,1),tplt_pts(1:5:end,2),tplt_pts(1:5:end,3),'b');
% plot3(pts_new(:,1),pts_new(:,2),pts_new(:,3),'.r');
%      axis equal