function [string] = createInventorLink(ivFile,R,T,color,transparency)

string = 'Separator {\r\n';

if (exist('color')==1),
   if (exist('transparency')==1),
       string = [string createInventorMaterial(color,transparency)];
   else
       string = [string createInventorMaterial(color)];
   end
end;

if (nargin>=2),  % have an R T
    if (size(R,1)==4 && size(R,2)==4), %if 4x4
        string = [string createInventorTransform(R)];
    else
        string = [string createInventorTransform(R,T)];
    end;
end;

string = [string '\tFile {\r\n'];
string = [string sprintf('\t\tname "%s"\r\n',strrep(ivFile,'\','\\'))];
string = [string '\t}\r\n'];

string = [string '}\r\n'];
    
end