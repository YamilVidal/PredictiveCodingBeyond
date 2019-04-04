INPath  = fullfile(pwd, 'Data', '1 - Sets');
OUTPath = fullfile(pwd, 'Data', '2 - Clean Channels');

ff = dir(fullfile(INPath,'*.set'));

for s = 1:length(ff)
    % Open EEGLAB and load dataset
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',ff(s).name,'filepath',INPath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    %% Filtering
    
    % Band-pass filtered (0.1-30Hz)
    EEG = pop_eegfiltnew(EEG, [], 0.1, [],  true, [], 0); % Highpass filter 0.1 Hz
    EEG = pop_eegfiltnew(EEG, [],  30, [], false, [], 0); % Lowpass filter 30 Hz
    
    %% Adjust OffSet due to EGI antialiasing filter.
    
    for m = 1:length(EEG.event)
        EEG.event(m).latency = EEG.event(m).latency + 9; % Equivalent to 36ms
    end
    
    %% Change TCP/IP marks time to closest DIN
    
    [ EEG ] = CorrectEEGEventLats( 'wrd1', 'DIN1', EEG );
    [ EEG ] = CorrectEEGEventLats( 'wrd2', 'DIN1', EEG );
    [ EEG ] = CorrectEEGEventLats( 'wrd3', 'DIN1', EEG );
    [ EEG ] = CorrectEEGEventLats( 'wrd4', 'DIN1', EEG );
    [ EEG ] = CorrectEEGEventLats( 'wrd5', 'DIN1', EEG );
    [ EEG ] = CorrectEEGEventLats( 'wrd6', 'DIN1', EEG );
    
    %% Rename events from the learning block. Delete unnecessary events and delete the first 6 events from each block
    CleanEvents
    
    %% Segment
    EEG = pop_epoch( EEG, { 'wrd1', 'wrd2', 'wrd3', 'wrd4', 'wrd5', 'wrd6' }, [-0.3, 1.550], 'newname', ff(s).name(1:end-4), 'epochinfo', 'yes');
    
    %% Channel rejection
    
    % Exclude frontal channels from channel rejection as they contain
    % blinks that can be removed with ICA
    ExElec = [127, 126, 17, 128, 125, 32, 25, 21, 14, 8, 1, 33, 26,...
        22, 15, 9, 2, 122, 34, 27, 23, 18, 16, 10, 3, 123, 116, 24, 19, 11, 4, 124];
    
    AllElec = 1:128;
    
    TheElec = setdiff(AllElec, ExElec);
    
    % The actual channel rejection happens here
    [~, IndEk] = pop_rejchan(EEG, 'elec', AllElec,'threshold',4,'norm','on','measure','kurt');
    [~, IndEp] = pop_rejchan(EEG, 'elec', AllElec,'threshold',4,'norm','on','measure','prob');
    [~, IndEs] = pop_rejchan(EEG, 'elec', AllElec,'threshold',3,'norm','on','measure','spec', 'freqrange', [1 30]);
    
    IndEk = setdiff(IndEk, ExElec);
    IndEp = setdiff(IndEp, ExElec);
    IndEs = setdiff(IndEs, ExElec);
    
    RemElec = unique([IndEk, IndEp, IndEs]);
    
    EEG = pop_select( EEG,'nochannel',RemElec);
    
    %% Save work done so far
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[EEG.setname, '_Clean_Channs.set'],'filepath',OUTPath);
end