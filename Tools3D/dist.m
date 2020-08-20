function mydist = dist(pt1, pt2)

mydist = (sum((pt1-pt2).^2,2)).^.5;
