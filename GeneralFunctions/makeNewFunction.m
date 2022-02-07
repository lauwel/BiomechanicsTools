function [] = makeNewFunction(fun_name)

% fun_name is the MATLAB file name of the function you want to write (i.e.
% fun_name = 'happy.m' will create a function called happy in the main
% directory
% This will load the template file so that all the initial comments are
% built in. It will automatically date it and sign it with L.Welte. Make
% your own template file to change it. 

    fid  = fopen('function_template.m','r+');
    f = fread(fid,'*char')';
    fclose(fid);

    f = strrep(f,'#functionname#',strrep(fun_name,'.m',''));
    f = strrep(f,'#date#',date);
    fid  = fopen(fun_name,'w+');
    fprintf(fid,'%s',f);
    fclose(fid);

    edit(fun_name)
end