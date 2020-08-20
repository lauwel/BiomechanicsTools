function T_44 = convertRTp_T(filename)

% input an RTp file and get out the T matrix

RTp = dlmread(filename);
n_fr = RTp(1,1); % number of frames of tracked data

% make the RTP file format into a series of 4x4x nframe matrices to
% save into the structure
T_44 = repmat(eye(4,4),1,1,n_fr);

for k = 1:n_fr
    T_44(1:3,1:3,k) = RTp((4*k-3)+1:(4*k),1:3);
    T_44(1:3,4,k) = RTp(4*k+1,1:3)';
end