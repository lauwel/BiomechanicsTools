function t_new = optimizeCongruence(centrs_pts,dfield,T_pts,T_df)
% centrs = points to test in the dfield 
% dfield = dfield of bone being moved
% T_pts = transform for centres
% T_df      = transforms for position of the dfield bone
% this will optimize the translation of T to make it congruent

t0 = T_pts(1:3,4)';
%     t_new = particleswarm(@minimizeMeanDist,3,
    lb = t0+[-10 -10 -10];
    ub = t0+[10 10 10];
    
 options = optimoptions(@fmincon,'MaxIter',10000);
 
t_new = fmincon(@minimizeMeanDist,t0,[],[],[],[],lb,ub,@myCon,options);

    function mean_dist = minimizeMeanDist(t)
        T_pts(1:3,4) = t';
        centrs = transformPoints(T_pts,centrs_pts);
        dists = lookUpDfieldPts(dfield,centrs,T_df(1:3,1:3),T_df(1:3,4)');
        I = dists>0;
        
        mean_dist = abs(mean(dists(I)));
        
%         plot3quick(centrs,'k','.','none');
%         plot3quick(centrs,'k','.','none');
%         drawnow
    end
    function [c,ceq] = myCon(t) 
        T_pts(1:3,4) = t';
        centrs = transformPoints(T_pts,centrs_pts);
        c = -min(lookUpDfieldPts(dfield,centrs,T_df(1:3,1:3),T_df(1:3,4)')); % c must be <= 0 to be okay
        ceq = [];
    end
end