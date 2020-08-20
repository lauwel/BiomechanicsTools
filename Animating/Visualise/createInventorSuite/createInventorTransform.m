function [string] = createInventorTransform(RT,T)

% first make sure we are in a 4x4 matrix
% if (exist('T')),
%     RT(4,:) = T;
%     RT(4,4) = 1;
% end;

if (exist('T','var')~=1),
    R = RT(1:3,1:3);
    T = RT(1:3,4);
else,
    R = RT;
end;

try,
    [phi,n,t_ham,q] = RT_to_helical(R,T);
catch,
    [phi,n,t_ham,q] = RT_to_helical(R,T');
end;
phi = phi*pi/180;

% fprintf(1,'\tTransform {\n');
% fprintf(1,'\t\ttranslation\t%g %g %g\n',T);
% fprintf(1,'\t\trotation\t%g %g %g %g\n',n,phi);
% fprintf(1,'\t}\n');
if (all(isnan(n)))
    string = '';
else
    string = '\tTransform {\r\n';
    string = [string sprintf('\t\ttranslation\t%g %g %g\r\n',T)];
    string = [string sprintf('\t\trotation\t%g %g %g %g\r\n',n,phi)];
    string = [string '\t}\r\n'];
end;