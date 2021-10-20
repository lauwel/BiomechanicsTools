function col_light = lighten(col,scale)

% take the RGB triplet and lighten it uniformly while still outputting a
% valid triplet.
% INPUTS
% col       =       rgb triplet (nx3)
% scale     =       scale to darken (0 = no darkening, 1 = maximal
% darkening)
% OUTPUT
% col_dark  =       new lightened rgb triplets (nx3)


if scale > 1 || scale < 0
    error('Scale value for darken.m must be between 0 and 1')
end

if size(col,2) ~=3
    error('RGB triplet in darken.m must have three columns')
end
nRows = size(col,1);
col_light = col + scale * ones(nRows,3);

ind_bad = col_light > 1;

col_light(ind_bad) = 1;