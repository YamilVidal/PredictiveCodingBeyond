function [ EventLats ] = GetEEGEventLatencies( EventInds, EEG )
%GETEEGEVENTLATENCIES Gives back a vector of latencies of EEG events

% Input:
%        EventInds: Vector of event indices
%        EEG: An EEGLAB EEG Structure
%
%   Output:
%        EventLats: Vector of event latencies
%
%   Created by Yamil Vidal Dos Santos. 09/02/16 during a mission in
%   Cambridge...

EventLats = nan(size(EventInds));

for e = 1:length(EventInds)
    EventLats(e) = EEG.event(EventInds(e)).latency;
end


end

