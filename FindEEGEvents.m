function [ indmarks, Lindmarks, nmarks ] = FindEEGEvents( eventname, EEG )
%FINDEEGEVENTS Find the indices of an event type in a EEGLAB EEG structure
%   Input:
%        eventname: text string containing the event type
%        EEG: An EEGLAB EEG Structure
%
%   Output:
%        indmarks: Vector of indices
%        Lindmarks: Vector of indices as logical
%        nmarks: Number of events of the given type
%
%   Created by Yamil Vidal Dos Santos. 14/09/15 during a mission in
%   Cambridge...

if ~ischar(eventname), error('First argument should be a text string'); end

Lindmarks = zeros(length(EEG.event),1);

for n=1:length(EEG.event)
    if length(EEG.event(n).type) == length(eventname)
        if strncmp(EEG.event(n).type, eventname, length(EEG.event(n).type))
        %if strncmp(EEG.event(n).type, eventname, length(eventname))
            Lindmarks(n) = 1;
        end
    end
end

indmarks = find(Lindmarks);
nmarks   = numel(indmarks);

end