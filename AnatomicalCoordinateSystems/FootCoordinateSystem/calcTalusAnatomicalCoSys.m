function [T_ACS_TC_CT,T_ACS_ST_CT] = calcTalusAnatomicalCoSys(Talpts)
% This function calculates the talar anatomical co-ordinate systems based
% on the talocrural axis (TC) and the subtalar axis (ST) as per:
% Montefiori 2019 : https://doi.org/10.1016/j.jbiomech.2018.12.041
% Briefly, the talus is fit to a reference talus to orient it. Coherent
% point drift (Myronenko) is used to determine the talar dome, calcaneal
% and navicular articular surfaces such that a sphere fit can be fit to the
% first two (of which the line connecting the centres is the ST axis) and a
% cylinder fit to the latter, such that the long axis is the TC axis. It is
% aligned to fit the SOL convention of x - lateral, y- anterior, z-
% superior.
% 
% The CPD can be anywhere from 10-30 seconds so be patient!
% 
% Written by L.Welte 04/2020. 

fprintf('Calculating the subtalar and the talocrural axes....\n')

ptsNew.Raw = Talpts;

% reference files
refDir = 'E:\Co-ordinateSystems\TalusRef\';
tal.Ref = fullfile(refDir, 'refTalus.iv');
tal.Dome = fullfile(refDir, 'talarDome.iv');
tal.Calc = fullfile(refDir, 'calcSurf.iv');
tal.Nav = fullfile(refDir, 'navSurf.iv');

surf_names = fields(tal); % get the list of the surfaces we are referencing
nsurf = length(surf_names);

[pts.Ref,~] = read_vrml_fast(tal.Ref);

% downsample the points to reduce computation time. 
npts = length(pts.Ref);
indPts = round(linspace(1,npts,3000));
pts.RefDown = pts.Ref(indPts,: );


% get the indices of the points in each of the surfaces on the references
for sf = 2:nsurf % for the dome, calc and nav
    [pts.(surf_names{sf}),~] = read_vrml_fast(tal.(surf_names{sf}));
    [~,~,iRef.(surf_names{sf})] = intersect(pts.(surf_names{sf}),pts.RefDown,'rows');
end


% turn the pts into point clouds
pc.Ref = pointCloud(pts.Ref);
pc.RefDown = pointCloud(pts.RefDown);
for sn = 2:nsurf
    pc.(surf_names{sn}) = select(pc.RefDown,iRef.(surf_names{sn}));
end


%% Now load in the new talus and segment the new surfaces


% make the raw point cloud
pcNew.Raw = pointCloud(ptsNew.Raw);

% downsample the point cloud
nptsNew = length(ptsNew.Raw);
indPtsNew = round(linspace(1,nptsNew,2000)); % gives us the indices such that we have 3000 points
ptsNew.RawDown = ptsNew.Raw(indPtsNew,:);
pcNew.RawDown = pointCloud(ptsNew.RawDown,'color',repmat([.75 .75  .75],length(indPtsNew),1));

beta = 2; lambda = 3; maxIter = 150; tole = 1e-5;
opt.max_it = maxIter; opt.tol = tole; opt.corresp = 1; opt.beta = beta; opt.lambda = lambda; opt.method= 'nonrigid'; opt.viz = 0;
cpd_struct = cpd_register(ptsNew.RawDown,pts.RefDown,opt);
pcNew.NewCPD = pointCloud(cpd_struct.Y);

for sn = 2:nsurf
    pcNew.(surf_names{sn}) = select(pcNew.NewCPD,iRef.(surf_names{sn}));
end


tol = 1;

modelNav = pcfitsphere(pcNew.Nav,tol);
modelCalc = pcfitsphere(pcNew.Calc,tol);
modelDome = pcfitcylinder(pcNew.Dome,tol);


%% create all the axes


STaxis = unit(modelNav.Center-modelCalc.Center);
TCaxis = unit(modelDome.Orientation);

%find an axis that will always be oriented anteriorly
ant_axis = unit(pcNew.Nav.Location(1,:)-pcNew.Dome.Location(1,:));
orient_axis = cross(ant_axis,STaxis);
if dot(orient_axis,TCaxis) < 0 % they are in the opposite direction
    TCaxis = - TCaxis;
end


z = cross(TCaxis,STaxis);
zu = unit(z);

% for TC focused ACS
y = cross(z,TCaxis);
yu = unit(y);

% for ST focused ACS
x = cross(STaxis,z);
xu = unit(x);

T_ACS_ST_CT = eye(4);
T_ACS_ST_CT(1:3,1:3) = [xu',STaxis',zu'];

T_ACS_TC_CT = eye(4);
T_ACS_TC_CT(1:3,1:3) = [TCaxis',yu',zu'];


%% plotting for verification
% 
% figure;
% hold on;
% pcshow(pcNew.Raw);
% plotPointsAndCoordSys1([],T_ACS_ST_CT);
% plotPointsAndCoordSys1([],T_ACS_TC_CT);
% 
% figure;
% hold on;
% pcshow(pcNew.Dome)
% h = plot(modelDome);
% h.FaceAlpha = 0.2;
% 
% figure; hold on;
% pcshow(pcNew.NewCPD)
% pcshow(pcNew.Dome,'markersize',50)
% pcshow(pcNew.Nav,'markersize',50)
% pcshow(pcNew.Calc,'markersize',50)
% 
% h = plot(modelNav);
% h.FaceAlpha = 0.2;
% hold on;
% h = plot(modelCalc);
% h.FaceAlpha = 0.2;
% 
% plot3quick([modelNav.Center;modelCalc.Center]','w')
% plot3quick([pcNew.Dome.Location(1,:);pcNew.Nav.Location(1,:)]','m')

