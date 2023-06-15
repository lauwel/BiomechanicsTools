function cmap_grid = makeColormapGrid(cmap )
% 
% This function creates a grid of unique colours, where the middle column is the
% original colormap and then the right are lighter, and the 
% left are darker
% ----------------------------INPUT VARIABLES------------------------------
% 
%  cmap             = the colours along the column (nx3 vector)
%               = 
%               =
% 
% ----------------------------OUTPUT VARIABLES-----------------------------
% 
%  cmap grid      = (nxnx3) grid of colours where the third
%                   dimension is the rgb triplet
%               = 
%               =
% 
% -------------------------------HISTORY-----------------------------------
% 
% Created 09-Nov-2022 by L. Welte (github.com/lauwel)
% -------------------------------------------------------------------------

ncols = size(cmap,1);

cmap_grid = zeros(ncols,ncols,3);

for el = 1:3
cmap_grid(:,ceil(ncols/2),el) =  cmap(:,el)
end

divs = 0.3/ncols;
for c = 1:floor(ncols/2)
    divs*(c-floor(ncols/2)+1)
    cmap_grid(:,floor(ncols/2)-c+1,:) = darken(cmap,divs*c);
end
for c = ceil(ncols/2)+1:ncols
    cmap_grid(:,c,:) = lighten(cmap,divs*(c-ceil(ncols/2)+1));
end

figure
for r = 1:ncols
    for c = 1:ncols
hold on
    fill([c-0.5,c+0.5,c+0.5, c-0.5],[r-0.5,r-0.5,r+0.5, r+0.5],squeeze(cmap_grid(r,c,:))','linestyle','none');
    end
end