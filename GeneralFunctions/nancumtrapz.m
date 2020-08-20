function Q = nancumtrapz(varargin)
% Q = nancumtrapz(Y)
% Q = nancumtrapz(X,Y)
% This function uses the cumtrapz function to calculate the integral of Y
% over X, but ignores nan values. 


if nargin == 1
  
    Y = varargin{1};  
    [r,c] = size(Y);
    X = repmat(1:c,r,1);
    
elseif nargin == 2
    X = varargin{1};
    Y = varargin{2};
    [r,c] = size(Y);
    if any(size(X) ~= size(Y))
        error('X and Y variables in nancumtrapz.m must be the same length')
    end
end

Q = nan(r,c);

for ir = 1:r
    
    ind_nonan = ~isnan(X(ir,:)) & ~isnan(Y(ir,:));
    Q(ir,ind_nonan) = cumtrapz(X(ir,ind_nonan),Y(ir,ind_nonan));
end