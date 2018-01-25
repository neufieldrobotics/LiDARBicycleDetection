function [adjTracks_out,trackLen_out]=filterTracks(adjTracks,...
    trackLen_old)

n_tracks = numel(adjTracks);
trackLen = zeros(n_tracks,1);
adjTracks_out = {};
count = 1;

for i = 1 : n_tracks
    seltrack = adjTracks{i};
    if length(seltrack)>3 % track must be longer than 3 points
        trackLen(count) = length(seltrack); % store length of track
        adjTracks_out{count} = adjTracks{i}; % store track points
        count = count + 1;
    end
end

% find difference in track lengths
difflen = length(trackLen) - length(trackLen_old);
for i=1:difflen % add zeros if dimm mismatch
    if difflen>0
        trackLen_old = vertcat(trackLen_old,0);
    else
        keyobard;
        trackLen = vertcat(trackLen,0);
    end
end

trackLen_out = trackLen;

end