function varargout = MocapDataTransform(varargin)
% load the motion data and save it to an easily manipulated variable
% saves marker_data, force_data in a variable with the same file name and
% _processedmotion at the end
% --- also filters the motion capture data using a lowpass butterworth
% filter, 4th order, cutoff 5 Hz ----------------
% Can be used as:
% MocapDataTransform() where the user will be prompted to select the files
% MocapDataTransform(filename) where filename is a string or
% a cell array of strings of the QTM exported mat files.
% or MocapDataTransform(filename,savedir) where  pathname will save the
% files in a specific location (Dec 15/2015)


if nargin == 0
    [list_files_mot, pathname,~] = uigetfile({'*.mat' 'MAT Files'}, 'Qualisys Motion file...','MultiSelect','on');
    % If the path is not on the MATLAB path, add it, and change the current
    % directory to be that path
    addpath(genpath(pathname))
    cd(pathname)
elseif nargin == 1
    list_files_mot = varargin{1};
        [pathname,~,~] = fileparts(list_files_mot); % determine the name of the trial
elseif nargin == 2
    list_files_mot = varargin{1};
    savedir = varargin{2};
end


if ~iscell(list_files_mot) % if only one file is loaded, it's loaded as a string not a cell array
    
    temp = list_files_mot;
    clear('list_files_mot')
    list_files_mot{1} = temp;
    nfiles = 1;
else
    nfiles = length(list_files_mot);
end


for i = 1:nfiles
    %      if ~isempty(strfind(list_files_mot{i},'processed'))
    %         continue % don't iterate if it's already been processed (i.e. has 'processed' in the filename
    %     end
    raw_qtm_export = load(list_files_mot{i}); % load the motion file

    root = fields(raw_qtm_export);
    disp((root{1}));
    if isfield(raw_qtm_export.(root{1}).Trajectories.Labeled,'Labels')
        for j= 1:size(raw_qtm_export.(root{1}).Trajectories.Labeled.Labels,2);
            % take the imported data and organize it in a sructure called
            % marker_data with the fields "marker name", "number of frames" and
            % "frame rate"
            marker_name = raw_qtm_export.(root{1}).Trajectories.Labeled.Labels{j};
            if isstrprop(marker_name(1),'digit') % if the first element of the marker name is a digit, then it needs to be put at the end as matlab doesn't like variables that start with numbers
                marker_name = [marker_name(2:end) marker_name(1)];
            end
            n = length(marker_name);
            if n ~= 3
                marker_name(3)= '_';
            end
            marker_data.nFrames = raw_qtm_export.(root{1}).Frames;
            marker_data.FrameRate = raw_qtm_export.(root{1}).FrameRate;
            
            m_temp = squeeze((raw_qtm_export.(root{1}).Trajectories.Labeled.Data(j,1:3,:)));
            
            ind = isnan(m_temp);
            m_temp(ind) = 0;
%             frs = find(ind == 1);
%             if sum(sum(ind)) ~= 0
%                 warning(['NaN values were replaced with 0 for frames ' num2str(frs(1)) ' to ' num2str(frs(end))  ' for trial ' root{1} ' marker ' marker_name])
%             end
            
            for k = 1:3
                m_filt(k,:) = LowPassButterworth(m_temp(k,:),4,10,marker_data.FrameRate);
            end
            
            marker_data.(marker_name)(:,:) = m_filt;
            marker_data.(marker_name)(ind) = NaN;
            clear m_filt
            
        end
    else
        disp(sprintf('The markers in file %s are not labelled', (root{1})));
        marker_data = [];
    end
    
    % import the forces
    if isfield(raw_qtm_export.(root{1}),'Force')
        numFP = size(raw_qtm_export.(root{1}).Force,2); % number of force plates
        for j = 1:numFP
            %
            %             fpname = raw_qtm_export.(root{1}).Force(1,j).ForcePlateName;
            %             fpname = fpname(~isspace(fpname)); % remove the spaces
            %             fpname = strrep(fpname,'-','_'); % remove invalid characters
            
            force_data(j) = raw_qtm_export.(root{1}).Force(1,j);
            if ~isempty(force_data(j).Force)
                for k = 1:3
                    force_data(j).Force(k,:) = LowPassButterworth(force_data(j).Force(k,:),4,6,force_data(j).Frequency);
                end
            end
        end
    else
        force_data(j) = [];
        disp('No force data')
        
    end
    
    
    % save the variable marker_data and force_data in a file for easily importing it into
    % the workspace
    if exist('savedir','var')
        save(strcat(savedir,'/', root{1},'_processedmotion.mat'),'marker_data', 'force_data')
    else
        save(strcat(pathname,'/', root{1},'_processedmotion.mat'),'marker_data', 'force_data')
    end
    varout(i).marker_data = marker_data;
    varout(i).force_data = force_data;
    
    clearvars -except list_files_mot nfiles varout savedir pathname
end

if nargout == 1
    varargout{1} = varout;
end



end