function partialVolume3DSurfaceViz(partialVolFile,surfaceFile,voxelSize,imageModality,downSample,origDicomPath, writeIV)
% partialVolume3DSurfaceViz(partialVolFile,surfaceFile,voxelSize,imageModality,downSample,origDicomPath, writeIV)
%INPUTS:    partialVolFile  = Partial volume tif stack (path and filename)(512 x 512 image assumed)
%           surfaceFile     = WRL or IV file corresponding to partial volume (path and filename) 
%           voxelSize       = [X Y Z] voxel size
%           imageModality   = 1 = CT, 2 = MRI
%           downSample      = Number of slices to skip, set to 0 for no downsampling.
%                             this feature speeds up the rendering. Usually not necessary with MRI
%                             but try 5 or 10 for CT if too slow (this feature is not very robust).
%           origDicomPath   = Path to original dicom directory (not partial volumes). 
%                             Code currently looks for multiple files with *.dicom extension.
%           writeIV         = Write IV files with "_aligned.iv" extension.
%                             This only modifies the original file if using MRI modality. In
%                             future, this could and should be combined with convertWRL2IV function.
%OUTPUTS:   This program is primarily a visualizer. Only output is 'surfaceFile_aligned.iv' if writeIV = 1
%% global params


[ttt partialName ttt] = fileparts(partialVolFile);
[ivPath surfaceName ext] = fileparts(surfaceFile);

%set modality, CT = 1, MR = 2
CT_MR = imageModality;
modal = {'CT','MR'};

CT_Voxel = voxelSize;
MR_Voxel = voxelSize;



%%
if CT_MR == 1
    voxelSize = CT_Voxel;
    mstr = modal{1};
else if CT_MR == 2
        voxelSize = MR_Voxel;
        mstr = modal{2};
    end
end

tiffFilename = partialVolFile;
im_info = imfinfo(tiffFilename);
imgSize = numel(im_info);

tic

parfor i = 1:imgSize
    im(:,:,i) = imread(tiffFilename,'Index',i);   
end %i loop through images


if downSample ~= 0
    ind = (1:downSample:imgSize)';
    im = im(:,:,ind);
end %if downsample


    im = flipdim(im,3);
    im = flipdim(im,1);

toc


figure; 

h = vol3d('cdata',im,'xdata',[0  512 * voxelSize(1)] ,'ydata',[0  512 * voxelSize(2)] ,'zdata',[-imgSize * voxelSize(3)  0]);
colormap(bone(256));
alphamap([0 linspace(0.1, 0, 255)]);
axis equal off
set(gcf, 'color','w');
view(3)

hold on;


%read wrl or iv file
%********************************************

[pts cnt] = read_vrml_fast(surfaceFile);
cnt = cnt + 1;

if imageModality == 2
    
    dicomFiles = dir([origDicomPath '\*.dicom']);
    for i = 1:length(dicomFiles)
        info = dicominfo(fullfile(origDicomPath,dicomFiles(i).name));
        out(i,1) = str2num(dicomFiles(i).name(end-8:end-6));
        out(i,2:4) = [info.ImagePositionPatient]';
    end %i
    
   [minImagePositionPatient1 ~] = min(out(:,2)); 
    pts(:,2) = pts(:,2) + (size(im,2)-1) * voxelSize(2);
    pts(:,3) = pts(:,3) - (size(im,3) - 1) * voxelSize(3) - minImagePositionPatient1;
    
end %modify iv file if this is MRI

    
camlight('right'); camlight('left'); % camlight('headlight');
    lighting gouraud;
      patch('faces',cnt(:,1:3),'vertices',pts,...
        'facecolor',[0.3 0.3 1],...
        'edgecolor','none','facealpha',0.7);
    
    plot3(0,0,0,'ko','MarkerFaceColor','r');
    
    title(['volume: ' partialName ' surface: ' surfaceName]);

    %grey = [200/255 250/255 255/255]
    
if nargin > 5 
    if writeIV == 1
        patch2iv(pts,cnt(:,1:3),fullfile(ivPath,[surfaceName '_aligned.iv']));
    end
end %if write aligned iv
    
