close all;
clear
clc

vidname = 'recoil';

viddir = 'E:\ArchSpring_Gearing\Animation\Video_animations\arch_recoil\frames\';
list_files = dir(fullfile(viddir,'*jpg'));
writerObj = VideoWriter(fullfile(viddir,[vidname '.avi']));
writerObj.FrameRate = 15;
open(writerObj);
% writerObj.VideoCompressionMethod
for i = 1:length(list_files)
    
 im = imread(fullfile(viddir, list_files(i).name));
%     im_save{i} = im(:,:,1);
%     size(im)
    
writeVideo(writerObj,im)

end
close(writerObj)



%% make a combined x-ray, wrist viz video
vidname = 'run';


viddir = 'E:\Projects\ShoeLigamentSOL001B\LigamentWrapping\Videos\'; % where to save the video

viddir1 = 'E:\Projects\ShoeLigamentSOL001B\LigamentWrapping\Videos\X-ray\'; % where to find the xray ims
list_filesX = dir(fullfile(viddir1,'*tif'));

viddir2 = 'E:\Projects\ShoeLigamentSOL001B\LigamentWrapping\Videos\WristViz\'; % where to find the wrist viz anims
list_filesW = dir(fullfile(viddir2,'*jpg'));


writerObj = VideoWriter(fullfile(viddir,[vidname '.avi']));
writerObj.FrameRate = 15;
open(writerObj);
% writerObj.VideoCompressionMethod
h= figure('Position',[1700 50 2000 1200],'Color',[1 1 1]);

for i = 1:length(list_filesX)
    subplot(1,2,1)
    im1 = imread(fullfile(viddir1, list_filesX(i).name));
    low = 0;
    high = 0.3;
    
    K = imadjust(im1,[low high],[]);
    imagesc(fliplr(K))
    
    colormap('gray')
    axis image
    axis off
    
    drawnow
    subplot(1,2,2)
    im2 = imread(fullfile(viddir2, list_filesW(i).name));
    imagesc(im2)
    axis image
    axis off
    
    drawnow
    pause(0.1)
    
    
    frame = getframe(h);
    writeVideo(writerObj,frame);
%     writeVideo(writerObj,im)
    
end
close(writerObj)



