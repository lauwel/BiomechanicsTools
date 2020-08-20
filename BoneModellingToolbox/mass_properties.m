function [Centroid,SurfaceArea,Volume,CoM_ev123,CoM_eigenvectors,I1,I2,I_CoM,I_origin,patches] = mass_properties(varargin)
%function [Centroid,SurfaceArea,Volume,CoM_ev123,CoM_eigenvectors,I1,I2,I_CoM,I_origin,patches] = mass_properties(ivFile)
%
% Given an IV file (or any tesselated surface) it will compute the basic
% properties for the given object. Calculations are based on the Divergence
% Theorem
%
%   mass_properties(), will pop up a dialog box asking the user to
%     select the file for analysis.
%
%   mass_properties(ivFname), will read in the file specified
%
%   mass_properties(filepath, ivFname), will read in the ivFname in the
%     directory specified by filepath.
%
%   mass_properties(pts, conn), Will use the object specified by the pts
%     and connections passed as command line options instead of reading
%     them in from disk. Usefull when manipulating IV files, and are trying
%     to avoid writing temporary files to disk.
%
%   Outputs:
%   [Centroid,SurfaceArea,Volume,CoM_ev123,CoM_eigenvectors,I1,I2,I_CoM,
%   I_origin,patches]
%
%       Centroid - The centroid of the object
%       SurfaceArea - The total surface area of all the triangles
%       Volume - The volume of the object assuming a closed surface
%       CoM_ev123 - The Eigenvalues
%       CoM_eigenvectors - The Eigenvectors, or the unit vectors desribing
%           the inertial axes
%       I1,I2 - The first and second invariants
%       I_CoM - Inertia about the bone center of mass represented in the
%          bone coordinate system. The diagnal are the Eigvenvalues (same
%          as the CoM_ev123.
%       I_origin - Inertia about the bone center of mass represented in the
%          CT coordinate space (or global space)
%       patches - ?
%

% ************************************************************************
% Finds MASS PROPERTIES of a 3D triangular .IV mesh
% ************************************************************************
% vtkMassProperties.  Reference: D. Eberly, J. Lancaster, A. Alyassin, "On
% gray scale image measurements, II. Surface area and volume", CVGIP:
% Graphical Models and Image Processing, vol. 53, no.6, pp.550-562, 1991.
%
% Uses Divergence Theorem to convert volume integration to an area
% integral over the boundary of the region formed by the triangular
% mesh. The function integrated to get volume is (x,y,z)/3.  The function
% integrated to get centroid is (x^2,y^2,z^2)/2.  For volume the "/3"
% factors are optimized by using VTK method of MUNC (maximum unit normal 
% component algorithm).
%
% Methods for inertia and principal axes calculation developed and implemented by
% Anwar Upal.  They also use the Divergence Theorem.
% Time is only the time it takes to calculate the inertia CoM, it excludes all other
% calculations volume etc.
% 
% Written by Anwar M. Upal 
% Last Modified May 19th, 2003
% 
% 1/22/07 - E. Leventhal. Changed to use read_vrml_fast instead of
% split_iv
% ************************************************************************
% [Centroid,SurfaceArea,Volume,CoM_eigenvalues,CoM_eigenvectors,I1,I2,I_CoM,I_origin] = mass_properties(filepath,ivFile);


% Check for the case where we were run without arguments.
if (nargin == 0)
    [ivFile,filepath] = uigetfile('*.iv','SELECT ANY FILE TO FIND MASS PROPERTIES!!!');
    varargin{1} = fullfile(filepath, ivFile); %setup to use a single filename
end;

% now lets check for the case of a filename and filepath
if (nargin==2 && ischar(varargin{1}) && ischar(varargin{2}))
   varargin{1} = fullfile(varargin{1},varargin{2});
end

if (ischar(varargin{1})) %we were passed a filename
    % read in the IV file, and then remove the extra -1 field. Also correct for
    % matlab 1 based index instead of 0 based.
    [points connection] = read_vrml_fast(varargin{1});
    connection(:,4) = [];
    connection = connection + 1;
elseif (nargin==2 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && size(varargin{1},2)==3 && size(varargin{2},2)>=3)
    %we should have pts and conn passed then :)
    points = varargin{1};
    connection = varargin{2};
    if (size(connection,2)==4) %if we have extra clear it
        connection(:,4)= []; 
    end
    if (min(min(connection))==0) %if the index was not corrected, correct
        warning('MassProperties:ConnIndex','Connection matrix appears to be still 0-indexed, adding 1 to all indices');
        connection = connection + 1;
    end;
else
    error('MassProperties:Arugments', 'No ivFile or pts & conn were passed in');
end


