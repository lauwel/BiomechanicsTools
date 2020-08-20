% This code will take the information from the original CT scans (DICOM
% files). It then converts the wrl file from Mimics to an iv file into the
% directory specified by the ivdir (iv file directory). It will convert the
% dcm files from Mimics into a tif file. It will then plot it all to ensure
% it's in the same space

clear all
close all
clc

%% Fill these in :

% make sure you put a back slash at the end of every directory (anything
% named dir)
orig_dicom_dir = '/home/lauren/Documents/School/Master's/KDrive/Mike Research/Foot/BF_SHOD_Pilot/Data/XBSP00011\DICOMs\E19678\E19678_02\'; % your original CT scan dicom directory
orig_dicom_filename = 'E19678_02_001.dicom'; % any dicom in that path will do

wrldir = 'K:\Mike Research\Foot\BF_SHOD_Pilot\Data\XBSP00004\Models\VRML\'; % where your vrml files are saved
wrlfilename = 'XBSP00004_cal_R.wrl'; % change the file name as needed

ivdir = 'K:\Mike Research\Foot\BF_SHOD_Pilot\Data\XBSP00004\Models\IV\';

PVdir = 'K:\Mike Research\Foot\BF_SHOD_Pilot\Data\XBSP00004\Segmentation\PartialVols\PVcal\'; % where are your partial volumes located? (dcm); your tif file will save here as well
%% get the info from the original DICOMS
orig_dicom_file = strcat(orig_dicom_dir,orig_dicom_filename); % full path to a file
info = dicominfo(orig_dicom_file);
offsetz = info.SliceLocation;
voxelSize = [info.PixelSpacing; info.SliceThickness]; % voxel size in CT scan
sprintf(' %1.5d ;%1.5d ;%1.5d ',voxelSize(1),voxelSize(2),voxelSize(3)) 

%% Convert the created WRL file to an IV file
wrlfile = strcat(wrldir,wrlfilename); % created in Mimics
convertWRL2IV_v2(wrlfile,ivdir,0,0,offsetz)  % will save the newly created iv file in ivdir


%% Convert the exported dcm files to a tif file
% It will save in the same location as PVdir
dicom2tif(PVdir,PVdir,[0 1 1],0);

%%  find the average centre - just for plotting purposes
[~,ivfilename,~] = fileparts(wrlfile); % the created iv file is named the same as the wrl file was; this gets the file name without the extension
[pts cnt] = read_vrml_fast(fullfile(ivdir,[ivfilename '.iv']));
centroid = mean(pts,1);


%% Visualize volumes and surface files (origDicomPath and writeIV arguments are not needed)

IVfile = strcat(fullfile(ivdir,[ivfilename '.iv']));
temp = dir([PVdir '*tif*']);
PVfile = temp.name;
PVfiletif = strcat(PVdir,PVfile);

voxelSize = [info.PixelSpacing; info.SliceThickness];
imageModality = 1;  % CT
downSample = 4; % sample every four slices; I wouldn't go higher than 4

writeIV = 1; % if you want it to write an iv file with _aligned

partialVolume3DSurfaceViz(PVfiletif,IVfile,voxelSize,imageModality,downSample,1,orig_dicom_dir, writeIV)

% plot the iv file in matlab

cnt = cnt + 1;
patch('faces',cnt(:,1:3),'vertices',pts,...
        'facecolor',[0.3 0.3 1],...
        'edgecolor','none','facealpha',1);