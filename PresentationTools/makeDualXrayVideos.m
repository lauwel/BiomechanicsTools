
xraydir1 = 'P:\Data\2019-01-01_PRFC\PRFC016\T0009_PRFC016_run0001_minimal\BVR\c1_71_125_c2_71_125_ss1000_250c_20190313_113142_C1S0001\';
xraydir2 = 'P:\Data\2019-01-01_PRFC\PRFC016\T0009_PRFC016_run0001_minimal\BVR\c1_71_125_c2_71_125_ss1000_250c_20190313_113142_C2S0001\';
viddir = 'C:\Users\Lauren\Documents\School\PhD\Research\New Balance\';
list_files1 = dir([xraydir1 '*tif']);
list_files2 = dir([xraydir2 '*tif']);
writerObj = VideoWriter(fullfile(viddir,'xrayvid.mp4'));
writerObj.FrameRate = 20;

open(writerObj);

for i = 60:164%[1:length(list_files1)]
 im1 = imread([xraydir1 list_files1(i).name]);
 im2 = imread([xraydir2 list_files2(i).name]);
%     im_save{i} = im(:,:,1);
    img8 = uint8([im2(1:2:end,end:-2:1,:), im1(1:2:end,1:2:end)] / 256);
%     imshow(img8)
    
writeVideo(writerObj,img8)

end
close(writerObj)


%% write a gif

xraydir1 = 'C:\Users\Lauren\Documents\School\PhD\Research\AllStudies\1B_WindlassArchSpringRunning\Graphs\AnimationPhotosforVideo\PAN1SOL001\';
viddir = 'P:\Personnel\LaurenWelte\Research\1B_Server_WindlassArchSpringRunning\Graphs\Videos\';
list_files1 = dir([xraydir1 '*jpg']);
writerObj = VideoWriter(fullfile(viddir,'SOL001_pan1_ligs.avi'));
writerObj.FrameRate = 20;
open(writerObj);
for j = 1
for i = 100:156%[1:length(list_files1)]
 im1 = imread([xraydir1 list_files1(i).name]);
%  im2 = imread([xraydir2 list_files2(i).name]);
%     im_save{i} = im(:,:,1);
    
    
writeVideo(writerObj,im1)

% end
% for i = [length(list_files1):-1:1]
%  im1 = imread([xraydir1 list_files1(i).name]);
% %  im2 = imread([xraydir2 list_files2(i).name]);
% %     im_save{i} = im(:,:,1);
%     
%     
% writeVideo(writerObj,im1)
% 
end
end
close(writerObj)
