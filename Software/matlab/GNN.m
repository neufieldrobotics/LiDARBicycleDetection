function [points,adjacency_tracks,target]=GNN(target,points,...
    method,max_linking_distance,max_gap_closing)

addpath('utils/SimpleTracker/');

if nargin<3
    %method = 'NearestNeighbor';
    method = 'Hungarian';
end
if nargin<4
    max_linking_distance = 1.5;
end
if nargin<5
    max_gap_closing = 1;
end

for j=1:length(target(end).class)
    tmp(j,:) = target(end).class(j).center;
end

if isempty(points)
    points{1}(1:j,:) = tmp;
else
    points{end+1}(1:j,:) = tmp;
end

[~, adjacency_tracks] = simpletracker(points,...
    'MaxLinkingDistance', max_linking_distance, ...
    'MaxGapClosing', max_gap_closing, ...
    'Method',method,'Debug', false);

end