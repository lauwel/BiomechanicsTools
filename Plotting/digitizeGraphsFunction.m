function [x_new,y_new] = digitizeGraphsFunction()

% This function will allow you to digitize the points on a 2D plot from an 
% image. It provides the option to export as a .csv file, and/or as arguments 
% from this function. 
% 
% 
% Written: L.Welte 2019/11/15

% load an image

uiwait(msgbox('Please select the image of the graph you would like to digitize.','Information','modal'))

[file,path] = uigetfile('*');

img = imread([path,file]);

figure

imshow(img);
drawnow;


loc_strs = {'bottom left','bottom right','top right','top left'};

% select the four corners of the plot
for i = 1:4
    str_in = sprintf('Please select the %s corner.',loc_strs{i});
    uiwait(msgbox(str_in,'Information','modal'))
    [x_lims(i),y_lims(i)] = ginput(1);
    
end
% these are the values of the graph's corners in real values
lims_cell = inputdlg({'Input the x-axis minimum','Input the x-axis maximum','Input the y-axis minimum ','Input the y-axis maximum'},...
              'Axis Limits', [1 30],{'0','20','0','1'}); 
x_temp(1) = str2num(lims_cell{1});
x_temp(2) = str2num(lims_cell{2});
y_temp(1) = str2num(lims_cell{3});
y_temp(2) = str2num(lims_cell{4});
x_gr = [x_temp(1) x_temp(2) x_temp(2) x_temp(1)]';
y_gr = [y_temp(1) y_temp(1) y_temp(2) y_temp(2)]';

uiwait(msgbox('Please select all of the points you wish to digitize and then press [ENTER] when you are done.','Instructions','modal'))
[x,y] = ginput;

mdl1 = fitlm(x_lims,x_gr);

xval = @(x) mdl1.Coefficients{1,1} + x * mdl1.Coefficients{2,1};

mdl2 = fitlm(y_lims,y_gr);

yval = @(y) mdl2.Coefficients{1,1} + y * mdl2.Coefficients{2,1};


x_new = xval(x);
y_new = yval(y);
figure
plot(x_new,y_new,'.','Markersize',20)


answer = questdlg('Would you like to save as a .csv file?', ...
	'File save option', ...
	'Yes','No','No');

if strcmp(answer, 'Yes')
    
    [file,path] = uiputfile([path '*.csv']);
    csvwrite([path,file],[x_new,y_new])
    
end
        
    
