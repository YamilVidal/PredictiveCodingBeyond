INPath  = fullfile(pwd, 'Data', '4 - Clean ICA');
OUTPath = fullfile(pwd, 'Data', '5 - Clean Conditions');

ff = dir(fullfile(INPath,'*.set'));

for s = 1:length(ff)
    % Open EEGLAB and load dataset
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_loadset('filename',ff(s).name,'filepath',INPath);
    [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    
    %%
    % Re reference
    EEG = pop_reref( EEG, []);
    
    % Remove Baseline
    EEG = pop_rmbase( EEG, [-300 0]);
    
    % Reject trials by extreme values
    lim = [-200, 200];
    EEG = pop_eegthresh(EEG,1, 1:size(EEG.data,1), lim(1), lim(2),EEG.xmin,EEG.xmax,0,1);
    
    % Reject trials by probability
    EEG = pop_jointprob(EEG,1, 1:size(EEG.data,1),4,4,1);
    
    %% Divide datasets in conditions
    
    % Create STD dataset, save it and close it
    EEG = pop_selectevent( EEG, 'type',{'wrd1', 'wrd2'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[EEG.setname, '_STD'],'savenew',fullfile(OUTPath,[ff(s).name(1:2), '_STD.set']),'gui','off');
    ALLEEG = pop_delset( ALLEEG, [2] );
    EEG = eeg_checkset( EEG );
    eeglab redraw;
    
    % Create DEV1 dataset, save it and close it
    EEG = pop_selectevent( EEG, 'type',{'wrd5', 'wrd6'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[EEG.setname, '_DEV1'],'savenew',fullfile(OUTPath,[ff(s).name(1:2), '_DEV1.set']),'gui','off');
    ALLEEG = pop_delset( ALLEEG, [2] );
    EEG = eeg_checkset( EEG );
    eeglab redraw;
    
    % Create DEV2 dataset, save it and close it
    EEG = pop_selectevent( EEG, 'type',{'wrd3', 'wrd4'},'deleteevents','off','deleteepochs','on','invertepochs','off');
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1,'setname',[EEG.setname, '_DEV2'],'savenew',fullfile(OUTPath,[ff(s).name(1:2), '_DEV2.set']),'gui','off');
    ALLEEG = pop_delset( ALLEEG, [2] );
    EEG = eeg_checkset( EEG );
    eeglab redraw;
    
end

ff = dir(fullfile(OUTPath,'*.set'));
id = @(n) n(1:2);
sujnum = unique(cellfun(id,{ff.name},'UniformOutput', false));
load ChanLocs % For Interpolation

for s = 1:length(sujnum)
    %% Makes the amount of trials per condition equal by random sampling trials (Pruning) and interpolate missing channels
    % Load all the datasets from one subject
    whichset = false(1,length(ff));
    for n = 1:length(ff)
        whichset(n) = strcmp(sujnum{s},ff(n).name(1:2));
    end
    
    whichset = find(whichset);
    thesets = {ff(whichset(1)).name, ff(whichset(2)).name, ff(whichset(3)).name};
    
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    for n = 1:3
        EEG = pop_loadset('filename',thesets{n},'filepath',OUTPath);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
    end
    
    % Decide how many trials to keep
    ntrials = min([size(ALLEEG(1).data,3),size(ALLEEG(2).data,3),size(ALLEEG(3).data,3)]);
    
    for S = 1:length(thesets)
        tkeep = randperm(size(ALLEEG(S).data,3),ntrials);
        
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'retrieve',S,'study',0);
        EEG = pop_selectevent( EEG, 'epoch',tkeep ,'deleteevents','off','deleteepochs','on','invertepochs','off');
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'overwrite','on','gui','off');
        
        EEG = pop_interp(EEG, ChanLocs, 'spherical');
        
        EEG = pop_saveset( EEG, 'filename',thesets{S},'filepath',OUTPath);
    end
end