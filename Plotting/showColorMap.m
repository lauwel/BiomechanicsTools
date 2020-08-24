function showColorMap(c)
% have a colormap c in the base workspace and show all the colors
figure
for i = 1:length(c)
hold on
fill([i-0.5,i-0.5,i+0.5, i+0.5],[0,1,1,0],c(i,:),'linestyle','none');
end
xlim([1 length(c)])