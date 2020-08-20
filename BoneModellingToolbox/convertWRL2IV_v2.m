function convertWRL2IV_v2(filename,ivdir,offsetx,offsety,offsetz)
% added the ivdir (ectory) to specify where to save it

if ~exist('offsetx','var')
    offsetx=0;
end
if ~exist('offsety','var')
    offsety=0;
end
if ~exist('offsetz','var')
    offsetz=0;
end

[pts conns]=read_vrml_fast(filename);
conns(:,4) = [];
conns(:) = conns(:)+1;

pts_new=pts;
pts_new(:,1)=pts(:,1)-offsetx;
pts_new(:,2)=pts(:,2)-offsety;
pts_new(:,3)=pts(:,3)-offsetz;

[pth name ext]=fileparts(filename);
ext_new='.iv';

patch2iv(pts_new,conns,fullfile(ivdir,[name ext_new]));