close all; clear; clc;

save = 1;

[rawDir]=velodyneExtract();

[mergedDir]=stitch();
fixFileName(mergedDir);
% fixFileName(rawDir); mergedDir=rawDir;

[parent,~]=fileparts(mergedDir);
[~,subDir]=fileparts(parent);
d = dir(mergedDir);
d = d(3:end);
% [~,idx] = sort([d.datenum]);
% [~,idx] = sort([d.name]);

% for i=1:length(d)
%     fname = fullfile(mergedDir, d(i).name);
%     ptCloud = pcread(fname);
%     
%     [ptcFilt] = filterVLP16(ptCloud, 0);
%     
%     outDir = fullfile(parent,'pcd_filtered');
%     if ~isdir(outDir)
%         mkdir(outDir);
%     end
%     if save
%         fname = strrep(fname, 'merged', 'filtered');
%         fname = strrep(fname, '/pcd', '/pcd_filtered');        
%         pcwrite(ptcFilt, fname, 'Encoding', 'compressed');
%         disp(['Writing file: ' fname]);
%     end
% end
% fixFileName(outDir);
