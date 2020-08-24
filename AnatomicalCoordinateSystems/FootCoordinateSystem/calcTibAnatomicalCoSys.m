function [T_ACS_TC_CT,T_ACS_long_CT] = calcTibAnatomicalCoSys(Tib_pts,T_inert)
% The CPD can be anywhere from 1-30 seconds so be patient!
% Calculates the talocrural focused co-ordinate system and the long axis
% co-ordinate system. All are oriented generally with x - lateral,
% y-anterior,z- superior. 
% ----------------INPUTS-------------------------
% Tib_pts = points that are aligned with the reference tibia
% T_inert = the inertial co-ordinate system with the z axis oriented along
% the long axis
% 
% Note: this will only calculate the axes as per the orientation of the
% bone relative to the reference bone. The centroid needs to be added
% after.
% Written by L.Welte 04/2020. 

fprintf('Calculating the tibia axes from the shape....\n')

ptsNew.Raw = Tib_pts;

% reference files
refDir = '';%E:\Co-ordinateSystems\TibRef\';
tib.Ref = fullfile(refDir, 'tibRef.iv');
tib.Dome = fullfile(refDir, 'tibDome.iv');
tib.Cyl = fullfile(refDir, 'tibCyl.iv');
tib.Mal = fullfile(refDir, 'tibMal.iv'); % malleolus to orient the co sys

surf_names = fields(tib); % get the list of the surfaces we are referencing
nsurf = length(surf_names);
[pts.Ref,~] = read_vrml_fast(tib.Ref);



% downsample the points to reduce computation time. 
npts = length(pts.Ref);
indPts = round(linspace(1,npts,3000));
pts.RefDown = pts.Ref(indPts,: );

% get the indices of the points in each of the surfaces on the references
for sf = 2:nsurf % for the dome, and long axis for cylinder fit
    [pts.(surf_names{sf}),~] = read_vrml_fast(tib.(surf_names{sf}));
    [~,~,iRef.(surf_names{sf})] = intersect(pts.(surf_names{sf}),pts.RefDown,'rows');
end


% turn the pts into point clouds
pc.Ref = pointCloud(pts.Ref);
pc.RefDown = pointCloud(pts.RefDown);
for sn = 2:nsurf
    pc.(surf_names{sn}) = select(pc.RefDown,iRef.(surf_names{sn}));
end

%% now align the reference and the new point cloud

% downsample the new point cloud
l1 = length(ptsNew.Raw);
indPts = round(linspace(1,l1,2500)); % gives us the indices such that we have 2000 points
ptsNew.RawDown = ptsNew.Raw(indPts,:);

 beta = 2; lambda = 3; maxIter = 150; tole = 1e-5;

opt.max_it = maxIter; opt.tol = tole; opt.corresp = 1; opt.beta = beta; opt.lambda = lambda; opt.method= 'nonrigid'; opt.viz = 0;
cpd_struct= cpd_register(ptsNew.RawDown,pc.RefDown.Location,opt);
pcNew.NewCPD = pointCloud(cpd_struct.Y);


for sn = 2:nsurf
    pcNew.(surf_names{sn}) = select(pcNew.NewCPD,iRef.(surf_names{sn}));
end


tol = 1;

[x0n,an,rn] = lscylinder(pcNew.Cyl.Location,mean(pcNew.Cyl.Location)',T_inert(1:3,3),50,0.05,0.05);
modelCyl = cylinderModel([(x0n-an*20)',(x0n+an*20)',rn]);
modelDome = pcfitcylinder(pcNew.Dome,tol);



%% create the axes
TCaxis = unit(modelDome.Orientation);
longAxis = unit(modelCyl.Orientation);

%find an axis that will always be oriented superiorly
sup_axis = unit(pcNew.Cyl.Location(1,:)-pcNew.Dome.Location(1,:));
if dot(sup_axis,longAxis) < 0 % they are in the opposite direction
    longAxis = - longAxis;
end

%find an axis that will always be oriented laterally
lat_axis = unit(pcNew.Dome.Location(1,:)-pcNew.Mal.Location(1,:));
if dot(lat_axis,TCaxis) < 0 % they are in the opposite direction
    TCaxis = - TCaxis;
end

%

y = cross(longAxis,TCaxis);
yu = unit(y);

% for TC focused ACS
z = cross(TCaxis,yu);
zu = unit(z);

T_ACS_TC_CT = eye(4);
T_ACS_TC_CT(1:3,1:3) = [TCaxis',yu',zu'];

% for long axis focused ACS
x = cross(yu,longAxis);
xu = unit(x);

T_ACS_long_CT = eye(4);
T_ACS_long_CT(1:3,1:3) = [xu',yu',longAxis'];

%%

figure;
hold on;
pcshow(pcNew.Dome)
h = plot(modelDome);
h.FaceAlpha = 0.2;


% modelCyl = pcfitcylinder(pc.Cyl,1)%,'referenceVector',T_inert(1:3,3));
figure; hold on;
pcshow(pcNew.NewCPD)
pcshow(pcNew.Dome,'markersize',50)
pcshow(pcNew.Cyl,'markersize',50)
pcshow(pcNew.Mal,'markersize',50)

h = plot(modelCyl);
h.FaceAlpha = 0.2;
hold on;
h = plot(modelDome);
h.FaceAlpha = 0.2;