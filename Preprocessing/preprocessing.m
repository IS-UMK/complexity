% 1. c0001_d0001__dnSamp: Import, Update Channel Information and Downsample (=256 Hz)

% FILES_SOURCE - output of dir() function in directory with files to be preprocessed

% Brain Vision Recorder data
EEG = pop_loadbv(FILES_SOURCE(ii).folder, FILES_SOURCE(ii).name);
% sample Biosig data
temp_refChan = 47; % 47 FCz
temp_inFile = [FILES_SOURCE(ii).folder, '/', FILES_SOURCE(ii).name];
EEG = pop_biosig(temp_inFile,'ref',temp_refChan);
% Remove mean from each channel
for chanNum = 1:size(EEG.data,1);EEG.data(chanNum,:) = single(double(EEG.data(chanNum,:))-mean(double(EEG.data(chanNum, :)))); end
assert(sum(abs(EEG.data(temp_refChan,:)))==0,'problem with reference')
assert(~any(EEG.data(temp_refChan,:)),'problem with reference')
% Remove reference channel
EEG = pop_select(EEG,'nochannel',[temp_refChan]);

% Remove unwanted channels
EEG.cc.c0001_d0001__dnSamp.unwanted_chans = {'EMG','EOG','VEOG','HEOG','EKG','ECG','emg','eog','veog','heog','ekg','ecg','EXG1','EXG2','EXG3','EXG4','EXG5','EXG6','EXG7','EXG8','exg1','exg2','exg3','exg4','exg5','exg6','exg7','exg8','VEOG1','VEOG2','HEOG1','HEOG2'};
EEG = pop_select( EEG,'nochannel',EEG.cc.c0001_d0001__dnSamp.unwanted_chans);
EEG.cc.c0001_d0001__dnSamp.chanlocs_003_removed_unwanted = EEG.chanlocs;
temp_comStr = ['% removed unwanted channels'];
EEG = eegh(temp_comStr,EEG);

% Append reference channel to 'EEG.chaninfo.nodatchans' get channel positions
EEG.cc.c0001_d0001__dnSamp.chans_lookup = '~/toolboxes/eeglab14_1_2b/plugins/dipfit2.3/standard_BESA/standard-10-5-cap385.elp';
EEG.cc.c0001_d0001__dnSamp.chans_append = length(EEG.chanlocs);
EEG.cc.c0001_d0001__dnSamp.chans_change = {length(EEG.chanlocs)+1,'labels','FCz'};
EEG.cc.c0001_d0001__dnSamp.chans_setRef = {['1:',num2str(length(EEG.chanlocs))],'FCz'};
EEG = pop_chanedit(EEG,'append',EEG.cc.c0001_d0001__dnSamp.chans_append,'changefield',EEG.cc.c0001_d0001__dnSamp.chans_change,'lookup',EEG.cc.c0001_d0001__dnSamp.chans_lookup,'setref',EEG.cc.c0001_d0001__dnSamp.chans_setRef);
EEG.cc.c0001_d0001__dnSamp.chanlocs_004_lookedup_no_ref = EEG.chanlocs;
temp_comStr = ['% updated chanlocs reference and position info'];
EEG = eegh(temp_comStr,EEG);

% Downsample
EEG.cc.c0001_d0001__dnSamp.dnSampFreq = 256; % Hz
[EEG,temp_out.comStr] = pop_resample(EEG,EEG.cc.c0001_d0001__dnSamp.dnSampFreq);
EEG = eegh(temp_out.comStr,EEG);

% 2. c0001_d0101__hiPass: Hi-Pass Filtering (>1 Hz)

% High-Pass Filtering
EEG.cc.c0001_d0101__hiPass.hiPassFreq = 1; % Hz
[EEG,temp_out.comStr,temp_out.hiPassCoefs] = pop_eegfiltnew(EEG,[],EEG.cc.c0001_d0101__hiPass.hiPassFreq,[],logical(1),[],0);
EEG = eegh(temp_out.comStr,EEG);

% 3. c0001_d0201__remBad: Reject Bad Channels and Bad Times/Samples (using trimOutlier)

% Remove Bad Channels Using POP_REJCHANSPEC
EEG.cc.c0001_d0201__remBad.freqlims =  [  0.00, 5.00;  5.00, 40.00   ]; % Hz
EEG.cc.c0001_d0201__remBad.stdthresh = [ -5.00, 5.00; -2.50,  2.50   ]; % SD
[EEG,temp_out.allrmchan,temp_out.specdata,temp_out.specfreqs,temp_out.comStr] = pop_rejchanspec(EEG,'freqlims',EEG.cc.c0001_d0201__remBad.freqlims,'stdthresh',EEG.cc.c0001_d0201__remBad.stdthresh);
% Remenber Reduced ChanLocs
EEG.cc.c0001_d0201__remBad.chanlocs_006_trimOutlier = EEG.chanlocs;

