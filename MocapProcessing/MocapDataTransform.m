function data = MocapDataTransform(varargin)
% MocapDataTransform()
% [data] = MocapDataTransform()
% [data] = MocapDataTransform(filename)
% [data] = MocapDataTransform(filename,'Name',Value,...)
%
% Overview:
% This function takes the output from Qualisys Track Manager and puts it
% into a more palatable form (i.e. marker_data and force_data structures, 
% with the filename as well).
% It also converts the force and COP into global and can filter the data as
% needed.
%
% -----------------INPUTS-----------------------------------------------
% 
% filename          a cell array of files to process. i.e. {'filename.m',
%                   'filename2.m'}
%
% Name- Value pairs can be added to customize:
% 'savedir'         directory to save the processed data. Default is the
%                   same path as the files with  '_processedmotion.mat' at
%                   the end
% 'saveProc'        whether to save processed data either 'off', 'on'.
%                   Default is 'off'
% 'filter'          whether to filter the trajectories and force with a
%                   fourth order low pass butterworth filter either
%                   'off' or 'on','adaptive'. Default is 'off'.
% 'forceCutOff'     cut-off frequency if filter is 'on',or 'adaptive' for the force/COP
% 'mocapCutOff'     cut-off frequency if filter is 'on',or 'adaptive' for trajectories
% 'lab'             which lab is being used - important for force plate
%                   orientation, offset and conversion to global. Either
%                   'HMRL' or 'SOL'.
% 'visualiseForces' pulls up a plot of the forces to verify the transforms
%                   and global position of forces. Either 'off' or 'on'.
%                   Default is 'off'.
% 'resample'        decide whether to upsample mocap, downsample forces or
%                   neither. 'mocap' upsamples mocap, 'force' downsamples
%                   the forces, 'none' does nothing
% 
% Version 2.2 L. Welte
% Added export of events from QTM.
% May 6/ 2020
% 
% Version 2.1 L. Welte
% Added the option to use an adaptive Low pass Butterworth filter.
% Nov 18/ 2019 
% 
% Version 2.0 L. Welte
% Added name-value pairs, added transformation of the force/COP in global,
% updated use of LowPassButterworth function
% May 22/2019
%
% Version 1.0 L. Welte
% Dec 15/2015
%--------------------------------------------------------------------------

% Set up all the inputs and error check the inputs
filename = varargin{1};
defaultSaveDir = [];
defaultSaveProcessed = 'off';
defaultFilter = 'off';
defaultCutOffFrequencyForce = 15; % Hz
defaultCutOffFrequencyMocap = 15;
defaultLabUsed = 'HMRL'; % else 'SOL'
defaultVisualiseForces = 'off';
defaultResample = 'off';
filterOpts = {'off','on','adaptive'};
visForceOpts = {'off','on'};
LabOpts = {'HMRL','SOL'};
resampleOpts = {'force','mocap','none'};
% determine whether name value pairs have been added
p = inputParser;
validPosNum = @(x) isnumeric(x) && all(x > 0);
%   addRequired(p,'filename',@(x)validateattributes(x,{'char'}))
addParameter(p,'savedir',defaultSaveDir,@ischar)
addParameter(p,'saveProc',defaultSaveProcessed,@(x) ismember(x,filterOpts))
addParameter(p,'filter',defaultFilter,@(x) ismember(x,filterOpts))
addParameter(p,'forceCutOff',defaultCutOffFrequencyForce,validPosNum)
addParameter(p,'mocapCutOff',defaultCutOffFrequencyMocap,validPosNum)
addParameter(p,'lab',defaultLabUsed,@(x) ismember(x,LabOpts))
addParameter(p,'visualiseForces',defaultVisualiseForces,@(x) ismember(x,visForceOpts))
addParameter(p,'resample',defaultResample,@(x) ismember(x,resampleOpts))
parse(p,varargin{2:end})

fc_mocap = p.Results.mocapCutOff;
fc_force = p.Results.forceCutOff;


lab = p.Results.lab;
filter_flag = p.Results.filter;
savedir = p.Results.savedir;
save_proc_flag = p.Results.saveProc;
visualise_force_flag = p.Results.visualiseForces;
resample_flag = p.Results.resample;

if strcmp(filter_flag,'adaptive') && length(fc_mocap) == 1
    fc_mocap = [fc_mocap,1];
