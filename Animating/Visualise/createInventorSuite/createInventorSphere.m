function [string] = createInventorSphere(centroid,radius,color,transparency)

string = 'Separator {\r\n';

if (exist('color')==1),
   if (exist('transparency')==1),
       string = [string createInventorMaterial(color,transparency)];
   else
       string = [string createInventorMaterial(color)];
   end
end;

string = [string '\tTransform {\r\n'];
string = [string sprintf('\t\ttranslation\t%g %g %g\r\n',centroid)];
string = [string '\t}\r\n'];

string = [string sprintf('\tSphere {\r\n')];
string = [string sprintf('\t\tradius %g\r\n',radius)];
string = [string sprintf('\t}\r\n')];
% string = [string sprintf('}\r\n')];

string = [string '}\r\n'];
    
end