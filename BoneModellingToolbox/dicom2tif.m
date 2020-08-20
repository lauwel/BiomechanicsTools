
function dicom2tif(inpath,outpath,flip,del)
% dicom2tif(inpath,outpath,flip,del)
% flip = 0 or [0 0 0] to keep input images exactly the same as output
%   images
% flip = 1 or [1 1 1] to flip x, y, and z. This means that the first column
%   will be the last (last column first - x flipped), first row will the be last (last
%   row first - y flipped) and first slice will be last (last slice first - z flipped).
% flip = [1 0 0] or [0 1 0] or [0 0 1] or ... flip only 1 or 2 of the image
%   parameters (rows, columns, and slices).
% bits = 1 for 16 bit
% bits = 2 for 8 bit

dicom_files=ls(fullfile(inpath,'*.dicom'));
if size(dicom_files,1)==0
    dicom_files=ls(fullfile(inpath,'*.dcm'));
end

if sum(size(flip))==2
    if flip==0;
        j=1;
        inc=1;
    elseif flip>0;
        j=size(dicom_files,1);
        inc=-1;
    end
elseif sum(size(flip))>3
    if flip(3)==0
        j=1;
        inc=1;
    elseif flip(3)>0
        j=size(dicom_files,1);
        inc=-1;
    end
end

for i=1:size(dicom_files,1)
    infile = fullfile(inpath,dicom_files(j,:));
    I_dicom=dicomread(infile);
    
    if sum(size(flip))==2
        if flip>0;
            I_dicom=flipud(I_dicom);
            I_dicom=fliplr(I_dicom);
        end
    elseif sum(size(flip))>3
        if flip(1)>0
            I_dicom=fliplr(I_dicom);
        end
        if flip(2)>0
            I_dicom=flipud(I_dicom);
        end
    end
    
    I_im=im2uint16(I_dicom);
       
    [pathstr, name, ext] = fileparts(fullfile(inpath,dicom_files(j,:)));
    u_ind=regexp(name,'_');
    u_ind=u_ind(end)-1;
    outfile = fullfile(outpath,[name(1:u_ind) '.tif']);
    
    if i==1
        imwrite(I_im,outfile,'Compression','none','WriteMode','overwrite')
    else
        imwrite(I_im,outfile,'Compression','none','WriteMode','append')
    end
    
    if isequal(inpath,outpath) && del==1
        delete(infile);
    end
    j=j+inc;
end

if ~isequal(inpath,outpath) && del==1
    rmdir(inpath,'s');
end
    