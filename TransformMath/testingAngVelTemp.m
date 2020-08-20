
for deg = 1:70
T(:,:,1) = eye(4,4);
T(:,:,2) = rotateCoordSys(rotateCoordSys(T(:,:,1),deg,1),0,2);
T(:,:,3) = rotateCoordSys(rotateCoordSys(T(:,:,2),deg,1),0,2);
% T(:,:,4) = rotateCoordSys(rotateCoordSys(T(:,:,3),deg,1),0,2);
% T(:,:,5) = rotateCoordSys(rotateCoordSys(T(:,:,4),deg,1),0,2);
% T(:,:,6) = rotateCoordSys(rotateCoordSys(T(:,:,5),deg,1),0,2);
% figure;
% 
% for i = 1:3
%     hold on;
%     plotPointsAndCoordSys1([],T(:,:,i),1,'k')
% end
Fs = 1;

w = calculateRotMatAngularVelocity(T(1:3,1:3,:),Fs);
% w = w*180/pi()
w_save(:,deg) = w(:,2);
end
figure;

plot(1:70,1:70); hold on;
plot(1:70,w_save(1,:))
err = [1:70]-w_save(1,:);
figure;
plot(err)