function varargout = PrettyStdDevGraphs(xdata,meandata,stddev,c,num)
% Plots the mean with a specified number of standard deviations shaded
% behind it.
% --------INPUT VARIABLES------------
% xdata is the data in x
% meandata is the same size as the xdata and is plotted as one line
% stddev is the value of the standard deviation at every point x
% c is the color
% num is the number of standard deviations to plot, default is 2
% -----------OUTPUT VARIABLES ------------
% h = the handle to the graphics object of the shaded area (1) and the mean 
% line (2)
% ----------HISTORY------------------
% Feb 21/2018 - edited to handle nan values being entered
% h is the handle to 1- the filled area, 2- the mean plot
% 2016 - Written by L Welte
% -------------------------------------------
if nargin < 5
    num = 2; % default number of standard devs
end

uplim = meandata + num * stddev;
lowlim = meandata - num * stddev;

%find the initial nan values
up_nan = ~isnan(uplim);
low_1_nan = ~isnan(lowlim);

%t
lowlim = flipud(lowlim);
lowlim = fliplr(lowlim);

low_nan = ~isnan(lowlim);

h(1) = fill([xdata(up_nan),fliplr(flipud(xdata(low_1_nan)))],[uplim(up_nan), lowlim(low_nan)],c); %draw a rectangle defined by these borders
hold on
h(2) = plot(xdata,meandata,'LineWidth',2);

set(h(1),'FaceAlpha',0.3,'LineStyle','none')
set(get(get(h(1),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
set(h(2),'Color',c)
hold off

if nargout ==1
    varargout = {h};
end
