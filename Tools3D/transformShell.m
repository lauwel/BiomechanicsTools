function [varargout] = transformShell(RT,statTform,direction,points);
% [varargout] = transformShell(RT,statTform,direction,points);
% Shell checking data input and then using doTransform to calculate
% appropriate transform.  Can transform either RTs or point cloud data
% 
% Inputs:   RT - EITHER 4x3 matrix comprising a Rotation and Translation or a
%                list of points to be transformed
%           statTform - 4x3 matrix comprising the Rotation and Translation
%                       to apply to RT
%           direction -  1 applies a forward transform 
%                       -1 does backward transform
%           points - If you are transforming points specify 1 otherwise, 0
%
% Outputs:
%   if 1 output - either a list of points or an [R;T] matrix
%   if 2 outputs - R and T as separate variables.  No equivalent in points
%
% J. Coburn 06/04/03

if all(size(RT) ~= 3),
    error('MATLAB:doTransform:badInput','First parameter must be in a 3xn or nx3 matrix. \rReformat input data.');
elseif size(RT,2) ~= 3,
    RT = RT';
end;

if ~exist('direction'),
    direction = 1;
end;

try,
    % Check points variable
    if exist('points')
        if points == 1,   % Treat as points
            [pts] = doTransform(RT,statTform,direction,points);
		else,   % Treat as RT
            for ii = 1:size(RT,1)/4,
                ind = 1 + ((ii-1)*4);
                [Rg{ii},Tg{ii}] = doTransform(RT(ind:ind+3,:),statTform,direction,points);
            end;
		end;
	else,   %The points variable doesn't exist.  Go through tests
        points = 0;
      
        if isa(RT,'cell'), % Only use cell arrays with RTs
            max = size(RT,2);
            for ii = 1:size(RT,2),
                [Rg{ii},Tg{ii}] = doTransform(RT{ii},statTform,direction,points);
            end;
            Tg = Tg';
        elseif mod(size(RT,1),4) == 0, %Check if the rows are a multiple of 4
            R = RT(1:3,:);
            verdict = testRotation(R);  %check the first three rows for rotationality
            if verdict,
                for ii = 1:size(RT,1)/4,
                    ind = 1 + ((ii-1)*4);
                    [Rg{ii},Tg{ii}] = doTransform(RT(ind:ind+3,:),statTform,direction,points);
                end;
                Tg = Tg';
                % If the first three rows make identity and the fourth row
                % is magnitude 1 then it might not actually be a rotation
                if (norm(RT(4,:)) == 1) | (R == eye(3) & ~exist('points')),
                    msgbox('Data treated as rotation matrices but tests show there is a possibility that data is a set of points. Refer to Matlab window for more information.','Data Type Warning','warn','modal');
                    fprintf('\aThe input data set has met specific conditions that make the type of data ambiguous.\n');
                    fprintf('If this input data is a set of points, specify another parameter after direction.\n');
                    fprintf('This parameter equals 0 if the data is RT and 1 if it is a point set.\n');
                    error('MATLAB:transformShell:ambiguous','Rerun program if the wrong data type has been executed.\n');
                end;
            else, % Fails rotation condition
                points = 1;
                [pts] = doTransform(RT,statTform,direction,points);
            end; %end if verdict
        else, %rows aren't a multiple of 4
            points = 1;
            [pts] = doTransform(RT,statTform,direction,points);
        end; %end if isa(RT
	end; % end exist points
    
catch,
    rethrow(lasterror)
end;

if nargout == 1 | nargout == 0,
    if points == 1,
        RTg = pts;
    else,
        RTg = [];
        for ii = 1:size(Tg,1),
            RTg = [RTg;Rg{ii};Tg{ii}];
        end;
    end;
    varargout{1} = RTg;
else,
    if points == 1,
        Rg = pts;
        Tg = 'Your points have been assimilated.';
    end;
    if size(RT,1)/4 == 1,
        Rg = Rg{1};
        Tg = Tg{1};
    end;    
    varargout{1} = Rg;
    varargout{2} = Tg;
end;