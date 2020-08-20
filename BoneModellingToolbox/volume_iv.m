function [Volume,VolumeX,VolumeY,VolumeZ,NormalizedShapeIndex,patches] = volume_iv(points,connection);

%% ************************************************************************
%% Based on VTK method GetVolume in
%% vtkMassProperties.  Reference: D. Eberly, J. Lancaster, A. Alyassin, "On
%% gray scale image measurements, II. Surface area and volume", CVGIP:
%% Graphical Models and Image Processing, vol. 53, no.6, pp.550-562, 1991.
%%
%% Uses Divergence Theorem to convert volume integration to an area
%% integral over the boundary of the region formed by the triangular
%% mesh. The function integrated to get volume is (x,y,z)/3.  For volume the "/3"
%% factors are optimized by using VTK method of MUNC (maximum unit normal 
%% component algorithm).
%%
%% Written by Anwar M. Upal 
%% Last Modified May 19th, 2003
%% ************************************************************************

n = size(connection);
%% initialize function
SurfaceArea = 0.0;
Volume  = 0.0;
VolumeX = 0.0;
VolumeY = 0.0;
VolumeZ = 0.0;
Kx = 0.0;
Ky = 0.0;
Kz = 0.0;
NormalizedShapeIndex = 0.0;
wxyz = 0; wxy = 0.0; wxz = 0.0; wyz = 0.0;
munc(1:3) = 0;
vol(1:3) = 0;
kxyz(1:3) = 0;
patches = zeros([n(1,1) 1]);


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

    %% determine max unit normal component...
    %%
    absu = abs(u); 
    t_munc = [0.0 0.0 0.0];
    t_wyz = 0.0; t_wxz = 0.0; t_wxy = 0.0; t_wxyz = 0.0;
    if (( absu(1) > absu(2)) && ( absu(1) > absu(3)) )
      munc(1) = munc(1) + 1;
      t_munc(1) = t_munc(1) + 1;
    elseif (( absu(2) > absu(1)) && ( absu(2) > absu(3)) )
      munc(2) = munc(2) + 1;
      t_munc(2) = t_munc(2) + 1;      
    elseif (( absu(3) > absu(1)) && ( absu(3) > absu(2)) )
      munc(3) = munc(3) + 1;
      t_munc(3) = t_munc(3) + 1;
    elseif (( absu(1) == absu(2))&& ( absu(1) == absu(3)))
      wxyz = wxyz + 1;
      t_wxyz = t_wxyz + 1;      
    elseif (( absu(1) == absu(2))&& ( absu(1) > absu(3)) )
      wxy = wxy + 1;
      t_wxy = t_wxy + 1;      
    elseif (( absu(1) == absu(3))&& ( absu(1) > absu(2)) )
      wxz = wxz + 1;
      t_wxz = t_wxz + 1;      
    elseif (( absu(2) == absu(3))&& ( absu(1) < absu(3)) )
      wyz = wyz + 1;
      t_wyz = t_wyz + 1;      
    else 
      fprintf(1, '\aUnpredicted situation...!\n');
      return; 
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
    patches(count,1) = area;
    SurfaceArea = SurfaceArea + area;

    %% volume elements ... 
    %%
    zavg = (z(1) + z(2) + z(3)) / 3.0;
    yavg = (y(1) + y(2) + y(3)) / 3.0;
    xavg = (x(1) + x(2) + x(3)) / 3.0;

    % volume of current triangle
    t_vol(3) = (area * double(u(3)) * double(zavg));
    t_vol(2) = (area * double(u(2)) * double(yavg));
    t_vol(1) = (area * double(u(1)) * double(xavg));     
    
    % incremental sum of volume
    vol(3) = vol(3) + t_vol(3);
    vol(2) = vol(2) + t_vol(2);
    vol(1) = vol(1) + t_vol(1);     
       
end;
    
%% Weighting factors in Discrete Divergence theorem for volume calculation...
%%      
kxyz(1) = (munc(1) + (wxyz/3.0) + ((wxy+wxz)/2.0)) /(n(1,1));
kxyz(2) = (munc(2) + (wxyz/3.0) + ((wxy+wyz)/2.0)) /(n(1,1));
kxyz(3) = (munc(3) + (wxyz/3.0) + ((wxz+wyz)/2.0)) /(n(1,1));
VolumeX = vol(1);
VolumeY = vol(2);
VolumeZ = vol(3);
Volume =  (kxyz(1) * vol(1) + kxyz(2) * vol(2) + kxyz(3)  * vol(3));
Volume =  abs(Volume);    

Kx = kxyz(1);
Ky = kxyz(2);
Kz = kxyz(3);

NormalizedShapeIndex = (sqrt(SurfaceArea)/(Volume^(1/3)))/2.199085233;
%fprintf(1, 'Kx: %f\n', Kx);
%fprintf(1, 'Ky: %f\n', Ky);
%fprintf(1, 'Kz: %f\n\n', Kz);
%fprintf(1, 'VolumeX: %f\n', VolumeX);
%fprintf(1, 'VolumeY: %f\n', VolumeY);
%fprintf(1, 'VolumeZ: %f\n', VolumeZ);
%fprintf(1, 'Volume:  %f\n', Volume);
