%% First block of code
% Performs filtering, events latency correction, segmentation and channel
% rejection.

% IN  Path = '1 - Set'
% OUT Path = '2 - Clean Channels'

Step1

%% Visually inspect continuous data and spectra to reject channels that were not picked by the automatic methods
% Note that some participants with small heads were using an infant size
% net that is lacking the last 4 electrodes. These come out as electrodes
% with values close to zero, which the automatic methods have trouble to
% reject.

% Spectra can be plotted with this line of code (uses 50% of the data to speed up things)
figure; SPEC = pop_spectopo(EEG, 1, [], 'EEG' , 'percent', 50, 'freqrange',[1 70],'electrodes','off');

% Continuous data can be plotted with:
% eegplot(EEG.data,'spacing',150,'winlength',50);

% Channels rejected (labels)

% 04: 125 126 127 128
% 07: 125 126 127 128
% 20: 17 21
% 21: 21
% 25: 2
% 26: 125 126 127 128
% 29: 125 126 127 128

%% Second block of code
% Reject obviously bad trials to improve the outcome of ICA. Then runs ICA.

% IN  Path = '2 - Clean Channels'
% OUT Path = '3 - Done ICA'

Step2

%% Remove ICA components manually
% Save in a different directory (4 - Clean ICA) to keep a copy of the datasets with all the
% components, just in case a mistake is made.

% First 24 component maps can be plotted with:
pop_selectcomps(EEG, 1:24);

%% Third block of code
% ReRef to Average Reference. Remove Baseline. Reject trials by Extreme
% values and Probability. Divide in conditions. Prune sets to have the same
% amount of trials per condition. Interpolate bad channels

% IN  Path = '4 - Clean ICA'
% OUT Path = '5 - Clean Conditions'

Step3

%% Create Grand Average datasets
% IN  Path = '5 - Clean Conditions'
% OUT Path = '6 - Grand Average'

Step4