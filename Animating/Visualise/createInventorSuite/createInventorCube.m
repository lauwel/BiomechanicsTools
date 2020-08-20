function [string] = createInventorCube(centroid,width,height,depth,color,transparency)

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

string = [string sprintf('\tCube {\r\n')];
string = [string sprintf('\t\twidth %g\r\n',width)];
string = [string sprintf('\t\theight %g\r\n',height)];
string = [string sprintf('\t\tdepth %g\r\n',depth)];
string = [string sprintf('\t}\r\n')];
% string = [string sprintf('}\r\n')];

string = [string '}\r\n'];
    
end


% 
% Separator {
%         Cube {
%             width   2
%             height  2
%             depth   2
%         }