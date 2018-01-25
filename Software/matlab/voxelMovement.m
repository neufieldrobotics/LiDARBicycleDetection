function [bbox]=voxelMovement(ptCloudA,ptCloudB,refTree,thresh)

if nargin<4
    thresh = 20;
end

voxelDensityA = zeros(refTree.BinCount,1);
voxelDensityB = zeros(refTree.BinCount,1);
voxelStateA = zeros(refTree.BinCount,1);
voxelStateB = zeros(refTree.BinCount,1);
bbox = zeros(size(refTree.roi));

for i=1:refTree.BinCount
    
    indicesA = findPointsInROI(ptCloudA, refTree.roi(i,:));
    indicesB = findPointsInROI(ptCloudB, refTree.roi(i,:));
    
    if ~isempty(indicesA)
        voxelDensityA(i) = length(indicesA);
    end
    if ~isempty(indicesB)
        voxelDensityB(i) = length(indicesB);
    end
    
    if voxelDensityA(i)>thresh
        voxelStateA(i) = 1; % occupied voxel
    end
    
    if voxelDensityB(i)>thresh
        voxelStateB(i) = 1; % occupied voxel
    end
    
    if voxelStateA(i)==0 && voxelStateB(i)==1
        bbox(i,:) = refTree.roi(i,:);
%     elseif voxelStateA(i)==1 && voxelStateB(i)==0
%         bbox(i,:) = refTree.roi(i,:);
    end
end

% figure(102);
% plot(1:i,voxelDensityA,1:i,voxelDensityB);
% title('Density');
% figure(101);
% plot(1:i,voxelStateA,1:i,voxelStateB);
% title('State');

end