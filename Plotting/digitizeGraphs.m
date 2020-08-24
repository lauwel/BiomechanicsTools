
close all
clear
clc

%% Dorsiflexion graph 
% load an image

uiwait(msgbox('Please select the image of the graph you would like to digitize.','Information','modal'))

[file,path] = uigetfile();

img = imread([file,path]);

figure

imshow(img);
drawnow;


loc_strs = {'bottom left','bottom right','top right','top left'};

% select the four corners of the plot
for i = 1:4
    str_in = sprintf('Please select the %s corner.',loc_strs{i});
    uiwait(msgbox(str_in,'Information','modal'))
    [x_lims(i),y_lims(i)] = ginput(i);
    
end
% these are the values of the graph's corners in real values
lims_cell = inputdlg({'Input the x-axis minimum','Input the x-axis maximum','Input the y-axis minimum ','Input the y-axis maximum'},...
              'Axis Limits', [1 30],{'0','20','0','1'}); 
x_temp = str2num(lims_cell{1},lims_cell{2})
x_gr = [0 100 100 0]';
y_gr = [0 0 100 100]';
[x y] = ginput;

mdl1 = fitlm(x_lims,x_gr);

xval = @(x) mdl1.Coefficients{1,1} + x * mdl1.Coefficients{2,1};

mdl2 = fitlm(y_lims,y_gr);

yval = @(y) mdl2.Coefficients{1,1} + y * mdl2.Coefficients{2,1};


x_new = xval(x);
y_new = yval(y);
figure
plot(x_new,y_new)


dors_angle = interp1(x_new,y_new,0:100,'spline');
hold on

plot(0:100,dors_angle,'.')
legend('selected','spline fit')
save('ffs_dors.mat','dors_angle')



%% MTPJ angle
% load an image
img = imread('MTPJ angle Bruening.png');

figure

imshow(img);

% select the four corners of the plot

[x_lims,y_lims] = ginput(4);

% these are the values of the graph's corners in real values
x_gr = [0 0 100 100]';
y_gr = [0 50 50 0]';
[x y] = ginput; % press return when done


mdl1 = fitlm(x_lims,x_gr);

xval = @(x) mdl1.Coefficients{1,1} + x * mdl1.Coefficients{2,1};

mdl2 = fitlm(y_lims,y_gr);

yval = @(y) mdl2.Coefficients{1,1} + y * mdl2.Coefficients{2,1};


x_new = xval(x);
y_new = yval(y);
figure
plot(x_new,y_new)

toe_angle = interp1(x_new,y_new,0:100,'pchip');
hold on

plot(toe_angle)

legend('selected','spline fit')
save('ffs_toe.mat','toe_angle')
%% Force - Kelly 2017
% load an image
img = imread('Force Kelly.png');

figure

imshow(img);

% select the four corners of the plot

[x_lims,y_lims] = ginput(4);

% these are the values of the graph's corners in real values
x_gr = [0 0 100 100]';
y_gr = [0 2 2 0]';
[x y] = ginput; % press return when done


mdl1 = fitlm(x_lims,x_gr);

xval = @(x) mdl1.Coefficients{1,1} + x * mdl1.Coefficients{2,1};

mdl2 = fitlm(y_lims,y_gr);

yval = @(y) mdl2.Coefficients{1,1} + y * mdl2.Coefficients{2,1};


x_new = xval(x);
y_new = yval(y);
figure
plot(x_new,y_new)

force_val = interp1(x_new,y_new,0:100,'pchip');
hold on

plot(force_val)

legend('selected','spline fit')
save('ffs_force.mat','force_val')