[I_origin,origin_eigenvectors,origin_eigenvalues] = i_origin_iv(points,connection);
[Volume,VolumeX,VolumeY,VolumeZ,NormalizedShapeIndex,patches] = volume_iv(points,connection);
Centroid = CoM_iv(points,connection,Volume);
[I_CoM,CoM_eigenvectors,CoM_eigenvalues,time] = i_CoM_iv(points,connection,Centroid);
SurfaceArea = surface_area_iv(points,connection);
[I1,I2,J1,J2,d2] = invariants_iv(points,connection,I_CoM);

%Reformat the output here...

double(Centroid);
double(SurfaceArea);
double(Volume);

CoM_ev123 = [CoM_eigenvalues(1,1) CoM_eigenvalues(2,2) CoM_eigenvalues(3,3)];
%negated to match GetPos output, see below
%A. Upal & E. Leventhal - 12/20/04
CoM_ev123 = -CoM_ev123;


%transpose gives different values from equivilant GetPos command from
%Inertia_Reg. Modified to give similar output
%A. Upal & E. Leventhal - 12/20/04
%CoM_eigenvectors = CoM_eigenvectors'

%check to make sure that we return a right handed matrix
if (det(CoM_eigenvectors)<0),
    CoM_eigenvectors = -CoM_eigenvectors;
end;

%check for closed surface!
if (abs(VolumeX-VolumeY)>1e-6 || abs(VolumeY-VolumeZ)>1e-6)
    fprintf(1, 'Make Sure Mesh is Closed!\n');    
end;

%now display the output if appropriate
%only show the output on stdout if the user is not saving the results
if (nargout==0)

  %  fprintf(1, '\n\n***********Mass Properties for %s: *************\n\n', ivFile);

    if (abs(VolumeX-VolumeY)<1e-6 && abs(VolumeY-VolumeZ)<1e-6)
        fprintf(1, 'Volume (cubic millimeters):  %f\n\n', Volume);
    else
        fprintf(1, 'VolumeX (cubic millimeters): %f\n', VolumeX);
        fprintf(1, 'VolumeY (cubic millimeters): %f\n', VolumeY);
        fprintf(1, 'VolumeZ (cubic millimeters): %f\n\n', VolumeZ);
    end;

    fprintf(1, 'Normalized Shape Index: %f\n\n',  NormalizedShapeIndex);
    fprintf(1, 'Surface Area (square millimeters): %f\n\n', SurfaceArea);
    fprintf(1, 'Center of Mass (millimeters): %f %f %f\n\n',  Centroid);

    fprintf(1, 'Inertia about CT origin: \n');
    fprintf(1, '        Aligned with the output coordinate system: \n');
    fprintf(1, 'Ixx:%f     Ixy:%f     Ixz:%f \n',  I_origin(1,1), I_origin(1,2), I_origin(1,3));
    fprintf(1, 'Iyx:%f     Iyy:%f     Iyz:%f \n',  I_origin(2,1), I_origin(2,2), I_origin(2,3));
    fprintf(1, 'Izx:%f     Izy:%f     Izz:%f \n\n',I_origin(3,1), I_origin(3,2), I_origin(3,3));

    fprintf(1, 'Inertia about bone Center of Mass: \n');
    fprintf(1, '        Aligned with the output coordinate system: \n');
    fprintf(1, 'Ixx:%f     Ixy:%f     Ixz:%f \n',  I_CoM(1,1), I_CoM(1,2), I_CoM(1,3));
    fprintf(1, 'Iyx:%f     Iyy:%f     Iyz:%f \n',  I_CoM(2,1), I_CoM(2,2), I_CoM(2,3));
    fprintf(1, 'Izx:%f     Izy:%f     Izz:%f \n\n',I_CoM(3,1), I_CoM(3,2), I_CoM(3,3));

    fprintf(1, 'Principal Moments of Inertia: \n');
    fprintf(1, 'P1:%f     P2:%f     P3:%f \n\n',  CoM_eigenvalues(1,1), CoM_eigenvalues(2,2), CoM_eigenvalues(3,3));

    fprintf(1, 'Principal Axes of Inertia: \n');
    fprintf(1, 'u1x:%f     u1y:%f     u1z:%f \n',  CoM_eigenvectors(1,1), CoM_eigenvectors(2,1), CoM_eigenvectors(3,1));
    fprintf(1, 'u2x:%f     u2y:%f     u2z:%f \n',  CoM_eigenvectors(1,2), CoM_eigenvectors(2,2), CoM_eigenvectors(3,2));
    fprintf(1, 'u3x:%f     u3y:%f     u3z:%f \n\n',CoM_eigenvectors(1,3), CoM_eigenvectors(2,3), CoM_eigenvectors(3,3));

    fprintf(1, 'Invariants: \n');
    fprintf(1, 'I1: %f \t',I1);
    fprintf(1, 'I2: %f\n',I2);

end;