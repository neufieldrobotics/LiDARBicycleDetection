function [ptCloud_mps,binCount_mps,edges_mps,...
    ptCloud_dist,binCount_dist,edges_dist] = movementPtCl(X,Y,Z,distMat,L)

binSize_mps = 0.1; % bin size in meters per second
binSize_dist = 0.1; % bin size in meters

mps = (distMat./L);

numBins = round(range(mps))/binSize_mps;
[locs_mps,edges_mps] = discretize(mps,numBins);
% figure; histogram(mps,numBins);

for i=1:length(edges_mps)
    idx = find(locs_mps==i);
    
%     mps_loc{i} = [X(idx) Y(idx) Z(idx)];
    
%     binLocs_mps{:,i} = mps(idx);
    binCount_mps(i) = length(idx);
end

numBins = round(range(distMat))/binSize_dist;
[locs_dist,edges_dist] = discretize(distMat,numBins);
% figure; histogram(distMat,numBins);

for i=1:length(edges_dist)
    idx = find(locs_dist==i);
    
%     dist_loc{i} = [X(idx) Y(idx) Z(idx)];
    
%     binLocs_dist{:,i} = distMat(idx);
    binCount_dist(i) = length(idx);
end

rm = find(binCount_dist==max(binCount_dist));
locs_dist(locs_dist==rm) = 0;

xyzPoints = [];
for i=1:length(edges_dist)
    idx = find(locs_dist==i);
    xyzPoints = vertcat(xyzPoints,[X(idx) Y(idx) Z(idx)]);
end

ptCloud_dist = pointCloud(xyzPoints);

rm = find(binCount_mps==max(binCount_mps));
locs_mps(locs_mps==rm) = 0;
locs_mps(locs_mps==rm+1) = 0;


xyzPoints = [];
for i=2:length(edges_mps)
    idx = find(locs_mps==i);
    xyzPoints = vertcat(xyzPoints,[X(idx) Y(idx) Z(idx)]);
end

ptCloud_mps = pointCloud(xyzPoints);

end