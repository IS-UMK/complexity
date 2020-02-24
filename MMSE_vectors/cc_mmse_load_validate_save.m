function [] = cc_mmse_load_validate_save(file,elecAn)

% INPUT ARGUMENTS  
% 1. file (string): Preprocessed EEG data in EEGLAB format (ALLEEG file), e.g.,
% file = 'ALLEEG_preprocessed.mat'
% 2. elecAn (cell): list of electrodes to be analyzed in lowercase, e.g.,
% elecAn = {'f3','f4','cz','p3','p4'}    

    load(file);
    cases = length(UJ2);     
    
    % initial length of data = length of the first sample batch of the
    % first subject
    numberSamples = size(UJ2(1).data,2); 
    for caseID = 1:cases
        numberSamples = min(numberSamples, size(UJ2(caseID).data,2));
    end
    disp(['CC: number of samples: ',num2str(numberSamples)]); 
    
    for caseID = 1:cases
        disp(['CC: ',datestr(now),': starting: ',num2str(caseID)]);        
        
        % checks minimal length of data and whether
        % all required electrodes are present for the current subject
        labelsTemp = lower({UJ2(caseID).chanlocs.labels});
        labelsIndex = find(ismember(labelsTemp,elecAn));
        if (length(labelsIndex) ~= length(elecAn) || isempty(UJ2(caseID).subject))
            continue;
        end        
        disp(['CC: electrodes indices: ',num2str(labelsIndex)]);                
        
        % actual MMSE computation
        EEGData = UJ2(caseID).data(labelsIndex,1:numberSamples)';
        UJ2(caseID).MMSE.MMSEValues = cc_mmse_prepare_computation(EEGData);

        disp(['CC: ',datestr(now),': finished: ',num2str(caseID)]);    
        
        x=struct;
        x.name=[sprintf('%s',UJ2(caseID).subject)];
        x.mmse=UJ2(caseID).MMSE.MMSEValues(:,1)'; 
        filename_temp=[x.name,'.csv'];
        writetable(struct2table(x),filename_temp,'Delimiter','\t');
    end
    
    output = table();
    fileNames = dir('*.csv');
    for i=1:numel(fileNames)
        res = readtable(fileNames(i).name);
        output = [output; res];
        delete(fileNames(i).name);
    end
    filename = [sprintf('%s_',elecAn{:}),sprintf('%i_',numberSamples),datestr(now,'__yyyy_mm_dd___HH_MM_SS'),'.csv'];
    writetable(output,filename,'Delimiter','\t');
    
end