function [folder]=ROSbag_destruct(FileName,chunk_size)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ROSbag_destruct - 9/18/17 - Antonio Rufo
% Script extracts contents of ROS bag file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% str = 'C:\Users\Thinkpad-Rufo\Documents\MATLAB\Robotics\matlab_gen\msggen';
% addpath(str);
% savepath;
% rosgenmsg(str);
if nargin<2
    chunk_size = 1000;
end

if nargin<1
    % set step size of files (100 is the safest) (10000 is faster but crashes)
    chunk_size = 100;
    %Change for your specific path
    PathName = '/home/antoniorufo/catkin_ws/';
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

%Find all unique Topic names and row locations
[names,~,row]=unique(bag.MessageList.Topic);

topicList = bag.AvailableTopics;
fname = [folder filesep FileName(1:end-4) '_TopicList'];
save(fname,'topicList'); % save file containing only topic list

tic;
for i=1:length(names)
    
    try
        tab = bag.MessageList(row==i,:); %Extract messages only from specific topic
        str = char(tab.Topic(1)); % Extract topics name as string
        bagSel = select(bag,'Topic',str); % Select topics string from bag
        ts = timeseries(bagSel);
        
        str = strrep(str, filesep, '_');
        disp(['Topic: ' str ' has ' num2str(height(tab)) ' msgs']);
        
        if strcmp('_ns1_velodyne_points',str) || strcmp('_ns2_velodyne_points',str) || strcmp('_rosout',str) 
            
%         else
%             continue; 
        end
        if height(tab)>chunk_size % Handel topics with more messages then chunk size
            for j=1:chunk_size:height(tab)-chunk_size %iterate through chunks
                step = chunk_size - 1;
                data = readMessages(bagSel,j:j+step); %extract section of message
                time = ts.Time(j:j+step);
                fname = [folder filesep FileName(1:end-4) '_BAG' str '_'...
                    num2str(j) '_to_' num2str(j+step)];
                disp(['Saving data for Topic: ' str ' from '...
                    num2str(j) ' to ' num2str(j+step)...
                    ' ' datestr(time(1)) ' to ' datestr(time(end))]);
                save(fname,'data','time');
                
            end
            j = j+1;
            data = readMessages(bagSel,j+step:height(tab)); %extract end of message
            time = ts.Time(j+step:height(tab));
            fname = [folder filesep FileName(1:end-4) '_BAG' str '_'...
                num2str(j+step) '_to_' num2str(height(tab))];
            disp(['Saving data for Topic: ' str ' from '...
                num2str(j+step) ' to ' num2str(height(tab))...
                ' ' datestr(time(1)) ' to ' datestr(time(end))]);
            save(fname,'data','time');
        else
            time = ts.Time;
            data = readMessages(bagSel); %Extract all data in topic
            fname = [folder filesep FileName(1:end-4) '_BAG' str];
            disp(['Saving all data for Topic: ' str]);
            save(fname,'data','time');
        end
    catch e
        disp(['Topic: ' str ' ' e.message]);
        err{i} = ['Topic: ' str ' ' e.message];
        %keyboard;
    end
    
end

if exist('err','var')
    save([folder filesep 'errors.mat'],'err','e');
end
toc;

end