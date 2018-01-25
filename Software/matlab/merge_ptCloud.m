function [corrected,raw]=merge_ptCloud(ptCloudA,ptCloudB,tf,gridStep)

if nargin<4
    gridStep = 0.1;
end

trans_port_base = tf{1}.Transforms(2,1).Transform.Translation;
trans_port_base = [trans_port_base.X trans_port_base.Y trans_port_base.Z];
quate_port_base = tf{1}.Transforms(2,1).Transform.Rotation;

trans_star_base = tf{1}.Transforms(4,1).Transform.Translation;
trans_star_base = [trans_star_base.X trans_star_base.Y trans_star_base.Z];
quate_star_base = tf{1}.Transforms(4,1).Transform.Rotation;

trans = trans_star_base - trans_port_base;
rot.X = quate_star_base.X - quate_port_base.X;
rot.Y = quate_star_base.Y - quate_port_base.Y;
rot.Z = quate_star_base.Z - quate_port_base.Z;

trans = [1 0 0 0;...
    0 1 0 0;...
    0 0 1 0;...
    trans 1];
rotX = [1      0          0  0;...
    0  cos(rot.X) sin(rot.X) 0;...
    0 -sin(rot.X) cos(rot.X) 0;...
    0          0          0  1];
rotY = [cos(rot.Y) 0 -sin(rot.Y) 0;...
    0          1          0  0;...
    sin(rot.Y) 0  cos(rot.Y) 0;...
    0          0          0  1];
rotZ = [cos(rot.Y) sin(rot.Y) 0 0;...
    -sin(rot.Y) cos(rot.Y) 0  0;...
    0                   0  1  0;...
    0                   0  0  1];

A = trans * rotX * rotY * rotZ;
tform = affine3d(A);
% roughAlign = pctransform(ptCloudB,tform);

% tformB = pcregrigid(roughAlign,ptCloudA,'Extrapolate',true);
aligned = pctransform(ptCloudB,tform);

raw = pcmerge(ptCloudA, ptCloudB, gridStep);
corrected = pcmerge(ptCloudA, aligned, gridStep);

end

