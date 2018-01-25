close all; clc; clear;
addpath(genpath('./utils'));

%% Single Bike

frame = 50; 
fname = ['./2017-09-18-20-09-08/pcd/velodyne_points_frame_0' num2str(frame) '.pcd'];
disp(['Loading: ' fname]);

frameB = 75; 
fnameB = ['./2017-09-18-20-11-50/pcd/velodyne_points_frame_0' num2str(frameB) '.pcd'];
disp(['Loading: ' fnameB]);

pc_close = pcread(fname);
pc_close = filterPC(pc_close);

pc_far = pcread(fnameB);
pc_far = filterPC(pc_far);

indices = findPointsInROI(pc_close, [-10 10 -10 10 -inf inf]);
pc_close = select(pc_close, indices);

h = figure(101); ax = axes('Parent',h); set(h,'Color','black');
% subplot(2,2,1);
pcshow(pc_close,'MarkerSize',20);
title('Point Cloud - Small Circle - Counter Clockwise');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
% axis([-50 50 -50 50 -inf inf]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H1.fig');

indices = findPointsInROI(pc_close, [-1 2 -1 3 -inf 4]);
pc_close = select(pc_close, indices);

h = figure(102); ax = axes('Parent',h); set(h,'Color','black');
% subplot(2,2,3);
pcshow(pc_close,'MarkerSize',40); title('Zoomed');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
view([-88,10]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H2.fig');

h = figure(103); ax = axes('Parent',h); set(h,'Color','black');
% subplot(2,2,2);
pcshow(pc_far,'MarkerSize',10);
title('Point Cloud - Large Circle - Clockwise');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
axis([-50 50 -50 50 -inf inf]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H3.fig');

indices = findPointsInROI(pc_far, [5.5 7 -2 0.5 -inf 2]);
pc_far = select(pc_far, indices);

h = figure(104); ax = axes('Parent',h); set(h,'Color','black');
% subplot(2,2,4);
pcshow(pc_far,'MarkerSize',40); title('Zoomed');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
view([-88,10]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H4.fig');

%% Multi - Bike

frame = 20;
fname = ['./2017-11-02-11-20-21_2/pcd_merged/merged_velodyne_points_frame_0' num2str(frame) '.pcd'];
disp(['Loading: ' fname]);

ptCloud = pcread(fname);
ptCloud = filterPC(ptCloud);

indices = findPointsInROI(ptCloud, [-40 40 -20 20 -inf 2]);
ptCloud = select(ptCloud, indices);

h = figure(105); ax = axes('Parent',h); set(h,'Color','black');
pcshow(ptCloud,'MarkerSize',40); title('Zoomed');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
view([-90,90]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H5.fig');

%% Driving Route

frame = 340;
fname = ['./Columbus_drive2/2017-10-18-17-33-13_0/pcd_merged/merged_velodyne_points_frame_0' num2str(frame) '.pcd'];
disp(['Loading: ' fname]);

ptCloud = pcread(fname);
ptCloud = filterPC(ptCloud);

indices = findPointsInROI(ptCloud, [8 10.5 -4 -2.5 -inf 2]);
pc_zoom = select(ptCloud, indices);

indices = findPointsInROI(ptCloud, [-15 15 -10 10 -inf 2]);
ptCloud = select(ptCloud, indices);

h = figure(106); ax = axes('Parent',h); set(h,'Color','black');
pcshow(ptCloud,'MarkerSize',20); title('Zoomed');
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
view([-88,10]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H6.fig');

h = figure(107); ax = axes('Parent',h); set(h,'Color','black');
pcshow(pc_zoom,'MarkerSize',80); title('Zoomed');
view([-88,10]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H7.fig');

%% Octree
% close all;

doplot3 = @(p,varargin)scatter3(p(:,1),p(:,2),p(:,3),varargin{:});
binCapacity = 100;
% style = 'equal';
style = 'weighted';

frame = 30;
fname = ['./2017-09-18-20-09-08/pcd/velodyne_points_frame_0' num2str(frame) '.pcd'];
disp(['Loading: ' fname]);

ptCloud = pcread(fname);
ptCloud = filterPC(ptCloud);
xyzPoints = ptCloud.Location;

ot = OcTree(xyzPoints,'style',style,'binCapacity',binCapacity);
ot.shrink;
ot.findroi;

h = figure(108); ax = axes('Parent',h); set(h,'Color','white');
title(['Octree Frame: ' num2str(frame)]);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
boxH = ot.plot;
cols = lines(ot.BinCount);
for i = 1:ot.BinCount
    set(boxH(i),'Color',cols(i,:),'LineWidth', 2);
    %doplot3(xyzPoints(ot.PointBins==i,:),'.');
end
%axis([-4 1 -4 2 -1 0.5]);
% axis([-5 5 -5 5 -2 2]);
view([0,0]);
%set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H8.fig');

%% Density and State Estimation

density_thresh = 20;

frame = 10;
fname = ['./2017-09-18-20-09-08/pcd/velodyne_points_frame_0' num2str(frame) '.pcd'];
disp(['Loading: ' fname]);

ptCloudA = pcread(fname);
ptCloudA = filterPC(ptCloudA);

[bbox]=voxelMovement(ptCloudA,ptCloud,ot,density_thresh);
idx = find(bbox(:,1)~=0);

C = ones(size(ot.Points));
C(:,1) = .5;
C(:,2) = .5;
C(:,3) = .5;

for i=1:length(idx)
    indices = findPointsInROI(ptCloud, ot.roi(idx(i),:));
    C(indices,1) = 1;
    C(indices,2) = 0;
    C(indices,3) = 0;
end
h = figure(109); ax = axes('Parent',h); set(h,'Color','black');
pcshow(xyzPoints,C,'MarkerSize',80);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
view([-90,90]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H9.fig');


%% Voxel Merging
h = figure(110); ax = axes('Parent',h); set(h,'Color','black');
for i=1:length(idx)
    
    binMinMax = ot.BinBoundaries(idx(i),:);
    pts = cat(1, binMinMax([...
        1 2 3; 4 2 3; 4 5 3; 1 5 3; 1 2 3;...
        1 2 6; 4 2 6; 4 5 6; 1 5 6; 1 2 6; 1 2 3]),...
        nan(1,3), binMinMax([4 2 3; 4 2 6]),...
        nan(1,3), binMinMax([4 5 3; 4 5 6]),...
        nan(1,3), binMinMax([1 5 3; 1 5 6]));
    h = plot3(pts(:,1),pts(:,2),pts(:,3)); hold on;
    set(h,'Color',cols(i,:),...
        'LineWidth',2);
end
pcshow(xyzPoints,C,'MarkerSize',80);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
axis([-5 5 -5 5 -2 2]);
view([-90,90]);
set(h,'Color','k');
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H10.fig');

[ot,bbox]=voxelMerge(ot,bbox);
idx = find(bbox(:,1)~=0);

h = figure(111); ax = axes('Parent',h); set(h,'Color','black');
for i=1:length(idx)
    
    binMinMax = ot.BinBoundaries(idx(i),:);
    pts = cat(1, binMinMax([...
        1 2 3; 4 2 3; 4 5 3; 1 5 3; 1 2 3;...
        1 2 6; 4 2 6; 4 5 6; 1 5 6; 1 2 6; 1 2 3]),...
        nan(1,3), binMinMax([4 2 3; 4 2 6]),...
        nan(1,3), binMinMax([4 5 3; 4 5 6]),...
        nan(1,3), binMinMax([1 5 3; 1 5 6]));
    h = plot3(pts(:,1),pts(:,2),pts(:,3)); hold on;
    set(h,'Color',cols(i,:),...
        'LineWidth',2);
end
pcshow(xyzPoints,C,'MarkerSize',80);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
axis([-5 5 -5 5 -2 2]);
view([-90,90]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H11.fig');

%% Classification

C = ones(size(ot.Points));
C(:,1) = .5;
C(:,2) = .5;
C(:,3) = .5;

[ot,bbox,target]=voxelClassification(ot,bbox);

h = figure(112); ax = axes('Parent',h); set(h,'Color','black');
for i=1:length(target)
    if ~isempty(target(i).roi)
        indices = findPointsInROI(ptCloud,target(i).roi );
        
        C(indices,1) = target(i).color(1);
        C(indices,2) = target(i).color(2);
        C(indices,3) = target(i).color(3);
        
        binMinMax = ot.BinBoundaries(target(i).index,:);
        pts = cat(1, binMinMax([...
            1 2 3; 4 2 3; 4 5 3; 1 5 3; 1 2 3;...
            1 2 6; 4 2 6; 4 5 6; 1 5 6; 1 2 6; 1 2 3]),...
            nan(1,3), binMinMax([4 2 3; 4 2 6]),...
            nan(1,3), binMinMax([4 5 3; 4 5 6]),...
            nan(1,3), binMinMax([1 5 3; 1 5 6]));
        h = plot3(pts(:,1),pts(:,2),pts(:,3)); hold on;
        set(h,'Color',cols(i,:),...
            'LineWidth',2);
    end
end
pcshow(xyzPoints,C,'MarkerSize',80);
xlabel('X (m)'); ylabel('Y (m)'); zlabel('Z (m)');
% axis([-5 5 -5 5 -2 2]);
view([-90,90]);
set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
%saveas(h,'H12.fig');
