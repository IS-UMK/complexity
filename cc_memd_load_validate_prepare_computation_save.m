function [] = cc_memd_load_validate_prepare_computation_save(file,elecAn,numberSamples,numberDirections)

% INPUT ARGUMENTS 
% 1. file (string): Preprocessed EEG data in EEGLAB format (ALLEEG file), e.g.,
% file = 'ALLEEG_preprocessed.mat'
% 2. elecAn (cell): list of electrodes to be analyzed in lowercase, e.g.,
% elecAn = {'f3','f4','cz','p3','p4'}    
% 3. numberSamples (integer): number of samples of EEG signal to be
% included, e.g., numberSamples = 10241
% 4. numberDirections (integer): number of directions for MEMD
% computation, e.g., numberDirections = 64 (authors recommend that
% at least 4 times number of time series analysed is necessary)

% checks whether all signals are of sufficient length and
% all required electrodes are present for all subjects
    [ALLEEG,labelsTemp,labelsIndex] = cc_validate_file(file,elecAn,numberSamples);
    
    cases = length(ALLEEG);     

    % computation of MEMD to be stored for each subject in
    % ALLEEG(caseID).MEMD structure 
    for caseID = 1:cases
        disp(['CC: ',datestr(now),': starting: ',num2str(caseID)]);        

        %save metadata
        ALLEEG(caseID).METADATA.file = file;
        ALLEEG(caseID).METADATA.elecAn = elecAn;
        ALLEEG(caseID).METADATA.numberSamples = numberSamples;
        
        % fields storing (confirming) that elecAn electrodes are analyzed using MEMD for all subjects
        ALLEEG(caseID).MEMD.chanSelLab = labelsTemp(labelsIndex);
        ALLEEG(caseID).MEMD.chanSelNum = labelsIndex;
        % actual MEMD computation
        EEGData = ALLEEG(caseID).data(labelsIndex,1:numberSamples)';
        ALLEEG(caseID).MEMD.IMF = memd(EEGData,numberDirections);

        disp(['CC: ',datestr(now),': finished: ',num2str(caseID)]);    
    end
    
    %iff all went well, results are saved
    filename = ['ALLEEG_preprocessed_MEMD_',sprintf('%s_',ALLEEG(1).METADATA.elecAn{:}),sprintf('%i_',ALLEEG(1).METADATA.numberSamples),datestr(now,'__yyyy_mm_dd___HH_MM_SS'),'.mat'];
    save(filename,'ALLEEG','-v7.3');