end
if strcmp(filter_flag,'adaptive') && length(fc_force) == 1
    fc_mocap = [fc_mocap,1];
end
if isempty(filename)
    [list_files_mot, pathname,~] = uigetfile({'*.mat' 'MAT Files'}, 'Qualisys Motion file...','MultiSelect','on');
    % If the path is not on the MATLAB path, add it, and change the current
    % directory to be that path
    addpath(genpath(pathname))
    %     cd(pathname)
else
    list_files_mot = varargin{1};
end


if ~iscell(list_files_mot) % if only one file is loaded, it's loaded as a string not a cell array
    
    temp = list_files_mot;
    clear('list_files_mot')
    list_files_mot{1} = temp;
    nfiles = 1;
    
else
    nfiles = length(list_files_mot);
end

if ~exist('pathname','var')
    [pathname,~,~] = fileparts(list_files_mot{1}); % determine the name of the trial
end

for i = 1:nfiles
    
    raw_qtm_export = load(list_files_mot{i}); % load the motion file
    
    root = fields(raw_qtm_export);
    disp((root{1}));
    
    unit_conv = 0; % set the unit conversion flag to 0
    unit_chk = 0; % only check the units once;
    if isfield(raw_qtm_export.(root{1}).Trajectories.Labeled,'Labels')
        for j = 1:size(raw_qtm_export.(root{1}).Trajectories.Labeled.Labels,2)
            
            % take the imported data and organize it in a sructure called
            % marker_data with the fields "marker name", "number of frames" and
            % "frame rate"
            marker_name = raw_qtm_export.(root{1}).Trajectories.Labeled.Labels{j};
            if isstrprop(marker_name(1),'digit') % if the first element of the marker name is a digit, then it needs to be put at the end as matlab doesn't like variables that start with numbers
                marker_name = [marker_name(2:end) marker_name(1)];
            end
            
            marker_data.nFrames = raw_qtm_export.(root{1}).Frames;
            marker_data.FrameRate = raw_qtm_export.(root{1}).FrameRate;
            
            m_temp = squeeze((raw_qtm_export.(root{1}).Trajectories.Labeled.Data(j,1:3,:)));
            
            nframesTracked = sum(~isnan(m_temp(1,:))); % determine the number of frames with tracked data
            if unit_chk == 0 && nframesTracked > 10 % only check once, but make sure there are enough frames to check
                unit_chk = 1;
                if unit_conv~=1
                    if sum(max(abs(m_temp)) > 10) > 0.1*(nframesTracked) % if 10% or more of the tracked values are larger than 10, assume its in millimeters and divide by 1000
                        unit_conv = 1;
                        warning('Converting marker units to meters for %s.',root{1})
                    end
                end
                
            end
            
            if unit_conv == 1 % convert to meters
                m_temp = m_temp/1000;
            end
            
            
            if strcmp(filter_flag,'on') % filter the data
                if strcmp(filter_flag,'adaptive') % filter the data
                    if length(fc_mocap) ~= 2
                        error('When specifying an adaptive filter, the filter cut-off frequency must have a low and a high value.')
                    else
                        m_filt = adaptiveLowPassButterworth(m_temp,fc_mocap,marker_data.FrameRate);
                    end
                else % regular low pass butterworth
                    m_filt = LowPassButterworth(m_temp,4,fc_mocap,marker_data.FrameRate);
                end
            else
                m_filt = m_temp;
            end
            
            if strcmp(resample_flag,'mocap') % upsample the mocap to force level
                m_nonan = normaliseNaN(m_filt,2,size(m_filt,2));
                
                force_fr = raw_qtm_export.(root{1}).Force(1).Frequency;
                
                m_interp = normaliseNaN(m_filt,2,force_fr/marker_data.FrameRate*marker_data.nFrames);

