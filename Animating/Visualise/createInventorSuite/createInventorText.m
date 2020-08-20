function [string] = createInventorText(text,fontsize, position,color,transparency)

string = 'Separator {\r\n';

if (exist('color')==1),
   if (exist('transparency')==1),
       string = [string createInventorMaterial(color,transparency)];
   else
       string = [string createInventorMaterial(color)];
   end
end;

%add
% AxisAlignment {
%      alignment ALIGNAXISXYZ
%      }

% string = [string '\tAxisAlignment {\r\n'];
% string = [string '\talignment ALIGNAXISXYZ   \r\n'];
% string = [string '\t}\r\n'];

string = [string '\tFontStyle {\r\n'];
string = [string sprintf('\t\tsize\t %g\r\n',fontsize)];
string = [string '\t}\r\n'];

string = [string '\tTranslation {\r\n'];
string = [string sprintf('\t\ttranslation\t%g %g %g\r\n',position)];
string = [string '\t}\r\n'];

string = [string sprintf('\tAsciiText {\r\n')];
string = [string sprintf('\t\tstring %s\r\n',['"' text '"'])];
string = [string sprintf('\t}\r\n')];
% string = [string sprintf('}\r\n')];

string = [string '}\r\n'];
    
end