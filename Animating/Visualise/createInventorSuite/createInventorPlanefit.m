function [string] = createInventorPlanefit(Data,PointsFlag,color,transparency)

[x0 n d normd] = lsplane(Data);
dcoeff = -1 * dot(n, x0);

string = 'Separator {\r\n';

if (exist('color')==1),
   if (exist('transparency')==1),
       string = [string createInventorMaterial(color,transparency)];
   else
       string = [string createInventorMaterial(color)];
   end
end;

%find 4 points on the plane at the edges of the x and y range
% 1 (max max), 2 (min max), 3 (max max), 4 (max min)
Pxy1 = [min(Data(:,1)) min(Data(:,2))];
Pxy2 = [min(Data(:,1)) max(Data(:,2))];
Pxy3 = [max(Data(:,1)) max(Data(:,2))];
Pxy4 = [max(Data(:,1)) min(Data(:,2))];

%solve for z (z = ((-ax -by -d) / c)

P1 = [Pxy1 ((-(n(1)*Pxy1(1)) -(n(2)*Pxy1(2)) -dcoeff) / n(3))]; 
P2 = [Pxy2 ((-(n(1)*Pxy2(1)) -(n(2)*Pxy2(2)) -dcoeff) / n(3))]; 
P3 = [Pxy3 ((-(n(1)*Pxy3(1)) -(n(2)*Pxy3(2)) -dcoeff) / n(3))]; 
P4 = [Pxy4 ((-(n(1)*Pxy4(1)) -(n(2)*Pxy4(2)) -dcoeff) / n(3))]; 

v1 = P3 - P2;
v2 = P2 - P1;

plane_vec = unit(cross(v2,v1));
if rad2deg(acos(dot(plane_vec,n))) > 90
    noffset = -n;
else noffset = n;
end

P5 = P1 - (noffset .* 0.001)';
P6 = P2 - (noffset .* 0.001)';
P7 = P3 - (noffset .* 0.001)';
P8 = P4 - (noffset .* 0.001)';

if PointsFlag == 1
   for i = 1:size(Data,1)
       string = [string createInventorSphere(Data(i,:),1)];
   end %i
           
end %if

string = [string '\tSeparator {\r\n'];
string = [string '\t\tCoordinate3 {\r\n'];
string = [string '\t\t\tpoint [\r\n'];
string = [string sprintf('\t\t\t\t %g %g %g %s\r\n', P1,',')];
string = [string sprintf('\t\t\t\t %g %g %g %s\r\n', P2,',')];
string = [string sprintf('\t\t\t\t %g %g %g %s\r\n', P3,',')];
string = [string sprintf('\t\t\t\t %g %g %g %s\r\n', P4,',')];
string = [string sprintf('\t\t\t\t %g %g %g %s\r\n', P5,',')];
string = [string sprintf('\t\t\t\t %g %g %g %s\r\n', P6,',')];
string = [string sprintf('\t\t\t\t %g %g %g %s\r\n', P7,',')];
string = [string sprintf('\t\t\t\t %g %g %g %s\r\n', P8,',')];
string = [string '\t\t\t]\r\n'];
string = [string '\t\t}\r\n'];
string = [string '\tIndexedFaceSet {\r\n'];
string = [string '\t\tcoordIndex [\r\n'];
string = [string '\t\t\t0, 1, 2, -1,\r\n'];
string = [string '\t\t\t2, 3, 0, -1,\r\n'];
string = [string '\t\t\t4, 7, 6, -1,\r\n'];
string = [string '\t\t\t6, 5, 4, -1,\r\n'];
string = [string '\t\t ]\r\n'];
string = [string '\t }\r\n'];

string = [string '}\r\n'];
string = [string '}\r\n'];