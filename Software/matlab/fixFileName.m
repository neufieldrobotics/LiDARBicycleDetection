function fixFileName(folder)

if nargin<1
    folder = uigetdir('.','Select PCD Folder');
    if ~folder
        disp('No Folder Selected... Exiting!');
        return;
    end
end

d = dir(folder);
d = d(3:end);

leadZeros = num2str(floor(length(d)/10));
leadZeros = length(leadZeros)+1;

disp(['Renaming ' num2str(length(d)) ' file(s) in folder: ' folder]);
disp(['Leading Zeros: ' num2str(leadZeros)]);

for ii=1:length(d)
    
    [~,file,ext] = fileparts(d(ii).name);
    k = strfind(file,'_');
    
    strNum = sprintf(['%0' num2str(leadZeros) 'd'],...
        str2num(file(k(end)+1:end)));
    
    source = fullfile(folder,d(ii).name);
    destination = fullfile(folder,[file(1:k(end)) strNum ext]);
    
    [status,msg,~] = movefile(source,destination);
    disp(['Moving ' d(ii).name ' to ' [file(1:k(end)) strNum ext]]);
    
    if status~=1
        disp(['Failed @ file: ' d(ii).name]);
        disp(['     ' msg])
    end
    
end
disp('Completed!!!');

end

