function [avgHAM,num,variat] = calcAvgMotion(kinemat,checkNums);
% Usage:   [avgHAM, num] = calcAvgMotion(kinemat, checkNums)
%
% Inputs:   kinemat -   a) a kinemat structure, pre-loaded
%                       b) a kinemat file name, not yet loaded
%                       c) a list of HAMs
%		    checkNums(optional) - array of numbers corresponding to kinemat
%		    rows to check  (ie checkNums = 2:5, only use kinemat(2:5))
%           [phi,n,L,s]in each row
% Ouputs:   avgHAM - the Average HAM
%           num - The number of subjects and series that went INTO that average HAM
%           variat - variation of orientation of each included HAM from the
%               average (angle between them)

threshold_phi = 0.1;

count = 1;
if isa(kinemat, 'double') % In case input is a list of HAMs, handle it as such and weed out small angles
    for ii = 1:size(kinemat,1)
    
        myHAM = kinemat(ii,:);
        
        if myHAM(1) < threshold_phi   %If phi is smaller than a threshold value, don't include
            fprintf('Skipped.  Angle too small. Frame = %i \n',ii); 
        else 
            allQuat{1}(count,:) = double(quaternion(myHAM(2:4),myHAM(1)*pi/180));
            if ii ~= 1
                gg = dot(allQuat{1}(count,:),allQuat{1}(1,:));
                if (gg < 0)
                    allQuat{1}(count,:) = -allQuat{1}(count,:);
                end
            end
            allHAM{1}(count,:) = myHAM;
            count = count + 1;
        end
    end
    
    count = count - 1;
    
    if ~exist('allQuat','var')
        warning('Minimum threshold was not met. No average found')
        avgHAM = zeros(8,1);
        num = [];
        variat = 0;
        return
    end
    
    avgHAM = avgCalc(allQuat,allHAM,count);
    
    for ii = 1:count % L. W. added variation from average helical axis using the computed angle for each included axis from the average
        variat(ii) =  acosd( dot(allHAM{1}(ii,2:4),avgHAM(2:4)) / (norm(allHAM{1}(ii,2:4))*norm(avgHAM(2:4))) );
    end
    num = [];
else
    if isa(kinemat, 'char') %See if it's a file name
        kinemat = load(kinemat);
    end
    if ~exist('checkNums')
        checkNums = 1:size(kinemat,2);
    end
    for boneCount = 1:size(kinemat(1).selBone,1)
        count = 0;
        for subjCount = checkNums
            for serCount = 1:size(kinemat(subjCount).RTdata,1)
                count = count + 1;
                myHAM = kinemat(subjCount).RTdata{serCount,3}(boneCount,:);
                if myHAM(1) < threshold_phi    %NEW MODIFICATION
                    count = count -1;   %%%%
                    disp('Skipped.  Angle too small.'); %%%%
                else %%%%
                    allQuat{boneCount}(count,:) = double(quaternion(myHAM(2:4),myHAM(1)*pi/180));
                    allHAM{boneCount}(count,:) = myHAM;
                    if (count ~= 1)
                        gg = dot(allQuat{boneCount}(count,:),allQuat{boneCount}(1,:));
                        if (gg < 0)
                            allQuat{boneCount}(count,:) = -allQuat{boneCount}(count,:);
                        end
                    end
                end %end of if myHAM(1)
            end %end of for serCount;
        end %end of for subjCount;
        avgHAM(boneCount,:) = avgCalc(allQuat,allHAM,count,boneCount);
        num(boneCount) = size(allQuat{boneCount},1);
    end % end of for boneCount;
end

end

function [avgHAM] = avgCalc(allQuat,allHAM,count,boneCount);

if ~exist('count'),
    count = size(allHAM{1},1);
end;
if ~exist('boneCount'),
    boneCount = 1;
end;
if count ==1,
    warning('Only averaging one position');
end;
sumQuat = sum(allQuat{boneCount},1);
avgQuat = sumQuat/norm(sumQuat);
% [avgPhi,avgN] = q2Axis(quaternion(avgQuat));
avgPhi = 2*acos(avgQuat(1))*180/pi;
avgN = avgQuat(2:4);
avgN = avgN/norm(avgN);
avgT = sum(allHAM{boneCount}(:,5),1)/count;
avgQLoc = sum(allHAM{boneCount}(:,6:8),1)/count;
avgHAM = [avgPhi,avgN,avgT,avgQLoc];

end