%                 figure;
%                 plot(m_temp')
%                 hold on;
%                  plot(m_filt')
%                 plot(m_interp','--')
                
                marker_data.(marker_name)(:,:) = m_interp;
            else
                marker_data.(marker_name)(:,:) = m_filt;
            end
            
            clear m_filt
            
        end
    else
        
        disp(sprintf('The markers in file %s are not labelled', (root{1})));
        
        marker_data.nFrames = raw_qtm_export.(root{1}).Frames;
        marker_data.FrameRate = raw_qtm_export.(root{1}).FrameRate;
    end
    
    
    if strcmp(resample_flag,'mocap') % replace the framerate if it was upsampled
        marker_data.Framerate = force_fr;
    end
    
    
    if isfield(raw_qtm_export.(root{1}),'Analog')
        for j = 1:raw_qtm_export.(root{1}).Analog.NrOfChannels
            chan_name = raw_qtm_export.(root{1}).Analog.Labels{j};
            analog_data.(chan_name) = raw_qtm_export.(root{1}).Analog.Data(j,:);
        end
        warning('Analog Data has NOT been resampled to match force/mocap.')
    else
        analog_data = [];
        warning('No analog data.')
    end
        
    
    if isfield(raw_qtm_export.(root{1}),'Events')
        event_data = raw_qtm_export.(root{1}).Events;
    else
        event_data = [];
        warning('No event data.')
    end
    
    
    
    
    % import the forces
    if isfield(raw_qtm_export.(root{1}),'Force')
        numFP = size(raw_qtm_export.(root{1}).Force,2); % number of force plates
        
        if strcmp(lab,'HMRL')
            
            % HMRL Force plate geometric offsets fp1 thru 4 [x0,y0,z0]
            fpOrientOffset = [-0.532,	-0.734,	-39.566;
                1.05,	-0.953,	-40.301;
                1.655,	0.712,	-41.471;
                0.986,	-1.728,	-41.688]/1000;
            fpDims = repmat([0.600 0.600],4,1); % dimensions of the force plates
            for f = 1:2
                % force plate relative to the geometric centre
                T_FP_in_geo = eye(4,4);
                T_FP_in_geo(1:3,[1,3]) = -T_FP_in_geo(1:3,[1,3]); % flip the z and x directions to align with global
                T_FP_in_geo(1:3,4) =  fpOrientOffset(1,1:3)';
                
                % geometric centre of the force plate relative to the
                % corner
                T_geo_in_corner = eye(4,4);
                T_geo_in_corner(1:2,4) = [-fpDims(f,1)/2; +fpDims(f,2)/2];
                
                % Force plate relative to the corner
                T_FP_in_corner{f} =   T_geo_in_corner * T_FP_in_geo ;
                
            end
            
            for f = 3:4
                % force plate relative to the geometric centre
                T_FP_in_geo = eye(4,4);
                T_FP_in_geo(1:3,[2,3]) = -T_FP_in_geo(1:3,[2,3]); % flip the z and y directions to align with global
                T_FP_in_geo(1:3,4) =  fpOrientOffset(1,1:3)';
                
                % geometric centre of the force plate relative to the
                % corner
                T_geo_in_corner = eye(4,4);
                T_geo_in_corner(1:2,4) = [-fpDims(f,1)/2; +fpDims(f,2)/2];
                
                % Force plate relative to the corner
                T_FP_in_corner{f} =   T_geo_in_corner * T_FP_in_geo ;
            end
            if f ~=numFP
                warning('Number of force plates in force structure from QTM does not match the number in HMRL. Verify that force plates 1 through 4 are in rows 1 through 4 in QTM export.')
            end
            
        elseif strcmp(lab,'SOL')
            % SOL Force plate geometric offsets fp1 thru fp2 -> needs to be
            % filled in
           
            fpOrientOffset = zeros(2,3); % Optima plates have no geometric offset
            fpDims = repmat([0.400 0.600],4,1);
            for f = 1:2
                % force plate relative to the geometric centre
                T_FP_in_geo = eye(4,4);
                T_FP_in_geo(1:3,[2,3]) = -T_FP_in_geo(1:3,[2,3]); % flip the z and y directions to align with global
                T_FP_in_geo(1:3,4) =  fpOrientOffset(1,1:3)';
                
                % geometric centre of the force plate relative to the
                % corner
                T_geo_in_corner = eye(4,4);
                T_geo_in_corner(1:2,4) = [-fpDims(f,1)/2; +fpDims(f,2)/2];
                
                % Force plate relative to the corner
                T_FP_in_corner{f} =   T_geo_in_corner * T_FP_in_geo ;
            end
            
            if f ~=numFP
                warning('Number of force plates in force structure from QTM does not match the number in SOL. Verify that force plates 1 through 2 are in rows 1 through 2 in QTM export.')
            end
            
        end
        
        
        
        if strcmp(visualise_force_flag,'on')
            figure; plotPointsAndCoordSys1([],eye(4,4),0.5,'r');
        end
        for f = 1:numFP
            force_data(f) = raw_qtm_export.(root{1}).Force(1,f); % we are adding to this structure later so set it up first
            force_data(f).COP = force_data(f).COP;  
            
            fpCorners = raw_qtm_export.(root{1}).Force(f).ForcePlateLocation;
            
            if max(max(abs(fpCorners))) > 50 % if max value is more than 50assume its in millimeters and divide by 1000
                unit_conv = 1;
                warning('Converting force plate location units to meters for %s.',root{1})
            end
            if unit_conv == 1
                force_data(f).COP =   force_data(f).COP/1000;
                fpCorners = fpCorners/1000;
                force_data(f).ForcePlateLocation = fpCorners;
            end
        end
        for f = 1:numFP
            % determine the co-ordinate system relation between the FP
            % co-ordinate system and the global co-ordinate system
          
            fpCorners = force_data(f).ForcePlateLocation;
            T_corner_in_glob = calculateTransformFromCorners(fpCorners,lab);
            
            
            T_FP_in_glob{f} =  T_corner_in_glob * T_FP_in_corner{f};
            
          
            
            force_data(f).FreeMoment = zeros(3,size(force_data(f).Force,2)); % initialize
            force_data(f).FreeMoment(3,:) = force_data(f).Moment(3,:) + force_data(f).COP(2,:) .* force_data(f).Force(1,:) - force_data(f).COP(1,:) .* force_data(f).Force(2,:)  ;% change third row (z) to be free moment
            
            % convert everything to global
            
            force_data(f).globForce = -1 * transformVectors(T_FP_in_glob{f},force_data(f).Force,0); % -1 to convert to force on person
            force_data(f).globMoment = -1 * transformVectors(T_FP_in_glob{f},force_data(f).Moment,0);
            force_data(f).globCOP = transformPoints(T_FP_in_glob{f},force_data(f).COP,0);
            force_data(f).globFreeMoment = -1 * transformVectors(T_FP_in_glob{f},force_data(f).FreeMoment,0);
            
            if  strcmp(filter_flag,'on') % filter the data% filter all the force parameters
                if strcmp(filter_flag,'adaptive') % filter the data
                    if length(fc_force) ~= 2
                        error('When specifying an adaptive filter, the filter cut-off frequency must have a low and a high value.')
                    else
                        
                        force_data(f).globForce = adaptiveLowPassButterworth(force_data(f).globForce,fc_force,force_data(f).Frequency);
                        force_data(f).globMoment = adaptiveLowPassButterworth(force_data(f).globMoment,fc_force,force_data(f).Frequency);
                        force_data(f).globCOP = adaptiveLowPassButterworth(force_data(f).globCOP,fc_force,force_data(f).Frequency);
                        force_data(f).globFreeMoment = adaptiveLowPassButterworth(force_data(f).globFreeMoment,fc_force,force_data(f).Frequency);
                        
                        force_data(f).Force = adaptiveLowPassButterworth(force_data(f).Force,fc_force,force_data(f).Frequency);
                        force_data(f).Moment = adaptiveLowPassButterworth(force_data(f).Moment,fc_force,force_data(f).Frequency);
                        force_data(f).COP = adaptiveLowPassButterworth(force_data(f).COP,fc_force,force_data(f).Frequency);
                        force_data(f).FreeMoment= adaptiveLowPassButterworth(force_data(f).FreeMoment,fc_force,force_data(f).Frequency);
                    end
                    
                else
                    force_data(f).globForce = LowPassButterworth(force_data(f).globForce,4,fc_force,force_data(f).Frequency);
                    force_data(f).globMoment = LowPassButterworth(force_data(f).globMoment,4,fc_force,force_data(f).Frequency);
                    force_data(f).globCOP = LowPassButterworth(force_data(f).globCOP,4,fc_force,force_data(f).Frequency);
                    force_data(f).globFreeMoment = LowPassButterworth(force_data(f).globFreeMoment,4,fc_force,force_data(f).Frequency);
                    
                    force_data(f).Force = LowPassButterworth(force_data(f).Force,4,fc_force,force_data(f).Frequency);
                    force_data(f).Moment = LowPassButterworth(force_data(f).Moment,4,fc_force,force_data(f).Frequency);
                    force_data(f).COP = LowPassButterworth(force_data(f).COP,4,fc_force,force_data(f).Frequency);
                    force_data(f).FreeMoment= LowPassButterworth(force_data(f).FreeMoment,4,fc_force,force_data(f).Frequency);
                end
            end
            
            if strcmp(resample_flag,'force') % downsample the force
                force_fr = raw_qtm_export.(root{1}).Force(1).Frequency;
                t = 0:1/marker_data.FrameRate:1/marker_data.FrameRate*(marker_data.nFrames)-1/marker_data.FrameRate;
                t_interp = 0:1/force_fr: 1/marker_data.FrameRate*(marker_data.nFrames)-1/force_fr;
                
                force_data(f).globForce = interp1(t_interp,force_data(f).globForce',t)';
                force_data(f).globMoment = interp1(t_interp,force_data(f).globMoment',t)';
                force_data(f).globCOP = interp1(t_interp,force_data(f).globCOP',t)';
                force_data(f).globFreeMoment = interp1(t_interp,force_data(f).globFreeMoment',t)';
                
                force_data(f).Force = interp1(t_interp,force_data(f).Force',t)';
                force_data(f).Moment = interp1(t_interp,force_data(f).Moment',t)';
                force_data(f).COP = interp1(t_interp,force_data(f).COP',t)';
                force_data(f).FreeMoment = interp1(t_interp,force_data(f).FreeMoment',t)';
                
                
                force_data(f).Frequency = marker_data.FrameRate;
            end
            
            
            if strcmp(visualise_force_flag,'on') % visualise the forces if it is selected as the option
                hold on;
                for j = 1:25:length(force_data(f).globCOP)
                    plotvector3(force_data(f).globCOP(:,j),force_data(f).globForce(:,j)/1000,'k')
                    hold on;
                end
                plotPointsAndCoordSys1(fpCorners', T_FP_in_glob{f},0.1,'r')
                plotPointsAndCoordSys1([], T_corner_in_glob ,0.1,'r')
                axis equal
            end
        end
    else
        force_data = [];
        warning('No force data.')
        
    end
    
    
    % save the variable marker_data and force_data in a file for easily importing it into
    % the workspace
    if save_proc_flag == 1
        if ~isempty(savedir)
            save(strcat(savedir,'/', root{1},'_processedmotion.mat'),'marker_data', 'force_data')
        else
            save(strcat(pathname,'/', root{1},'_processedmotion.mat'),'marker_data', 'force_data')
        end
    end
    data(i).filename = list_files_mot{i};
    data(i).marker_data = marker_data;
    data(i).force_data = force_data;
    data(i).analog_data = analog_data; 
    data(i).event_data = event_data;
    clearvars -except list_files_mot nfiles varout savedir pathname filter_flag fc_mocap fc_force lab savedir save_proc_flag visualise_force_flag resample_flag data
end

% 
% varargout{1} = data.marker_data;
% varargout{2} = data.force_data;



end

function T = calculateTransformFromCorners(corners,lab)
% look for corner most aligned with global
dist_from_origin = distBtwPoints3xN(corners',zeros(3,4));
if strcmp(lab,'HMRL')
[~,ind] = min(dist_from_origin);
elseif strcmp(lab,'SOL')
    ind = 1;
end
corners_new = corners([ind:4,1:ind-1],:);
T = eye(4,4);
x1 = corners_new (1,:) - corners_new (2,:);
y1 = corners_new (4,:) - corners_new (1,:);

z1 = cross(x1,y1);
x1 = cross(y1,z1);

x1n = x1'/norm(x1);
y1n = y1'/norm(y1);
z1n = z1'/norm(z1);
O = corners_new (1,:)';

T(1:3,1:4) = [x1n, y1n, z1n, O];

end

function dist = distBtwPoints3xN(p1,p2)
% distBtwPoints3xN(p1,p2)

% find the distance between two points that are 3xn or nx3

[r1 c1] = size(p1);
[r2 c2] = size(p2);
flip_flag = 0;
if (r1 ~= r2) || (c1 ~= c2)
    error('Input dimensions of points 1 and 2 do not match.')
end
if r1 == 3
    p1 = p1';
    p2 = p2';
    flip_flag = 1;
end

n = size(p1,1);
% x1 = p1(:,1); x2 = p2(:,1);
% y1 = p1(:,2); y2 = p2(:,2);
% z1 = p1(:,3); z2 = p2(:,3);

for i = 1:n
    dist(i,:) = norm(p1(i,:) - p2(i,:));
end


if flip_flag == 1
    dist = dist';
end
end

function vec_trans = transformVectors(T,vec,direction)

% input a 3xn or nx3 set of vectors and tranform it based on the transformation matrix, out
% put the same orientation transformed vector

% T is either 4x4x1, in which case all vectors will be transformed with
% that transform, OR 4x4xn, in which case it must have the same number n as
% number of vectors to transform

% optional argument direction tells whether the inverse of T is required ->
% direction = 0, no inverse
% direction = 1 or -1 , inverse

% Feb 2019 transformVector ( no s) has been replaced with this function and retired
% 2019 Feb - changed notation to handle -1 as inverse for clarity
%             - also handle when transforms line up with points - i.e.
%             T(:,:,10) corresponds with frame pts(10,:)

[r,c] = size(vec);
% [r,c] = size(pts);
flag_trans = 0;
nT = size(T,3);
% determine number of points, and assess orientation
if r == 3 % rows have 3
    if c == 3 % ambiguous case
        warning('transformVectors.m is treating input points with columns as individual vectors.')
    end
    
    n = c;
    
    if n == 1 && nT > 1 % i.e there are transforms for every point, but only one point
        n = nT;
    end
elseif c == 3
    n = r;
    vec = vec';
    flag_trans = 1;
    if n == 1 && nT > 1 % i.e there are transforms for every point, but only one point
        n = nT;
    end
else
    error('Input point has incorrect dimensions. (Error in transformVectors) ')
    return
end

if nargin == 2
    direction = 0; % set the default if only two inputs are specified
end

if ismember(direction,[-1 1])
    T = invTranspose(T);
end


vec_trans = zeros(3,n);
for i = 1:n % for each point
     if size(T,3) > 1
        Ta = T(:,:,i);
        if size(vec,2) == 1
            vec = repmat(vec,1,n);
        end
    else
        Ta = T;
    end
    vec_temp = Ta * [vec(:,i);0];
    vec_trans(1:3,i) = vec_temp(1:3);
end

if flag_trans == 1 % return the same format as was entered
    vec_trans = vec_trans';
end


end

function pt_trans = transformPoints(T,pts,direction)

% input a 3xnpts point and tranform it based on the transformation matrix, out
% put a 3xn transformed point

% T is either 4x4x1, in which case all vectors will be transformed with
% that transform, OR 4x4xn, in which case it must have the same number n as
% number of vectors to transform

% optional argument direction tells whether the inverse of T is required ->
% direction = 0, no inverse
% direction = 1 or -1 , inverse

% 2018 August - updated to handle row or column orientations of points
% 2019 Feb - changed notation to handle -1 as inverse for clarity
%             - also handle when transforms line up with points - i.e.
%             T(:,:,10) corresponds with frame pts(10,:)

[r,c] = size(pts);
flag_trans = 0;
nT = size(T,3);
% determine number of points, and assess orientation
if r == 3 % rows have 3
    if c == 3 % ambiguous case
        warning('transformPoints.m is treating input points with columns as individual points.')
        
    end
    
    n = c;
    if n == 1 && nT > 1 % i.e there are transforms for every point, but only one point
        n = nT;
    end
elseif c == 3
    n = r;
    pts = pts';
    flag_trans = 1;
    if n == 1 && nT > 1 % i.e there are transforms for every point, but only one point
        n = nT;
    end
else
    error('Input point has incorrect dimensions. (Error in transformPoints) ')
    return
end

if nargin == 2
    direction = 0; % set the default if only two inputs are specified
end

if ismember(direction,[-1 1])
    T = invTranspose(T);
end

pt_trans = zeros(3,n);
for i = 1:n % for each point/transform
    if nT > 1
        Ta = T(:,:,i);
        if size(pts,2) == 1
            pts= repmat(pts,1,n);
        end
    else
        Ta = T;
    end
    pt_temp = Ta * [pts(:,i);1];
    pt_trans(1:3,i) = pt_temp(1:3);
end

if flag_trans == 1 % return the same format as was entered
    pt_trans = pt_trans';
end

end




function T_inv = invTranspose(T)

R = T(1:3,1:3);
R_inv = R';
v_inv = -R_inv * T(1:3,4);
T_inv = eye(4,4);

T_inv(1:3,1:3)= R_inv;
T_inv(1:3,4) = v_inv;
end

