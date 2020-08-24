function varargout = PrettyStdDevGraphs(xdata,meandata,stddev,c,num)
% c is the color
% takes in vectors
% plots a graph with transparent standard deviations
% Feb 21/2018 - edited to handle nan values being entered
% h is the handle to 1- the filled area, 2- the mean plot
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
