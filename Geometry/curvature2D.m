function k = curvature2D(y)
% compute curvature of a 2D line
% Input is a symbolic 2x1 array that's parameterized as a function of x
% i.e. y = [x ; cos(x)] , where the second function can be anything as a
% function of x.
% outputs curvature as a function of x

dy_dt = diff(y,y(1));

dy_dt_mag = norm(dy_dt);
dy_dt_mag = subs(dy_dt_mag,abs(cos(y(1)))^2 + abs(sin(y(1)))^2,1);

T = dy_dt/dy_dt_mag; % unit tangent vector

dT_dt = diff(T,y(1)); % derivative of tangent vector

dT_dt_mag = simplify(norm(dT_dt)); %|| dT/dt || -> how much the unit tangent vector changes direction wrt time
dT_dt_mag  = subs(dT_dt_mag,abs(cos(y(1)))^2 + abs(sin(y(1)))^2,1);

k = dT_dt_mag/dy_dt_mag; % curvature


% % TO OUTPUT TO A FUNCTION
% kf = matlabFunction(k);
% yf = matlabFunction(y(2));

% % TO PLOT
% % verification
% x_test = -10:0.05:1;
% 
% figure;
% 
% subplot(3,1,1)
% plot(x_test,kf(x_test))
% ylabel('curvature (k)')
% hold on; 
% subplot(3,1,2)
% plot(x_test,1./kf(x_test))
% ylabel('radius of curvature')
% subplot(3,1,3)
% plot(x_test,yf(x_test))
% ylabel('function')