INPath  = fullfile(pwd, 'Data', '5 - Clean Conditions');
OUTPath = fullfile(pwd, 'Data', '6 - Grand Average');

ff = dir(fullfile(INPath,'*.set'));

Cond = {'STD', 'DEV1', 'DEV2'};

%%
for cnd = 1:length(Cond)
    ff     = dir(fullfile(INPath,['*',Cond{cnd},'*.set']));
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    
    for s = 1:length(ff)    
        EEG = pop_loadset('filename', ff(s).name,'filepath',INPath);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
        EEG = eeg_checkset( EEG );
    end
    
    % For each participant, take the mean of all trials and save it in the
    % DATA matrix
    
    DATA = nan(size(EEG.data,1),size(EEG.data,2),length(ALLEEG));
    for s = 1:length(ALLEEG)
        if size(ALLEEG(s).data,3) > 30 % Do not include participants with less than 30 trials
            DATA(:,:,s) = mean(ALLEEG(s).data,3);
        end
    end
    DATA(:,:,squeeze(isnan(DATA(1,1,:)))) = [];
    
    % Create dataset and save it
    EEG = pop_importdata('dataformat','array','nbchan',0,'data','DATA','setname',[Cond{cnd},'_GA.set'],'srate',ALLEEG(1).srate,'pnts',0,'xmin',ALLEEG(1).xmin,'chanlocs','{ ALLEEG(1).chanlocs ALLEEG(1).chaninfo ALLEEG(1).urchanlocs }');
    
    % Re reference
    EEG = pop_reref( EEG, []);
    % Remove Baseline
    EEG = pop_rmbase( EEG, [-300 0]);
    
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, CURRENTSET,'savenew',fullfile(OUTPath, [Cond{cnd},'_GA.set']),'overwrite','on','gui','off');
end