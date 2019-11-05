function [ALLEEG,labelsTemp,labelsIndex] = cc_validate_file(file,elecAn,numberSamples)

% INPUT ARGUMENTS 
% 1. file (string): Preprocessed EEG data in EEGLAB format (ALLEEG file), e.g.,
% file = 'ALLEEG_preprocessed.mat'
% 2. elecAn (cell): list of electrodes to be analyzed in lowercase, e.g.,
% elecAn = {'f3','f4','cz','p3','p4'}    
% 3. numberSamples (integer): number of samples of EEG signal to be
% included, e.g., numberSamples = 10241    

    load(file);
    cases = length(ALLEEG);

    for caseID = 1:cases
        % stores all electrode labels for EEG signals recorded 
        labelsTemp = lower({ALLEEG(caseID).chanlocs.labels});
        % indices of electrodes on elecAn list: all shall be found
        % for all subjects, otherwise the function exits with an
        % error and no output is generated
        labelsIndex = find(ismember(labelsTemp,elecAn));
        
        if (length(ALLEEG(caseID).data) < numberSamples | length(labelsIndex) ~= length(elecAn) | isempty(ALLEEG(caseID).subject))
            error(['EEG signal for subject ',num2str(caseID),10,'is either shorter than ',num2str(numberSamples),10,'or some electrodes among ',strjoin(elecAn),10,'have not been found in the data for this subject.',10,'or subject field is empty',10,'Function execution aborted.']);
        end
    end
