function [ptCloud] = filterVLP16(ptCloudIn, display)

if nargin<2
    display = 0;
end

maxDistance = .5; % Set the maximum point-to-plane distance in meters
referenceVector = [0,0,1];
maxAngularDistance = 0.5;

ptCloudIn = removeInvalidPoints(ptCloudIn);
ptCloudIn = pcdenoise(ptCloudIn);
ptCloudIn.Normal = pcnormals(ptCloudIn);

medZ = median(ptCloudIn.ZLimits);

if abs(diff(ptCloudIn.ZLimits)) < 15
    % remove Ceiling
    Z = [(ptCloudIn.ZLimits(2) - 0.5), ptCloudIn.ZLimits(2)];
    roi = [-inf,inf;-inf,inf;Z];
    sampleIndices = findPointsInROI(ptCloudIn,roi);
    
    [modelP1,inlierIndices,outlierIndices] = pcfitplane(ptCloudIn,...
        maxDistance,referenceVector,'SampleIndices',sampleIndices);
    
    plane = select(ptCloudIn,inlierIndices);
    ptCloud = select(ptCloudIn,outlierIndices);
    
else
    ptCloud = ptCloudIn;
end

% remove ground
medZ = median(ptCloudIn.ZLimits);
minLim = medZ - diff(ptCloudIn.ZLimits);
Z = [minLim, minLim + 0.1];
% Z = [ptCloud.ZLimits(1), (ptCloud.ZLimits(1) +0.5)]; % set next z limit
roi = [-inf,inf;-inf,inf;Z];
sampleIndices = findPointsInROI(ptCloud,roi);

% [modelP2,inlierIndices,outlierIndices] = pcfitplane(ptCloud,...
%     maxDistance,referenceVector,maxAngularDistance);
[modelP2,inlierIndices,outlierIndices] = pcfitplane(ptCloud,...
    maxDistance,referenceVector,'SampleIndices',sampleIndices);

if ~isempty(inlierIndices)
    plane1 = select(ptCloud,inlierIndices);
    ptCloud = select(ptCloud,outlierIndices);
end

if display
    figure(10);
    
    if exist('plane','var')
        subplot(2,2,1); pcshow(plane); title('Ceiling Plane');
    end
    if exist('plane1','var')
        subplot(2,2,2); pcshow(plane1);
    end
    title('Floor Plane');
    
    subplot(2,2,3:4); pcshow(ptCloudIn); hold on;
    
    if exist('modelP1','var')
        plot(modelP1);
    end
    if exist('modelP2','var')
        plot(modelP2);
    end
    hold off;
    
    title('Floor & Ceiling models'); xlabel('X (m)'); ylabel('Y (m)');
    
    figure(20);
    pcshow(ptCloud); title('Filtered Point Cloud');
    xlabel('X (m)'); ylabel('Y (m)');
    drawnow;
end

end