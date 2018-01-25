function [xlim, ylim, zlim]=findLim(ptCloud,xlim,ylim,zlim)
    maxX = max(ptCloud.XLimits);
    minX = min(ptCloud.XLimits);
    
    maxY = max(ptCloud.YLimits);
    minY = min(ptCloud.YLimits);
    
    maxZ = max(ptCloud.ZLimits);
    minZ = min(ptCloud.ZLimits);
    
    if maxX > xlim(2)
        xlim(2) = maxX;
    end
    if minX < xlim(1)
        xlim(1) = minX;
    end
    
    if maxY > ylim(2)
        ylim(2) = maxY;
    end
    if minY < ylim(1)
        ylim(1) = minY;
    end
    
    if maxZ > zlim(2)
        zlim(2) = maxZ;
    end
    if minZ < zlim(1)
        zlim(1) = minZ;
    end
    
end