clc; clear;

zoom = 1;
save = 0;
rate = 10; % frame rate of output video
breakpoint = 0;

folder = uigetdir('.','Select PCD Folder');
if ~folder
    disp('No Folder Selected... Exiting!');
    return;
end
[parent,~]=fileparts(folder);
[~,subDir]=fileparts(parent);
d = dir(folder);
d = d(3:end);

xlim=[0,1]; ylim=[0,1]; zlim=[0,1];

if save
    if zoom
        fname = fullfile(parent,[subDir '_zoom.avi']);
    else
        fname = fullfile(parent,[subDir '.avi']);
    end
    disp(['Saving file: ' fname]);
    v = VideoWriter(fname);
    v.FrameRate = rate;
    open(v);
end

for i=1:length(d)
    h = figure(10); ax = axes('Parent',h); set(h,'Color','black');
    if i==1
        set(h, 'Position', get(0, 'Screensize'));
    end
    fname = fullfile(folder,d(i).name);
    ptCloud = pcread(fname);
    
    if zoom
        %roi = [-8 8 -8 8 -2 2]; % bike circle
        %roi = [-5 10 -6 6 -2 2]; % extra bike circle
        %roi = [-15 15 -20 20 -2 2]; % multibike
        roi = [-40 40 -10 15 -2 5]; % road
    end
    
    indices = findPointsInROI(ptCloud, roi);
    ptCloud = select(ptCloud, indices);
    
    [xlim, ylim, zlim] = findLim(ptCloud,xlim,ylim,zlim);
    pcshow(ptCloud,'MarkerSize',40);
    
    if zoom
        %view(160, 20); % bike circle
        view([-90,35]); % rear view
        %view([-180,35]); % road side view
    else
        view(-90, 30);
    end
    axis([xlim ylim -2 2]);
    set(ax,'Color',[0 0 0],'DataAspectRatio',[1 1 1]);
    %xlabel('X (meters)'); ylabel('Y (meters)');
    %title(['Frame: ' num2str(i)]);
    drawnow;
    
    if exist('v','var')
        F = getframe(h);
        writeVideo(v,F);
    end
    
    if i == breakpoint
        keyboard;
    end
    clf;
end
if exist('v','var')
    close(v);
end
disp('Completed!!!');
