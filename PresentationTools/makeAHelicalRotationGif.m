
%make an animation with a helical axis 

% rotate a pose matrix around a helical axis 

% data from Zoe's bonestruct
tib_pose = bonestruct.tib.inertiaACS;
tal_pose = bonestruct.tal.inertiaACS;
cal_pose = bonestruct.cal.inertiaACS;

tib_tal = invTranspose(tal_pose)*tib_pose;
tal_tal = invTranspose(tal_pose)*tal_pose;
cal_tal = invTranspose(tal_pose)*cal_pose;

inv_tal = invTranspose(tal_pose);


ivstring = createInventorHeader();

ivstring = [ivstring createInventorLink( 'P:\Data\2017-10-13_SOL001_Cleaned\Models\IV\aligned_beadless\SOL001_cal_aligned.iv',inv_tal(1:3,1:3),inv_tal(1:3,4),[0 0.4 0.8],0)];
ivstring = [ivstring createInventorLink( 'P:\Data\2017-10-13_SOL001_Cleaned\Models\IV\aligned_beadless\SOL001_tal_aligned.iv',inv_tal(1:3,1:3),inv_tal(1:3,4),[0 0.4 0.8],0)];
trans = 0;
q = [0 0 0];
n = [-1 0 0.2]';
n = n/norm(n);
ivstring =  [ivstring createInventorArrow(q,n,150, 3,[0.5 0 0.1],0)];
for phi =10%10:10:50
% phi = 10;

[R,T] = Helical_To_RT(phi, n, trans, q);
Tt = eye(4);
Tt(1:3,1:3) = R;
Tt(1:3,4) = T;



tib_tal = Tt *(inv_tal);
cal_tal = (inv_tal);


% 
% ivstring = [ivstring createInventorLink( 'P:\Data\2017-10-13_SOL001_Cleaned\Models\IV\aligned_beadless\SOL001_tib_aligned.iv',eye(3),zeros(3,1),[0 0.1 0.5],0)];
% ivstring = [ivstring createInventorLink( 'P:\Data\2017-10-13_SOL001_Cleaned\Models\IV\aligned_beadless\SOL001_cal_aligned.iv',eye(3),zeros(3,1),[0 0.1 0.5],0)];
% ivstring = [ivstring createInventorLink( 'P:\Data\2017-10-13_SOL001_Cleaned\Models\IV\aligned_beadless\SOL001_tal_aligned.iv',eye(3),zeros(3,1),[0 0.1 0.5],0)];

% ivstring = [ivstring createInventorLink( 'P:\Data\2017-10-13_SOL001_Cleaned\Models\IV\aligned_beadless\SOL001_tib_aligned.iv',inv_tal(1:3,1:3),inv_tal(1:3,4),[0 0.1 0.5],0)];
% ivstring = [ivstring createInventorLink( 'P:\Data\2017-10-13_SOL001_Cleaned\Models\IV\aligned_beadless\SOL001_cal_aligned.iv',inv_tal(1:3,1:3),inv_tal(1:3,4),[0 0.1 0.5],0)];
% ivstring = [ivstring createInventorLink( 'P:\Data\2017-10-13_SOL001_Cleaned\Models\IV\aligned_beadless\SOL001_tal_aligned.iv',inv_tal(1:3,1:3),inv_tal(1:3,4),[0 0.1 0.5],0)];

ivstring = [ivstring createInventorLink( 'P:\Data\2017-10-13_SOL001_Cleaned\Models\IV\aligned_beadless\SOL001_tib_aligned.iv',tib_tal(1:3,1:3),tib_tal(1:3,4),[0.5+(phi)*0.01 0.5+(phi)*0.01 0.5+(phi)*0.01],0)];

% ivstring =  [ivstring createInventorArrow([0 0 0],tal_tal(1:3,2),150, 3,[0 1 0],0)];
% ivstring =  [ivstring createInventorArrow([0 0 0],tal_tal(1:3,3),150, 3,[0 0 1],0)];

ivstring = [ivstring createInventorArrow(q,n,150, 3,[0.1 0.1 0.5],0)];
end
fid = fopen('C:\Users\Lauren\Documents\School\PhD\Presentations\Figures\helical_gif.iv','w');
            fprintf(fid,ivstring);
            fclose(fid);