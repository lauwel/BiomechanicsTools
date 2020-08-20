function patch2iv(iv_vert,iv_faces,fname,color)
%This function generates an IV file from vertices and faces generated from
%the MATLAB  "patch" command, for example.

% 2018 - L.W. Modified to add the color, match with the patch2iv function
% of MR

% [pts,col] = size(iv_vert);
[n_faces,patch_type] = size(iv_faces);

display(['Writing OpenInventor file: ',fname]);

fid = fopen(fname,'w');

fprintf(fid,'%s \n','#VRML V1.0 ascii');
fprintf(fid,'%s \n','#');
fprintf(fid,'%s \n','Separator {');


if exist('color','var')
    fprintf(fid,'\t Material {\n');
	fprintf(fid,'\t\t diffuseColor ');
	fprintf(fid,'%10.4f %10.4f %10.4f \n', color(1), color(2), color(3));
	fprintf(fid, '\t }\n');
end

fprintf(fid,'\t %s  \n','Coordinate3 {');
fprintf(fid,'\t \t %s  \n','point [');
%for i = 1:pts;
%    fprintf(fid,'\t \t \t %g %g %g,\n',iv_vert(i,:));
%end;
fprintf(fid,'\t \t \t %g %g %g,\n',iv_vert');
fprintf(fid,'\t \t %s \n','] }');
fprintf(fid,'\t %s \n','IndexedFaceSet {');
fprintf(fid,'\t \t %s \n','coordIndex [');
if (size(iv_faces,2)==3),
    iv_faces = iv_faces-1;
    fprintf(fid,'\t \t \t%g, %g, %g,  -1, \n',iv_faces');
else,
    for i = 1:n_faces;
        fprintf(fid,'\t \t \t');
        for j = 1:patch_type
            fprintf(fid,'%g, ',iv_faces(i,j) - 1); %substract 1 becuase inventor uses [0...]
        end;
        fprintf(fid,'%s \n',' -1,');
    end;
end;
fprintf(fid,'%s \n','] } }');

fclose(fid);