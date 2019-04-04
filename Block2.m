INPath  = fullfile(pwd, 'Data', '2 - Clean Channels');
OUTPath = fullfile(pwd, 'Data', '3 - Done ICA');

ff = dir(fullfile(INPath,'*.set'));

parfor s = 1:length(ff)
    % Open EEGLAB and load dataset
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',ff(s).name,'filepath',INPath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    %% Reject obviously bad trials
    
    % Reject trials with very high amplitude
    lim = [-500, 500];
    EEG = pop_eegthresh(EEG,1, 1:size(EEG.data,1), lim(1), lim(2),EEG.xmin,EEG.xmax,0,1);
    
    % Reject by probability
    EEG = pop_jointprob(EEG,1, 1:size(EEG.data,1),7,3,1);
    
    %% Run ICA
    EEG = pop_runica(EEG, 'extended',1,'interupt','on');
    
    %% Save work done so far
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'overwrite','on','gui','off');
    EEG = eeg_checkset( EEG );
    EEG = pop_saveset( EEG, 'filename',[EEG.setname,'_DoneICA.set'],'filepath',OUTPath);
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'savenew',fullfile(OUTPath, [ff(s).name(1:2),'_DoneICA.set']),'overwrite','on','gui','off');
end