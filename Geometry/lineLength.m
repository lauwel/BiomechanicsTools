function tot_dist = lineLength(pts)

% measure the length of a line based on points

% input pts that are NXD where N is the number of points and D is the
% dimensions

distv = distBtwPoints3xN( pts(2:end,:), pts(1:end-1,:));

tot_dist = sum(distv);