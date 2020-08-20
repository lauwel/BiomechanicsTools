function iRef = calculateSegIVindices(ref_iv, crop_iv)

% return the indices of the points on the reference surface of a segmented 
% surface in geomagics

  [pts_ref,~] = read_vrml_fast(ref_iv);
  [pts_crop,~] = read_vrml_fast(crop_iv);
  [~,~,iRef] = intersect(pts_crop,pts_ref,'rows');