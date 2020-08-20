function M = makeSkewMatrix(w)

% w is a 1x3 or 3x1 vector and this returns the skew symmetric matrix

M = [0 -w(3) w(2);
    w(3) 0 -w(1);
    -w(2) w(1) 0];
