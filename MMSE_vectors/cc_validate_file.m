function [ALLEEG,labelsIndex,numberSamples] = cc_validate_file(file,elecAn)

% INPUT ARGUMENTS  
% 1. file (string): Preprocessed EEG data in EEGLAB format (ALLEEG file), e.g.,
% file = 'ALLEEG_preprocessed.mat'
% 2. elecAn (cell): list of electrodes to be analyzed in lowercase, e.g.,
% elecAn = {'f3','f4','cz','p3','p4'}    

    load(file);
    cases = length(ALLEEG);
    % initial length of data = length of the first sample batch of the
    % first subject
    numberSamples = size(ALLEEG(1).uncuts(1).data,2); 
    
    for caseID = 1:cases
        for i = 1:length(ALLEEG(caseID).uncuts)
            numberSamples = min(numberSamples, size(ALLEEG(caseID).uncuts(i).data,2));
        end
        % stores all electrode labels for EEG signals recorded 
        labelsTemp = lower({ALLEEG(caseID).chanlocs.labels});
        % indices of electrodes on elecAn list: all shall be found
        % for all subjects, otherwise the function exits with an
        % error and no output is generated
        labelsIndex = find(ismember(labelsTemp,elecAn));
        
        if (length(labelsIndex) ~= length(elecAn) || isempty(ALLEEG(caseID).subject))
            error(['EEG signal for subject ',num2str(caseID),10,'have some electrodes among ',strjoin(elecAn),10,'that have not been found in the data for this subject.',10,'or subject field is empty',10,'Function execution aborted.']);
        end
    end
