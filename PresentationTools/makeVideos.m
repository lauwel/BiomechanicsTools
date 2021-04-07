close all;
clear
clc

vidname = 'tal cal';

viddir = 'E:\ShapeModelling\Videos\Talus calc\';
list_files = dir(fullfile(viddir,'*jpg'));
writerObj = VideoWriter(fullfile(viddir,[vidname '.avi']));
writerObj.FrameRate = 10;
open(writerObj);
% writerObj.VideoCompressionMethod
for i = 1:length(list_files)
    
 im = imread(fullfile(viddir, list_files(i).name));
%     im_save{i} = im(:,:,1);
%     size(im)
    
writeVideo(writerObj,im)

end
close(writerObj)