% Remove Bad Samples Using TRIMOUTLIER
EEG.cc.c0001_d0201__remBad.channelSdLowerBound = -Inf; % SD
EEG.cc.c0001_d0201__remBad.channelSdUpperBound =  Inf; % SD (consider using 35)
EEG.cc.c0001_d0201__remBad.amplitudeThreshold  =  444; % uV (use 444 or 500 or 555)
EEG.cc.c0001_d0201__remBad.pointSpreadWidth    = 2000; % samples (use 2000 or 4000)
EEG = trimOutlier(EEG,EEG.cc.c0001_d0201__remBad.channelSdLowerBound,EEG.cc.c0001_d0201__remBad.channelSdUpperBound, EEG.cc.c0001_d0201__remBad.amplitudeThreshold,EEG.cc.c0001_d0201__remBad.pointSpreadWidth);

% 4. c0001_d0301__loPass: Lo-Pass Filtering (<40 Hz)

% Low-Pass Filtering
EEG.cc.c0001_d0301__loPass.loPassFreq = 40; % Hz
[EEG,temp_out.comStr,temp_out.loPassCoefs] = pop_eegfiltnew(EEG,[],EEG.cc.c0001_d0301__loPass.loPassFreq,[],logical(0),[],0);
EEG.cc.c0001_d0301__loPass.loPassCoefs = temp_out.loPassCoefs;
EEG = eegh(temp_out.comStr,EEG);

% 5. c0001_d0401__reRefe: Re-Reference to the Average

[EEG,temp_comStr] = pop_reref(EEG,[],'refloc',struct('labels',{'FCz'},'type',{''},'theta',{0},'radius',{0.12662},'X',{32.9279},'Y',{0},'Z',{78.363},'sph_theta',{0},'sph_phi',{67.208},'sph_radius',{85},'urchan',{65},'ref',{''},'datachan',{0}));
EEG = eegh(temp_comStr,EEG);

% 6. c0001_d0501__remBad: Reject Bad Times/Samples (using trimOutlier)

% Remove Samples Times Using TRIMOUTLIER
EEG.cc.c0001_d0501__remBad.channelSdLowerBound = -Inf; % SD
EEG.cc.c0001_d0501__remBad.channelSdUpperBound =  Inf; % SD
EEG.cc.c0001_d0501__remBad.amplitudeThreshold  =  222; % uV
EEG.cc.c0001_d0201__remBad.pointSpreadWidth    = 2000; % samples (use 2000 or 4000)
EEG = trimOutlier(EEG,EEG.cc.c0001_d0501__remBad.channelSdLowerBound,EEG.cc.c0001_d0501__remBad.channelSdUpperBound,EEG.cc.c0001_d0501__remBad.amplitudeThreshold,EEG.cc.c0001_d0501__remBad.pointSpreadWidth);

% 7. c0001_d0601__pcaICA: ICA

EEG.cc.c0001_d0601__pcaICA.rankData = rank(double(EEG.data'));
EEG.cc.c0001_d0601__pcaICA.rankChan = length(EEG.cc.c0001_d0201__remBad.chanlocs_006_trimOutlier);
EEG.cc.c0001_d0601__pcaICA.rankUsed = min([EEG.cc.c0001_d0601__pcaICA.rankData,EEG.cc.c0001_d0601__pcaICA.rankChan]);
EEG = pop_runica(EEG,'icatype','binica','pca',EEG.cc.c0001_d0601__pcaICA.rankUsed,'extended',1,'interupt','off');
   
% 8. c0001_d0701__adjust: ADJUST

% before running ADJUST the averaged channels should be removed
% the corresponding 'icasphere', 'icaweights', 'icachansind', ETC
% will also be adjusted
EEG = pop_select(EEG,'channel',{EEG.cc.c0001_d0201__remBad.chanlocs_006_trimOutlier.labels}');
% afterwards the missing channels can be restored

% (GUI) Tools > ADJUST
% (GUI) Tools > Remove Components

% Bring back the interpolated channels
[EEG] = pop_interp(EEG,EEG.cc.c0001_d0001__dnSamp.chanlocs_004_lookedup_no_ref,'spherical');
EEG.cc.c0001_d0701__adjust.chanlocs_008_from_lookedup = EEG.chanlocs;

% Remove Bad Samples Using TRIMOUTLIER
EEG.cc.c0001_d0701__adjust.channelSdLowerBound = -Inf; % SD
EEG.cc.c0001_d0701__adjust.channelSdUpperBound =  Inf; % SD
EEG.cc.c0001_d0701__adjust.amplitudeThreshold  =  111; % uV (111)
EEG.cc.c0001_d0701__adjust.pointSpreadWidth    = 2000; % samples (use 4000 or 2000)
EEG = trimOutlier(EEG, EEG.cc.c0001_d0701__adjust.channelSdLowerBound, EEG.cc.c0001_d0701__adjust.channelSdUpperBound, EEG.cc.c0001_d0701__adjust.amplitudeThreshold, EEG.cc.c0001_d0701__adjust.pointSpreadWidth);
   
% Author: cybercraft
% Created: 2019-11-04 Mon 16:26

