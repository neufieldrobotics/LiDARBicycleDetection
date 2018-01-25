function [outDir]=velodyneExtract(FileName,topics)

format = 'pcd';
encoding = 'compressed';

if nargin<2
    topics = {'/tf_static','/tf','/ns1/velodyne_points','/ns2/velodyne_points','/imu/imu','/vehicle/gps/fix'};
%     topics = {'/velodyne_points'};
%     topics = {'/imu/imu','/vehicle/gps/fix'};
%     topics = {'/vehicle/imu/data_raw','/vehicle/gps/fix'};
%     topics = {'/tf_static'};
end

if nargin<1
    %Change for your specific path
    PathName = '/home/antoniorufo/bicycleDetection/catkin_ws/';
    addpath(PathName);
    
    [FileName,PathName] = uigetfile('*','Get rosbag Log File',...
        PathName); %GUI to open desired bag file
    if FileName == 0
        disp('No File Selected... Exiting!');
        return;
    end
else
    [PathName,name,ext] = fileparts(FileName);
    FileName = [name ext];
end

folder = FileName(1:end-4); % Create ouput folder
if ~isdir(folder)
    mkdir(folder);
end

disp('Opening bag file');
tic;
bag = rosbag(fullfile(PathName,FileName));
toc

topicList = bag.AvailableTopics;
fname = [folder filesep FileName(1:end-4) '_TopicList'];
save(fname,'topicList'); % save file containing only topic list

if isempty(topics)
   topics = topicList.Row; 
end

for i=1:length(topics)
%     try
        bagSel = select(bag,'Topic',topics{i}); % Select topics string from bag
        msgH = height(bagSel.MessageList);
        
        str = strrep(topics{i}, filesep, '_');
        fnameB = strrep(fname, '_TopicList', str);
        disp(['Topic: ' topics{i} ' has ' num2str(msgH) ' msgs']);
        
        if strcmp(topics{i},'/ns1/velodyne_points') || strcmp(topics{i},'/ns2/velodyne_points') ||  strcmp(topics{i},'/velodyne_points')
            xlim=[0,1]; ylim=[0,1]; zlim=[0,1];
            player = pcplayer(xlim,ylim,zlim);
            
            j=1;
            while j<msgH
                data = readMessages(bagSel,j);
                
                xyzPoints = readXYZ(data{1});
                int = readField(data{1},'intensity');
                %rings = readField(data{1},'ring');
                ptCloud = pointCloud(xyzPoints,'Intensity',int);
                
                [xlim, ylim, zlim]=findLim(ptCloud,xlim,ylim,zlim);
                player.Axes.XLim = xlim;
                player.Axes.YLim = ylim;
                player.Axes.ZLim = zlim;
                player.Axes.Title.String = ['Frame: ' num2str(j)];
                
                view(player,ptCloud);
                drawnow;
                
                set(player.Axes,'CameraPosition',...
                    [-1195.66088867188 -7.1901798248291 694.642700195312],'CameraTarget',...
                    [-3.45315742492676 3.09533548355103 6.29363822937012],'CameraUpVector',...
                    [0.495678246021271 -0.000737741589546204 0.868505895137787],...
                    'CameraViewAngle',1.24355305839284,'DataAspectRatio',[1 1 1],...
                    'PlotBoxAspectRatio',[8.94112393368094 2.80725519812016 1]);
                
                %set(player.Axes,'CameraPosition',...
                %[-781.870115298294 -921.189441456094 673.529540740662],'CameraTarget',...
                %[0.214491771062987 -5.67834090660288 6.09368073807021],'CameraUpVector',...
                %[0.314783159903103 0.360780906900012 0.877922946196204],'CameraViewAngle',...
                %1.24355305839284,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',...
                %[10.5477350983354 9.28422997017536 1]);
                outDir = fullfile(folder,format);
                if ~isdir(outDir)
                    mkdir(outDir);
                end
                
                str = strrep(str, 'ns1', 'port');
                str = strrep(str, 'ns2', 'starboard');
                pcwrite(ptCloud, [fullfile(folder, format, str(2:end)) '_frame_'...
                    num2str(j) '.' format], 'Encoding', encoding);
                disp(['Writing file: ' fullfile(folder, format, str(2:end)) '_frame_'...
                    num2str(j) '.' format]);
                
                j = j + 1;
            end
            ts = timeseries(bagSel);
            save([fullfile(folder, str(2:end)) '_time'],'ts'); % save file containing only topic list
        elseif strcmp(topics{i},'/tf')
            data = readMessages(bagSel,1);
            disp(['Writing File: ' fnameB]);
            save(fnameB,'data'); % save file containing only topic list
        else
            data = readMessages(bagSel);
            ts = timeseries(bagSel);
            disp(['Writing File: ' fnameB]);
            save(fnameB,'data','ts'); % save file containing only topic list
        end
        %keyboard;
%     catch
%         disp(['Topic: ' topics ' ' e.message]);
%         err{i} = ['Topic: ' topics ' ' e.message];
        %keyboard;
%     end
end

if exist('err','var')
    save([folder filesep 'errors.mat'],'err','e');
end
toc;

end