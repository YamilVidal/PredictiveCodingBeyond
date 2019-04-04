%% Find all the events that should be kept

IndWrd1  = FindEEGEvents( 'wrd1', EEG );
IndWrd2  = FindEEGEvents( 'wrd2', EEG );
IndWrd3  = FindEEGEvents( 'wrd3', EEG );
IndWrd4  = FindEEGEvents( 'wrd4', EEG );
IndWrd5  = FindEEGEvents( 'wrd5', EEG );
IndWrd6  = FindEEGEvents( 'wrd6', EEG );

evtorem  =  true(length(EEG.event),1); % Make a vector marking all the events to remove
evtokeep = [IndWrd1; IndWrd2; IndWrd3; IndWrd4; IndWrd5; IndWrd6]; % Spare the ones to keep
evtorem(evtokeep) = false;

%% Rename the events of the learning block

IndLrn  = FindEEGEvents( 'Lear', EEG );

for e = IndLrn(1)+1:IndLrn(2)-1
    EEG.event(e).type = [EEG.event(e).type,'_L'];
end

%%
% Remove first 6 events from the Learning block and from each DEV block

eventname = 'Devi';
IndDevi  = FindEEGEvents( eventname, EEG );

iniindDevi = IndDevi(1:2:end); % ind of the begin Devi of each block

RemLrn = nan(1,12);
RemDev = nan(12,12);

for n=1:12
    RemLrn(n)   = IndLrn(1)+n;
    RemDev(:,n) = iniindDevi+n;
end

Rem = [RemLrn;RemDev];

evtorem(Rem(:)) = true;
%%
EEG.event(evtorem) = [];
