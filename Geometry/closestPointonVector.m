function line_pt = closestPointonVector(pt,origin,vec,plot_flag)

% Find the closest point on a vector from another point
% pt        =   point investigated for closest point on the vector
% origin    =   vector origin
% vec       =   vector orientation
% plot_flag =   optional argument to plot the results, 0=don't plot, 1=plot

% line_pt   =   closest point on the line from pt

if ~exist('plot_flag','var')
    plot_flag = 0;
elseif plot_flag ~= 0 && plot_flag ~= 1
    error('The plotting flag must be either 0 or 1')
    return
end
unit_vec = vec/norm(vec);
pt_origin = pt - origin; % vector from origin to point
pt_or_proj = dot(pt_origin,unit_vec)*unit_vec; % projection onto original vector
line_pt = origin + pt_or_proj;
% test = acosd(dot( (line_pt-pt),unit_vec)/(norm(line_pt-pt)*norm(unit_vec)));


if plot_flag == 1
    figure;
    hold on
    plot3quick(pt,'k','o');
    plot3quick(line_pt,'r','o');  
    plot3quick(origin,'m','o');
    plotvector3(origin',unit_vec');
    plotvector3(origin',pt_origin');
%     plotvector3(origin',pt_or_proj');
%     plotvector3(pt',(line_pt-pt)');
  
    legend('original point','closest point on vector','vector origin','vector')
    axis equal
end