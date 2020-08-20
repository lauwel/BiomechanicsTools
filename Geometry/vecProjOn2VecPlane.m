function plane_vec = vecProjOn2VecPlane(v_proj,plane_normal)
% find the vector projection of v_proj on a plane (based on normal of a plane)
proj_perp = dot(v_proj,plane_normal) * plane_normal; % project the vector in plane normal direction
plane_vec = v_proj - proj_perp; % proj_perp + plane_vec = v_proj as they are the two components in that plane; solve for plane_vec
end