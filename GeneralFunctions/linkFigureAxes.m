function linkFigureAxes(figs,dim)
%
% Links axes of the figure numbers specified in figs
% ----------------------------INPUT VARIABLES------------------------------
%
%  figs             = a vector array of figure numbers.
% dim               = 'x' or 'y' the axis to link
% -------------------------------HISTORY-----------------------------------
%
% Created 19-Apr-2022 by L. Welte (github.com/lauwel)
% -------------------------------------------------------------------------
ha_all = [];
for f = 1:length(figs)
    figure(figs(f))
    hf(f) = get(gcf);
    ha_temp = hf(f).Children;
    for a = 1:length(ha_temp)
        if strcmp(ha_temp(a).Type,'axes')
            ha_all = [ha_all,ha_temp(a)];
        end
    end
end
if exist('dim','var')

    linkaxes(ha_all,dim);
else

    linkaxes(ha_all);
end