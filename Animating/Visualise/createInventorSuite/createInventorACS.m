function [string] = createInventorACS(varargin)
%function [string] = createInventorACS(length,R,T)

length = 30; % default length
Radius = 0.4;
ConeHeight = 3;

nargin()
if (nargin >= 1)
    length = varargin{1};
    varargin(1) = [];
end;

% check for Radius, should be a scalar
if (size(varargin,2)>=1 && size(varargin{1},2)==1)
    Radius = varargin{1};
    varargin(1) = [];
end;

% check for ConeHeight, should be a scalar
if (size(varargin,2)>=1 && size(varargin{1},2)==1)
    ConeHeight = varargin{1};
    varargin(1) = [];
end;

%check for an RT
if (size(varargin,2)>=1 && size(varargin{1},2)==4)
    transform = createInventorTransform(varargin{1});
    varargin(1) = [];
elseif (size(varargin,2)>=2 && size(varargin{1},2)==3 && size(varargin{2},2)==3)
    transform = createInventorTransform(varargin{1},varargin{2});
    varargin(1:2) = [];
end;


string = '# ------------ Starting ACS --------------\r\n';
string = [string 'Separator {\r\n'];


% Add transform if needed :)
if (exist('transform','var')==1)
    string = [string transform];
end;

% Make X axis - cylinder then cone
string = [string 'Separator {\r\n'];
string = [string '\tMaterial {\r\n'];
string = [string '\t\tdiffuseColor\t 1 0 0\r\n'];
string = [string '\t}\r\n'];

string = [string '\tTransform {\r\n'];
string = [string sprintf('\t\ttranslation\t%g 0 0\r\n',length/2)];
string = [string sprintf('\t\trotation\t0 0 -1 %g\r\n',pi/2)];
string = [string '\t}\r\n'];

string = [string sprintf('\tCylinder {\r\n')];
string = [string sprintf('\t\tradius %g\r\n',Radius)];
string = [string sprintf('\t\theight %g\r\n',length)];
string = [string sprintf('\t}\r\n')];
string = [string '}\r\n'];

string = [string 'Separator {\r\n'];
string = [string '\tMaterial {\r\n'];
string = [string '\t\tdiffuseColor\t 1 0 0\r\n'];
string = [string '\t}\r\n'];

string = [string '\tTransform {\r\n'];
string = [string sprintf('\t\ttranslation\t%g 0 0\r\n',length)];
string = [string sprintf('\t\trotation\t0 0 -1 %g\r\n',pi/2)];
string = [string '\t}\r\n'];

string = [string sprintf('\tCone {\r\n')];
string = [string sprintf('\t\tbottomRadius %g\r\n',Radius*2)];
string = [string sprintf('\t\theight %g\r\n',ConeHeight)];
string = [string sprintf('\t}\r\n')];
string = [string '}\r\n'];

% Make Y axis - cylinder then cone
string = [string 'Separator {\r\n'];
string = [string '\tMaterial {\r\n'];
string = [string '\t\tdiffuseColor\t 0 1 0\r\n'];
string = [string '\t}\r\n'];

string = [string '\tTransform {\r\n'];
string = [string sprintf('\t\ttranslation\t0 %g 0\r\n',length/2)];
% string = [string sprintf('\t\trotation\t0 0 -1 %g\r\n',pi/2)];
string = [string '\t}\r\n'];

string = [string sprintf('\tCylinder {\r\n')];
string = [string sprintf('\t\tradius %g\r\n',Radius)];
string = [string sprintf('\t\theight %g\r\n',length)];
string = [string sprintf('\t}\r\n')];
string = [string '}\r\n'];

string = [string 'Separator {\r\n'];
string = [string '\tMaterial {\r\n'];
string = [string '\t\tdiffuseColor\t 0 1 0\r\n'];
string = [string '\t}\r\n'];

string = [string '\tTransform {\r\n'];
string = [string sprintf('\t\ttranslation\t0 %g 0\r\n',length)];
% string = [string sprintf('\t\trotation\t0 0 -1 %g\r\n',pi/2)];
string = [string '\t}\r\n'];

string = [string sprintf('\tCone {\r\n')];
string = [string sprintf('\t\tbottomRadius %g\r\n',Radius*2)];
string = [string sprintf('\t\theight %g\r\n',ConeHeight)];
string = [string sprintf('\t}\r\n')];
string = [string '}\r\n'];

% Make Z axis - cylinder then cone
string = [string 'Separator {\r\n'];
string = [string '\tMaterial {\r\n'];
string = [string '\t\tdiffuseColor\t 0 0 1\r\n'];
string = [string '\t}\r\n'];

string = [string '\tTransform {\r\n'];
string = [string sprintf('\t\ttranslation\t0 0 %g\r\n',length/2)];
string = [string sprintf('\t\trotation\t1 0 0 %g\r\n',pi/2)];
string = [string '\t}\r\n'];

string = [string sprintf('\tCylinder {\r\n')];
string = [string sprintf('\t\tradius %g\r\n',Radius)];
string = [string sprintf('\t\theight %g\r\n',length)];
string = [string sprintf('\t}\r\n')];
string = [string '}\r\n'];

string = [string 'Separator {\r\n'];
string = [string '\tMaterial {\r\n'];
string = [string '\t\tdiffuseColor\t 0 0 1\r\n'];
string = [string '\t}\r\n'];

string = [string '\tTransform {\r\n'];
string = [string sprintf('\t\ttranslation\t0 0 %g\r\n',length)];
string = [string sprintf('\t\trotation\t1 0 0 %g\r\n',pi/2)];
string = [string '\t}\r\n'];

string = [string sprintf('\tCone {\r\n')];
string = [string sprintf('\t\tbottomRadius %g\r\n',Radius*2)];
string = [string sprintf('\t\theight %g\r\n',ConeHeight)];
string = [string sprintf('\t}\r\n')];
string = [string '}\r\n'];

% All Done
string = [string '}\r\n'];  % Complete Separator...
string = [string '# ------------ Done ACS --------------\r\n'];
    
end