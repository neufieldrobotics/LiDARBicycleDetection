function [outDir]=stitch(folder,display,save,zoom)
close all; clc; clear;

calFrame = 1; % what frame is used to calibrate transforms
zone = 5; % timezone difference

if nargin<4
    zoom = 0; % zoom in output?
end
if nargin<3
    save = 1; % Save output?
end
if nargin<2
    display = 0; % display output?
end
if nargin<1
    folder = uigetdir('.','Select PCD Folder');
    if ~folder
        disp('No Folder Selected... Exiting!');
        return;
    end
end

[parent,~]=fileparts(folder);
[~,subDir]=fileparts(parent);
d = dir(folder);
d = d(3:end);
[~,idx] = sort([d.datenum]);

tf = load([parent filesep subDir '_tf_static.mat']);
% tf = load('/home/antoniorufo/bicycleDetection/catkin_ws/matlab/2017-10-18-17-41-30_0/2017-10-18-17-41-30_0_tf_static.mat');
% tf = load([parent filesep subDir '_tf.mat']); % old method
timesPort = load([parent filesep 'port_velodyne_points_time.mat']);
timesStar = load([parent filesep 'starboard_velodyne_points_time.mat']);

if mod(numel(idx),2)
    disp(['Uneven number of PCd files detected... fix directory '...
        folder ' and rerun']);
    keyboard;
end
numF = numel(idx)/2;
port_files = cell(1,numF); starboard_files = cell(1,numF);
portT_string = cell(1,numF); starT_string = cell(1,numF);

for i=1:numel(idx)
    %disp(d(idx(i)).name);
    if strfind(d(idx(i)).name,'port')
        port_files{i} = [folder filesep d(idx(i)).name];
        [portT(i,:),portT_string{i}]=epoch2datetime(timesPort.ts.Time(i),zone);
        ii=i;
    elseif strfind(d(idx(i)).name,'starboard')
        starboard_files{i-ii} = [folder filesep d(idx(i)).name];
        [starT(i-ii,:),starT_string{i-ii}]=epoch2datetime(timesStar.ts.Time(i-ii),zone);
    end
end

figure(4);
plot(portT); hold on; title('Velodyne Timestamps');
plot(starT); hold off;
portT = duration(portT,'Format','s');
starT = duration(starT,'Format','s');
figure(5);
plot(portT-starT); title('Velodyne Mismatch');
figure(6);
plot(diff(portT)); hold on; title('Velodyne time skips');
plot(diff(starT)); hold off;

if display
    xlim=[0,1]; ylim=[0,1]; zlim=[0,1];
    player = pcplayer(xlim,ylim,zlim);
end

for i=1:numel(port_files)
    port = pcread(port_files{i});
    starboard = pcread(starboard_files{i});
    
    [corr,raw]=merge_ptCloud(port,starboard,tf.data,0.01);
    %s[corr,raw]=merge_ptCloud_tf(port,starboard,tf.data,0.01); %old method
    
    if display
        [xlim, ylim, zlim] = findLim(corr,xlim,ylim,zlim);
        if zoom
            player.Axes.XLim = [-15 15];
            player.Axes.YLim = [-15 15];
            player.Axes.ZLim = zlim;
            set(player.Axes,'view',[-90 90]);
        else
            player.Axes.XLim = xlim;
            player.Axes.YLim = ylim;
            player.Axes.ZLim = zlim;
            set(player.Axes,'view',[-90 30]);
        end
        player.Axes.Title.String = ['Frame: ' num2str(i)];
        view(player,corr); drawnow;
    end
    
    outDir = fullfile(parent,'pcd_merged');
    if ~isdir(outDir)
        mkdir(outDir);
    end
    if save
        port_files{i} = strrep(port_files{i}, 'port', 'merged');
        loc = strfind(port_files{i},'merged');
        file = fullfile(outDir,port_files{i}(loc:end));
        pcwrite(corr, file, 'Encoding', 'compressed');
        disp(['Writing file: ' port_files{i}(loc:end)]);
    end
    
    if i==calFrame
        h(1) = figure(2);
        pcshow(raw);
        title(['Raw Frame: ' num2str(i) ' - Merged']);
        axis([-12 12 -12 12 min(raw.ZLimits) max(raw.ZLimits)]);
        view([-90 90]); drawnow;
        h(2) = figure(3);
        pcshow(corr);
        title(['Corrected Frame: ' num2str(i) ' - Merged']);
        axis([-12 12 -12 12 min(corr.ZLimits) max(corr.ZLimits)]);
        view([-90 90]); drawnow;
        
        %disp('Press enter to continue.....');
        %pause;
    end
end
clearvars -except outDir
end


