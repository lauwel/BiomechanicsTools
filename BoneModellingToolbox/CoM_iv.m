function Centroid = CoM_iv(points,connection,Volume);

%% ************************************************************************
%% Based on VTK method GetVolume in
%% vtkMassProperties.  Reference: D. Eberly, J. Lancaster, A. Alyassin, "On
%% gray scale image measurements, II. Surface area and volume", CVGIP:
%% Graphical Models and Image Processing, vol. 53, no.6, pp.550-562, 1991.
%%
%% Uses Divergence Theorem to convert volume integration to an area
%% integral over the boundary of the region formed by the triangular
%% mesh.  The function integrated to get centroid is (x^2,y^2,z^2)/2.  
%%
%% Written by Anwar M. Upal 
%% Last Modified May 19th, 2003
%% ************************************************************************

n = size(connection);
%% initialize function
centroid = [0.0 0.0 0.0];
func_sum = [0.0 0.0 0.0];

%% go through each triangle to find volume of mesh
for count = 1:n(1,1)
    
    %% store current vertix (x,y,z) coordinates ...        
    %%    
    x(1) = points(connection(count,1),1);y(1) = points(connection(count,1),2);z(1) = points(connection(count,1),3); 
    x(2) = points(connection(count,2),1);y(2) = points(connection(count,2),2);z(2) = points(connection(count,2),3);
    x(3) = points(connection(count,3),1);y(3) = points(connection(count,3),2);z(3) = points(connection(count,3),3);
 
    %% get i j k vectors ... 
    %%
    i(1) = ( x(2) - x(1)); j(1) = (y(2) - y(1)); k(1) = (z(2) - z(1));
    i(2) = ( x(3) - x(1)); j(2) = (y(3) - y(1)); k(2) = (z(3) - z(1));
    i(3) = ( x(3) - x(2)); j(3) = (y(3) - y(2)); k(3) = (z(3) - z(2));

    %% cross product between two vectors, to determine normal vector
    %%
    u(1) = ( j(1) * k(2) - k(1) * j(2));
    u(2) = ( k(1) * i(2) - i(1) * k(2));
    u(3) = ( i(1) * j(2) - j(1) * i(2));

    
    %% normalize normal vector to 1
    %%
    if (norm(u) ~= 0.0)    
        u = u/norm(u);
    else
      u(1) = 0.0;
      u(2) = 0.0;
      u(3) = 0.0;
    end;

    %% This is reduced to ...
    %%
    ii(1) = i(1) * i(1); ii(2) = i(2) * i(2); ii(3) = i(3) * i(3);
    jj(1) = j(1) * j(1); jj(2) = j(2) * j(2); jj(3) = j(3) * j(3);
    kk(1) = k(1) * k(1); kk(2) = k(2) * k(2); kk(3) = k(3) * k(3);

    %% area of a triangle...
    %%
    a = sqrt(ii(2) + jj(2) + kk(2));
    b = sqrt(ii(1) + jj(1) + kk(1));
    c = sqrt(ii(3) + jj(3) + kk(3));
    s = 0.5 * (a + b + c);
    area = sqrt( abs(s*(s-a)*(s-b)*(s-c)));

    %% elements ... 
    %%
    zavg = (z(1) + z(2) + z(3)) / 3.0;
    yavg = (y(1) + y(2) + y(3)) / 3.0;
    xavg = (x(1) + x(2) + x(3)) / 3.0;

    % volume of current triangle
    t_vol(3) = (area * double(u(3)) * double(zavg));
    t_vol(2) = (area * double(u(2)) * double(yavg));
    t_vol(1) = (area * double(u(1)) * double(xavg));        
    
    % sum of function for centroid calculation
    func_sum(3) = func_sum(3) + (t_vol(3) * double(zavg));
    func_sum(2) = func_sum(2) + (t_vol(2) * double(yavg));
    func_sum(1) = func_sum(1) + (t_vol(1) * double(xavg));          
end;    
    
func_sum = func_sum /2;
if (exist('Volume')~=1),
    Volume = volume_iv(points,connection);
end;
centroid = func_sum/Volume;
Centroid = centroid;

%fprintf(1, 'Centroid: %f %f %f\n',  centroid);