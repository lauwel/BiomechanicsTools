

viddir = 'C:\Users\welte\Downloads\';


xray_dir =  'E:\ArchSpring_Gearing\Animation\Video_animations\arch_recoil\tib cal fixed mt1\';



colcol = [0.4 0.4 0.4];

close all;
h = figure('Position',[50,50,1500,900]);
hg(1) = axes(h,'Position',[0.1 0.55 0.45 0.35]);
hg(2) = axes(h,'Position',[0.1 0.1 0.3 0.35]);
hg(3) = axes(h,'Position',[0.55 0.1 0.3 0.35]);
him = axes(h,'Position',[0.55 0.55 0.45 0.45]);


list_files = dir([xray_dir '*.jpg']);

% get the length of the trial -> could be from frame markers
npts = length(list_files); % number of points
x_pts = linspace(0,100,npts); % plotting x points


var1 = ones(npts,1)*1.5; % variable 1
var2 = sin(x_pts+pi()); % variable 2
var3 =  cos(x_pts); % variable 3

% plot 1
% plot(hg(1),x_pts,var1,'color',colcol)
set(hg(1),'nextplot','add','Xgrid','on','ygrid','on','XTick',[0:20:100]);%,'Ycolor','none')
%%
% plot 2
plot(hg(2),x_pts,var2,'color',colcol)
set(hg(2),'nextplot','add')

% plot 3
plot(hg(3),x_pts,var3,'color',colcol)
set(hg(3),'nextplot','add')


vid_filename = 'x-ray_graph_video.avi';
% set up the video writing
writerObj = VideoWriter(fullfile(viddir,vid_filename));
writerObj.FrameRate = 10;
open(writerObj);


ct = 1; % in case you are not indexing through frames starting at 1 in the loop

% plot the initial points
h_point(1) = plot(hg(1),x_pts(ct),var1(ct),'marker','o','markerfacecolor','k','markeredgecolor','k','markersize',12);
h_point(2) = plot(hg(2),x_pts(ct),var2(ct),'marker','o','markerfacecolor',[0.8 0.2 0.2]);
h_point(3) = plot(hg(3),x_pts(ct),var3(ct),'marker','o','markerfacecolor',[0.8 0.2 0.2]);


for i = 1:npts
    
    %read in the xray image
    im = imread(fullfile(xray_dir,list_files(i).name));
    imagesc(him,rot90(rot90(im)))
    drawnow
%     colormap('gray')
    axis image
    axis off
    
    
    % set the point to a new current point
    set(h_point(1),'Xdata',x_pts(ct),'ydata',var1(ct))
    xlabel(hg(1),'% stance')
    ylabel(hg(1),'')
    set(hg(1),'xlim',[min(x_pts), max(x_pts)])
    
legend(ha(1:2),{'walk','run'})
    
    set(h_point(2),'Xdata',x_pts(ct) ,'ydata',var2(ct) )
    xlabel(hg(2),'x-value')
    ylabel(hg(2),'Sine wave displaced')
    set(hg(2),'xlim',[min(x_pts)-5, max(x_pts)+5])
    set(hg(2),'ylim',[min(var3)-5, max(var3)+5])
    
    set(h_point(3),'Xdata',x_pts(ct),'ydata',var3(ct) )
    xlabel(hg(3),'x-value')
    ylabel(hg(3),'Cosine wave')
    set(hg(3),'xlim',[min(x_pts)-5, max(x_pts)+5])
    set(hg(3),'ylim',[min(var3)-5, max(var3)+5])
    % on first iteration, make it look nice
    if ct == 1
        makeNicePlotsFunction
    end
    
    ct = ct + 1;
    drawnow
    
    
    frame = getframe(h);
    writeVideo(writerObj,frame);
    
end


close(writerObj)


