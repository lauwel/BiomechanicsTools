function [string] = createInventorMaterial(color,transparency)

string = '\tMaterial {\r\n';
string = [string sprintf('\t\tdiffuseColor\t%d %d %d\r\n',color)];
if (exist('transparency')==1),
    string = [string sprintf('\t\ttransparency\t%d\r\n',transparency)];
end;
string = [string '\t}\r\n'];