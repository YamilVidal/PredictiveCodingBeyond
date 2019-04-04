function [ EEG ] = CorrectEEGEventLats( EventType1, EventType2, EEG )
%CORRECTEEGEVENTLATS Changes event latencies of one type of event, to the
%closest latency of another type of event.
%
% This is useful, for example, to match TCP/IP events with DIN events

%   Input:
%        EventType1: text string containing the event type which latencies
%        will be mapped into the other.
%
%        EventType2: text string containing the event type to which to map.
%
%        EEG: An EEGLAB EEG Structure
%
%   Output:
%        Updated EEG lab structure
%
%   Created by Yamil Vidal. 09/02/16

    % Events with latencies to be changed
    Inds1 = FindEEGEvents( EventType1, EEG );
    Lats1 = GetEEGEventLatencies(Inds1, EEG);
    
    % Events with target latencies
    Inds2   = FindEEGEvents( EventType2, EEG );
    Lats2   = GetEEGEventLatencies(Inds2, EEG);
        
    for e = 1:length(Inds1)
        [M, I] = min(abs(Lats2-Lats1(e)));
        EEG.event(Inds1(e)).latency = EEG.event(Inds2(I)).latency;
        
        % Check if there is an event for which no match within 150ms
        sLim = 150/(1000/EEG.srate);
        if M>sLim; error('No event found within 150ms'); end
    end

end