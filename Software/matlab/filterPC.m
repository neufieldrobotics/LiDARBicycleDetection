function [ptCloudOut]=filterPC(ptCloudIn)

ptCloudIn = removeInvalidPoints(ptCloudIn);
ptCloudOut = pcdenoise(ptCloudIn);


end