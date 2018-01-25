function [time_matlab,time_matlab_string]=epoch2datetime(epoch,zone)

time_reference = datenum('1970', 'yyyy'); 
time_matlab = time_reference + epoch / 86400; % seconds in day
time_matlab = time_matlab - hours(zone);
time_matlab_string = datestr(time_matlab, 'yyyymmdd HH:MM:SS.FFF');

end