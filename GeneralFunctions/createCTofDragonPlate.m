op%% create the floor and mesh it

subj_dir = 'E:\SOL001B\';

pts_raw = readmatrix(fullfile(subj_dir,'Models','Floor','Floor points (T0024 fr 99).csv'));
npts = length(pts_raw(2:end))/3;
pts = reshape(pts_raw(2:end),3,npts);

figure

plot3quick(pts,'g');hold on
% [n1,~,~] = affine_fit(pts')

[x0,n1,d1,d] = lsplane(pts')

pts_raw = readmatrix(fullfile(subj_dir,'Models','Floor','Floor points (T0033 fr 102).csv'));
npts = length(pts_raw(2:end))/3;
pts = reshape(pts_raw(2:end),3,npts);

plot3quick(pts)
% [n2,~,~] = affine_fit(pts');

[x0,n2,d2,d] = lsplane(pts')

acosd(dot(n1,n2))

%% Make a new floor

meas =[ 600 50.8 400 ];
dims = [512 100 512];
dims(1) = dims(1)*2; % so we only have to take a quarter of the plate but still have resolution

voxelSize = meas./dims;
Ivol = VOXELISE(dims(1),dims(2),dims(3),'E:/ForcePlateBlock.STL','xyz');

I_new = permute(Ivol,[1 3 2]);
voxelS_new = voxelSize([1 3 2]);
dims = [512 512 100]; 
meas = meas([1 3 2]);
%% Now add the top of the plate etc

act_vol = uint16(20*rand(dims(1),dims(2),dims(3)));
act_vol(I_new(1:dims(1),1:dims(2),1:dims(3))) = act_vol(I_new(1:dims(1),1:dims(2),1:dims(3)))*60;
% act_vol(:,1:4,:) =  act_vol(:,1:2:8,:) *320;
% act_vol(:,50:2:60,:) =  act_vol(:,50:2:60,:)*16;
act_vol(:,:,end-4:end) =act_vol(:,:,end-4:end)*320; % top of the plate where bolt holes are

figure; image(squeeze(act_vol(:,50,:))); axis equal
figure; imagesc(squeeze(act_vol(155,:,:))); axis equal
figure; imagesc(squeeze(act_vol(:,:,50))); axis equal

% act_vol_new = permute(act_vol,[1 3 2]);


FV = stlread('E:/ForcePlateBlock.STL');
figure
patch('faces',FV.faces,'vertices',FV.vertices,'Facealpha',0.5)
axis equal

new_vert= FV.vertices(:,[3 1 2]);
plane.Centre = [200 300  0];
plane.Normal = [0 -1 0];
[outPts,outTris] = segmentTriangularMesh(new_vert,FV.faces,plane);
figure
patch('faces',FV.faces,'vertices',new_vert,'Facealpha',0.9)
axis equal
hold on;
patch('faces',outTris,'vertices',outPts,'Facealpha',0.5)
axis equal
k = convhull(outPts(:,1),outPts(:,2),outPts(:,3),'simplify',true);

patch('faces',k,'vertices',outPts,'Facealpha',0.5);
[pts_new,cns_new] = removeUnrefPts(outPts,k);
[X,Y] = meshgrid(0:4:400,0:4:300);
X_lin = X(:);
Y_lin = Y(:);
npts = length(X_lin);
D = delaunay(X_lin,Y_lin);
ptst = [X_lin,Y_lin,zeros(npts,1)];
ptsb = [X_lin,Y_lin,50.8*ones(npts,1)];
pts_ex = [ptst;ptsb];
cns_ex = [D;D+npts];

k = convhull(pts_ex(:,1),pts_ex(:,2),pts_ex(:,3));

figure;
patch('faces',k,'vertices',pts_ex,'Facealpha',0.5,'edgealpha',0.1);
patch2iv(pts_ex,k,'E:\SOL001B\Models\Floor\dragonplate.iv')
% patch2iv(outPts,outTris,'E:\SOL001B\Models\Floor\dragonplate.iv')
%   figure;
%   subplot(1,3,1), imshow(squeeze(Ivol(25,:,:)));
%   subplot(1,3,2), imshow(squeeze(Ivol(:,25,:)));
%   subplot(1,3,3), imshow(squeeze(Ivol(:,:,25)));

% imwrite(squeeze(act_vol(:,1,1:40)),colormap(gray(64)),'dragonPlate.tif')
% for f = 2:dims(2)
%     imwrite(squeeze(act_vol(:,f,1:40)),colormap(gray(64)),'dragonPlate.tif','WriteMode','append')
%     
% end

% dicomwrite(squeeze(act_vol(:,1,1:40)),colormap(gray(64)),'dragonPlate.dcm')
%% write a dicom file
   flname =  sprintf('dragonPlate_%0.3i.dcm',1);
   dicomwrite(squeeze(act_vol(:,:,1)),colormap(gray(64)),['E:\SOL001B\Models\Dicom\Floor\' flname])
   dinfo  = dicominfo(['E:\SOL001B\Models\Dicom\Floor\' flname]);
   dinfo.Width = 512;
   dinfo.Height = 512;
    dinfo.PixelSpacing = voxelS_new([2,1]);
    dinfo.SliceThickness = voxelS_new(3);
    dinfo.ImagePositionPatient = [0;0;meas(3)];
    dinfo.ImageOrientationPatient = [1 0 0 0 1 0];
for f = 1:dims(3)
   flname =  sprintf('dragonPlate_%0.3i.dcm',f);
   dicomwrite(squeeze(act_vol(:,:,f)),colormap(gray(64)),['E:\SOL001B\Models\Dicom\Floor\' flname],dinfo,'CreateMode','Copy')
%      dinfo  = dicominfo(['E:\SOL001B\Models\Dicom\Floor\' flname]);
%      dinfo.PixelSpacing
end

%% write a floor wrist viz with a calc 

raw_auto = dlmread('E:\SOL001B\Models\Floor\tracked floor .tra');
T_DP = convertRotation(raw_auto(13,:),'autoscoper','4x4xn');
dlmwrite('E:\SOL001B\Models\Floor\T_floor_aligned.txt',T_DP)
raw_auto = dlmread('E:\SOL001B\T0024_SOL001_nrun_rfs_barefoot\Autoscoper\T0024_SOL001_nrun_rfs_barefoot_cal_unfilt.tra');

T_cal = convertRotation(raw_auto(140,:),'autoscoper','4x4xn');
ivstring = createInventorHeader();
ivstring = [ivstring createInventorLink('E:\SOL001B\Models\Floor\dragonplate_aligned.iv',T_DP(1:3,1:3),T_DP(1:3,4)',[0.7 0.7 0.7],0.5)];
ivstring = [ivstring createInventorLink('E:\SOL001B\Models\IV\3Aligned Reduced\SOL001B_cal_R_aligned_reduced.iv',T_cal(1:3,1:3),T_cal(1:3,4)',[0.7 0.7 0.7],0.5)];


pts_raw = readmatrix(fullfile(subj_dir,'Models','Floor','Floor points (T0024 fr 99).csv'));
npts = length(pts_raw(2:end))/3;
pts = reshape(pts_raw(2:end),3,npts);
for p = 1:npts
    ivstring = [ivstring createInventorSphere(pts(:,p)',0.5,[1 0 0],0.5)];
end


fid = fopen('E:\SOL001B\Models\Floor\floorViz.iv','w');
fprintf(fid,ivstring);
fclose(fid);