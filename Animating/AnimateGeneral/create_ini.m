function create_ini(showham, setcolor, loadligaments, numFibers,baseFiberPath,fiberName,filedir)
%write an .ini file for an animation sequence
ini = '[global]\n';
ini = [ini 'showham=' num2str(showham) '\n'];
ini = [ini 'setcolor=' num2str(setcolor) '\n'];
ini = [ini 'loadligaments=' num2str(loadligaments) '\n'];
ini = [ini 'numFibers=' num2str(numFibers) '\n'];
ini = [ini 'baseFiberPath=' strrep(baseFiberPath,'\','\\') '\n'];
ini = [ini 'fiberName=' strrep(fiberName,'%','%%') '\n'];

if ~isempty(regexp(filedir,'.ini'))
    fid = fopen(filedir,'w');
else
    fid = fopen(fullfile(filedir,'INI.ini'),'w');
end

fprintf(fid,ini);
fclose(fid);
end