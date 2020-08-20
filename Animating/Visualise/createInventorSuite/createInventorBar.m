function [string] = createInventorBar(base,orient,length,width,color,transparency)
%function [string] = createInventorArrow(base,orient,length,width,color,transparency)

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

% Try and set the height and width of the code so they are proportional to
% the width of the shaft.
%cone_height = width*5;
%cone_width = width*1.6;

%subtract half the height of the cone from the overall length, so that the
%tip of the cone ends up at the correct place.
cyl_length = length;

if (cyl_length < 0)
    % This is a special case where the vector is very short....
    % not certain how to handle it yet, for now, set cyl_length=0;
    % and then cut the bottom of the cone off until it is the correct
    % height....
    cyl_length = 0;
  %  cone_width = cone_width * length / cone_height;
  %  cone_height = length;
end;

cyl_trans = base + unit(orient)*(cyl_length/2);
%cone_trans = base + unit(orient)*(cyl_length+(cone_height/2));



string = [string 'Separator {\r\n'];
string = [string '\tTransform {\r\n'];
string = [string sprintf('\t\ttranslation\t%g %g %g\r\n',cyl_trans)];
string = [string sprintf('\t\trotation\t%g %g %g %g\r\n',UQ)];
string = [string '\t}\r\n'];

string = [string sprintf('\tCylinder {\r\n')];
string = [string sprintf('\t\tradius %g\r\n',width)];
string = [string sprintf('\t\theight %g\r\n',cyl_length)];
string = [string sprintf('\t}\r\n')];
string = [string '}\r\n'];
% 
% string = [string 'Separator {\r\n'];
% string = [string '\tTransform {\r\n'];
% string = [string sprintf('\t\ttranslation\t%g %g %g\r\n',cone_trans)];
% string = [string sprintf('\t\trotation\t%g %g %g %g\r\n',UQ)];
% string = [string '\t}\r\n'];

% string = [string sprintf('\tCone {\r\n')];
% string = [string sprintf('\t\tbottomRadius %g\r\n',cone_width)];
% string = [string sprintf('\t\theight %g\r\n',cone_height)];
% string = [string sprintf('\t}\r\n')];
% string = [string '}\r\n'];


string = [string '}\r\n'];
    
end