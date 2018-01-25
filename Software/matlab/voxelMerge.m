function [refTree,bbox]=voxelMerge(refTree,bbox)

idx = find(bbox(:,1)~=0);
if numel(idx)<2
    return;
end

for i=1:numel(idx)
    for j=i+1:numel(idx)
        boxB = bbox(idx(j),:);
        boxA = bbox(idx(i),:);
        cubeA = [boxA(1),boxA(3),boxA(5),...
            boxA(2)-boxA(1),boxA(4)-boxA(3),boxA(6)-boxA(5)];
        cubeB = [boxB(1),boxB(3),boxB(5),...
            boxB(2)-boxB(1),boxB(4)-boxB(3),boxB(6)-boxB(5)];
        
        centXA = (boxB(1) + boxB(2))/2;
        centYA = (boxB(3) + boxB(4))/2;
        centZA = (boxB(5) + boxB(6))/2;
        centXB = (boxA(1) + boxA(2))/2;
        centYB = (boxA(3) + boxA(4))/2;
        centZB = (boxA(5) + boxA(6))/2;
        
        dist = euclidDist([centXA,centYA,centZA],[centXB,centYB,centZB]);
        area = cubeint(cubeA,cubeB);
        
        if abs(dist)<= 1.5 || (area>0 && abs(dist)<=2)
            minX = min(boxB(1),boxA(1));
            maxX = max(boxB(2),boxA(2));
            minY = min(boxB(3),boxA(3));
            maxY = max(boxB(4),boxA(4));
            minZ = min(boxB(5),boxA(5));
            maxZ = max(boxB(6),boxA(6));
            
            bbox(idx(j),:) = [minX,maxX,minY,maxY,minZ,maxZ];
            bbox(idx(i),:) = 0;
            refTree.BinBoundaries(idx(j),:) = [minX,minY,minZ,maxX,maxY,maxZ];
            
            refTree.PointBins(refTree.PointBins==idx(i)) = idx(j);
            break;
        end
    end
end
end