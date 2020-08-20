function [string] = createInventorCylinder(centroid,orient,length,width,color,transparency)

string = 'Separator {\r\n';

if (exist('color')==1),
   if (exist('transparency')==1),
       string = [string createInventorMaterial(color,transparency)];
   else
       string = [string createInventorMaterial(color)];
   end
end;

OI_vector = [0 1 0];
UQ(1:3) = cross(OI_vector,orient);
if norm(orient)~=0,
    UQ(4) = acos(dot(orient,OI_vector)/(norm(orient)*norm(OI_vector)));
else UQ(4) = 0;
end;

string = [string '\tTransform {\r\n'];
string = [string sprintf('\t\ttranslation\t%g %g %g\r\n',centroid)];
string = [string sprintf('\t\trotation\t%g %g %g %g\r\n',UQ)];
string = [string '\t}\r\n'];

string = [string sprintf('\tCylinder {\r\n')];
string = [string sprintf('\t\tradius %g\r\n',width)];
string = [string sprintf('\t\theight %g\r\n',length)];
string = [string sprintf('\t}\r\n')];
% string = [string sprintf('}\r\n')];

string = [string '}\r\n'];
    
end