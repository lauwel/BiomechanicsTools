
close all
clear
clc
ivDir = 'E:\PRFC003\Models\IV\3Aligned Reduced\';
writeFile = 'C:\Users\Lauren\OneDrive - Queen''s University\Research\PhD\Seminar\CTbones.iv';
arch_bones = {'cal','tal','nav','cmm','mt1','ph1'};




list_files = dir([ivDir, '*.iv']);

load([ivDir 'bonestruct.mat'])


for b = 1:length(list_files)
    
   file_spl = strsplit(list_files(b).name,'_');
   boneout = 0; st = 0;
    while boneout == 0 && st < length(file_spl) % while the bone hasn't been found, or the # of split parts of the file is exceeded
        st = st + 1;
        boneout = bonecodeFT(file_spl{st}); 
    end
    if st < length(file_spl)
        bonesCell{b} = file_spl{st};
        file_list{b} = [ivDir,list_files(b).name];
    end
    
    
end
nBones = length(bonesCell);

ivstring = createInventorHeader();

for b = 1:nBones
    
    if strcmp(bonesCell{b},'tib')
        tib_pose = bonestruct.tib.T_Aligned;
        tal_pose = bonestruct.tal.T_ACS.T_TC;
        inv_tal = invTranspose(tal_pose);
        tib_tal = inv_tal*tib_pose;
        
        trans = 0;
        q = [0 0 0];
        n = [1 0 0 ];%tal_pose(1:3,3)';
        n = n/norm(n);
        phi = -40;
        [R,T] = Helical_To_RT(phi, n, trans, q);
        Tt = eye(4);
        Tt(1:3,1:3) = R;
        Tt(1:3,4) = T;
        
        T_CT =tal_pose* Tt *(inv_tal);
    elseif strcmp(bonesCell{b},'fib')
         fib_pose = bonestruct.fib.T_Aligned;
        tal_pose = bonestruct.tal.T_ACS.T_TC;
        inv_tal = invTranspose(tal_pose);
        tib_tal = inv_tal*fib_pose;
        
        trans = 0;
        q = [0 0 0];
        n = [1 0 0 ];%tal_pose(1:3,3)';
        n = n/norm(n);
        phi = -40;
        [R,T] = Helical_To_RT(phi, n, trans, q);
        Tt = eye(4);
        Tt(1:3,1:3) = R;
        Tt(1:3,4) = T;
        
        T_CT =tal_pose* Tt *(inv_tal);
        
%     elseif strcmp(bonesCell{b},'ph1')
%            ph1_pose = bonestruct.tib.T_Aligned;
%         tal_pose = bonestruct.tal.T_ACS.T_TC;
%         inv_tal = invTranspose(tal_pose);
%         tib_tal = inv_tal*ph1_pose;
%         
%         trans = 0;
%         q = [0 0 0];
%         n = tal_pose(1:3,3)';
%         n = n/norm(n);
%         phi = 30;
%         [R,T] = Helical_To_RT(phi, n, trans, q);
%         Tt = eye(4);
%         Tt(1:3,1:3) = R;
%         Tt(1:3,4) = T;
%         
%         T_CT = Tt *(inv_tal);
        
    else
        T_CT = eye(4,4);
    end
    
    if any(contains(arch_bones,bonesCell{b}))
        col = [0 0.7 0.7];
    else
        col = [0.7 0.7 0.7];
    end
    
    trans = 0.2;
    
    ivstring = [ivstring createInventorLink(file_list{b},T_CT(1:3,1:3),T_CT(1:3,4)',col,trans)];
    
end

fid = fopen(writeFile,'w');
fprintf(fid,ivstring)
fclose(fid);

