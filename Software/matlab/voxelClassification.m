function [ref,bbox,class]=voxelClassification(ref,bbox,thresh)

if nargin<3
    thresh = 20;
end

idx = find(bbox(:,1)~=0);
class = struct('index',[],'type',[],'color',[],'dimm',[],'center',[],...
    'roi',[]);

for i=1:numel(idx)
    
    density = sum(ref.PointBins==idx(i)); % find and sum number of points at current box
    box = bbox(idx(i),:);
    pts = ref.Points(ref.PointBins==idx(i),:);
    box=shrink_box(pts,box);
    
    sizeX = pdist([box(1);box(2)]);
    sizeY = pdist([box(3);box(4)]);
    sizeZ = pdist([box(5);box(6)]);
    
    centerX = (box(1) + box(2))/2;
    centerY = (box(3) + box(4))/2;
    centerZ = (box(5) + box(6))/2;
    
    class(i).index = idx(i);
    class(i).center = [centerX,centerY,centerZ];
    class(i).dimm = [sizeX sizeY sizeZ];
    
    if density<thresh
        class(i).index = NaN;
        class(i).center = [NaN,NaN,NaN];
        class(i).dimm = [NaN NaN NaN];
        class(i).type = 'noise';
        class(i).color = [1 1 1];
        bbox(idx(i),:) = [0 0 0 0 0 0];
    elseif box(5)>2.5 || centerZ > 3
        class(i).index = NaN;
        class(i).center = [NaN,NaN,NaN];
        class(i).dimm = [NaN NaN NaN];
        class(i).type = 'noise';
        class(i).color = [1 1 1];
        bbox(idx(i),:) = [0 0 0 0 0 0];
    elseif sizeX<=0.3 || sizeY<=0.3 || sizeZ<=0.5 || centerZ>=3.05
        class(i).index = NaN;
        class(i).center = [NaN,NaN,NaN];
        class(i).dimm = [NaN NaN NaN];
        class(i).type = 'noise';
        class(i).color = [1 1 1];
        bbox(idx(i),:) = [0 0 0 0 0 0];
    elseif (sizeX<=2 && sizeY<=2 && sizeZ<=2.5) || (sizeY<=2 && sizeX<=2 && sizeZ<=2.5)
        class(i).type = 'bike/person';
        class(i).color = [1 0 0]; % red
        class(i).roi = box;
    elseif (sizeX<=2 && sizeY<=2 && sizeZ>=1) || (sizeY<=2 && sizeX<=2 && sizeZ>=1)
        class(i).type = 'car';
        class(i).color = [0 1 0]; % green
        class(i).roi = box;
    elseif (sizeX<=25 && sizeY<=2 && sizeZ>=1) || (sizeY<=2 && sizeX<=25 && sizeZ>=1)
        class(i).type = 'Large Vehicle';
        class(i).color = [0 0 1]; % blue
        class(i).roi = box;
    elseif sizeX>25 || sizeY>25 || sizeZ>=4.2 || sizeZ<=1
        class(i).index = NaN;
        class(i).center = [NaN,NaN,NaN];
        class(i).dimm = [NaN NaN NaN];
        class(i).type = 'noise';
        class(i).color = [1 1 1];
        bbox(idx(i),:) = [0 0 0 0 0 0];
    else
        class(i).type = 'unknown';
        class(i).color = [0 1 1];
        class(i).roi = box;
        %bbox(idx(i),:) = 0;
    end
end

end