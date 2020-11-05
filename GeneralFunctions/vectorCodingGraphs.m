function varargout  = vectorCodingGraphs(xData,phaseData,numDivs,varargin)
% vectorCodingGraphs(xData,phaseData,numDivs)
% h = vectorCodingGraphs(xData,phaseData,numDivs)
% h = vectorCodingGraphs(xData,phaseData,numDivs,optCol,xName, yName)
% Written by L. Welte 2019.
% Code for plotting the vector coding results.
% xData     = the x co-ordinates for corresponding phase data
% phaseData = the raw array of vector coding data -> -180 to 180
% numDivs = the number of divisions of the phase circle, default 4 (90 deg)- are
%           -45 to 45, 45 to 135, 135 to -135, -135 to -45
% optCol = the optional argument to specify colours - must have same number
%           of rows as numDivs
% xName - names of the variables for the legend
% yName - names of the variable for the legend
size_divs = 360/(numDivs*2);

div_array = [-180+size_divs:size_divs*2:-size_divs, size_divs:size_divs*2:180];

optCol = varargin{1};
xName = varargin{2};
yName = varargin{3};


% verify the size inputs and get the number of subjects and the number of
% data points
[r,c] = size(xData);
if r == 1
    npts = c;
    nsubj = size(phaseData,1);
    if size(phaseData,2) ~= npts
        error('The phaseData variable is incorrectly formatted and does not match xData.')
    end
elseif c == 1
    npts = r;
    nsubj = size(phaseData,2);
    if size(phaseData,1) ~= npts
        error('The phaseData variable is incorrectly formatted and does not match xData.')
    end
    phaseData = phaseData'; % subjects are rows and points are columns
else
    error('The xData variable is not an appropriate size')
end

% hf = figure;
ha = axes(gcf,'Position',[0.1,0.2,0.4,0.6] );

if ~isempty(optCol)
    cols_small  = optCol;
else
    cols = colormap('jet');
    cols_small = cols(round(linspace(1,64,numDivs)),:);
end
cols_small(end+1,:) = [0 0 0]; % for if there are nans, grey it out
for i = 1:nsubj
    for j = 1:npts
        theta = phaseData(i,j);
        
        ind_smaller = find(theta < div_array);
        if isnan(theta) % if its a nan value
            bucket = length(cols_small);
        elseif isempty(ind_smaller) % if it's larger than the last bucket, it's actually part of the first bucket
            bucket = 1;
        else
            bucket = ind_smaller(1);
        end
        
        xwidth = 0.5;
        ywidth = 0.4;
        
        patch(ha,[xData(j)-xwidth xData(j)-xwidth xData(j)+xwidth xData(j)+xwidth],[i-ywidth,i+ywidth, i+ywidth, i-ywidth],cols_small(bucket,:),'EdgeColor','none')
        bucket_save(i,j) = bucket;
    end
end
xlim([min(xData) max(xData)])
ylim([1-ywidth nsubj+ywidth])
set(ha,'YColor','none')
xlabel('% Stance')



% figure
% ha2 = axes(gcf)
ha2 = axes(gcf,'Position',[0.65,0.35,0.2,0.2] );

% ha2 = axes(gcf,'Position',[0.4,0.4,0.4,0.4] );
hold on
for i = 1:numDivs
    if i ~= numDivs
       y_pie = [0 sind(div_array(i)) sind(div_array(i+1))];
        x_pie = [0 cosd(div_array(i)) cosd(div_array(i+1))];
        bucket = i+1;
    else
        
        y_pie = [0 sind(div_array(i)) sind(div_array(1))];
        x_pie = [0 cosd(div_array(i)) cosd(div_array(1))];
        bucket = 1;
    end
    
    patch(ha2,x_pie,y_pie,cols_small(bucket,:),'EdgeColor','none')
end


if ~isempty(xName)&& ~isempty(yName)
    ht(1) = text(1.5,0,  sprintf('(+) %s \n dominates', xName));
    ht(2) = text(0,1.5, sprintf('(+) %s \n dominates', yName));
    ht(3) = text(-1.5,0, sprintf('(-) %s \n dominates', xName));
    ht(4) = text(0,-1.5,sprintf('(-) %s \n dominates', yName));
end
for i = 1:4
    set(ht(i),'HorizontalAlignment','center')
end
set(ha2,'Visible','off')

varargout = {bucket_save};