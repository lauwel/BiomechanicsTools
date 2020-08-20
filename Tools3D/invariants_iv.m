function [I1,I2,J1,J2,d2] = invariants_iv(points,connection,I_CoM)

%% ************************************************************************
%% Finds INVARIANTS of a 3D triangular .IV mesh
%% ************************************************************************
%% These invariants do not vary with orientation or scaling of bone.
%%
%% Written by Anwar M. Upal 
%% Last Modified May 19th, 2003
%% ************************************************************************

if (nargin == 0)
    [ivFile,filepath] = uigetfile('*.iv','SELECT ANY FILE TO FIND INVARIANTS!!!');
end;

if (exist('I_CoM')~=1),
    [I_CoM,CoM_eigenvectors,CoM_eigenvalues] = i_CoM_iv(points,connection);
end;

J1 = I_CoM(1,1) + I_CoM(2,2) + I_CoM(3,3);
J2 = I_CoM(2,2) * I_CoM(3,3) - I_CoM(3,2)^2 + I_CoM(1,1) * I_CoM(3,3) - I_CoM(3,1)^2 ...
    + I_CoM(1,1) * I_CoM(2,2) - I_CoM(1,2)^2;
d2 = det(I_CoM);

I1 = (J1^2)/J2; I2 = d2/(J1^3);
%fprintf(1, 'Filename : %s\n',ivFile);
%fprintf(1, 'Inertia about bone Center of Mass: \n');
%fprintf(1, '        Aligned with the output coordinate system: \n');
%fprintf(1, 'Ixx:%f     Ixy:%f     Ixz:%f \n',  I_CoM(1,1), I_CoM(2,1), I_CoM(3,1));
%fprintf(1, 'Iyx:%f     Iyy:%f     Iyz:%f \n',  I_CoM(1,2), I_CoM(2,2), I_CoM(3,2));
%fprintf(1, 'Izx:%f     Izy:%f     Izz:%f \n\n',I_CoM(1,3), I_CoM(2,3), I_CoM(3,3));

%fprintf(1, 'J1: %f \t ',  J1);
%fprintf(1, 'J2: %f \t', J2);
%fprintf(1, 'd2: %f\n\n',  d2);

%fprintf(1, 'I1: %f \t',I1);
%fprintf(1, 'I2: %f\n',I2);