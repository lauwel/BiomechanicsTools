function StreamTube_to_IV(nodes,IV_file_name,tube_radius,colour)

%Input
% nodes = [n x 3] list of points on streamtube

% IV_file_name = full path string of Open Inventor File name to which tube
%   is written.

% colour         = optional argument to specify the colour of the streamtube
% tube_radius    = the radius of the tube. 


% TubePlot Arguments:
% curve: [3,N] vector of curve data
% r      the radius of the tube
% n      number of points to use on circumference. Defaults to 8
% ct     threshold for collapsing points. Defaults to r/2 


% 2018 L.W. Modified to combine the MR changes into this function. Added
% color and fibre radius, also modified patch2iv

if size(nodes,1) > size(nodes,2), nodes = nodes'; end

[X,Y,Z] = tubeplot(nodes,tube_radius,24);
fvc = surf2patch(X,Y,Z);

if exist('colour','var')
    patch2iv(fvc.vertices,fvc.faces,IV_file_name,colour);
else
    patch2iv(fvc.vertices,fvc.faces,IV_file_name);
end


