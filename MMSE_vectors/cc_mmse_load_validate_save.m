function [] = cc_mmse_load_validate_save(file,elecAn)

% INPUT ARGUMENTS  
% 1. file (string): Preprocessed EEG data in EEGLAB format (ALLEEG file), e.g.,
% file = 'ALLEEG_preprocessed.mat'
% 2. elecAn (cell): list of electrodes to be analyzed in lowercase, e.g.,
% elecAn = {'f3','f4','cz','p3','p4'}    

% checks minimal length of data and whether
% all required electrodes are present for all subjects
    [ALLEEG,labelsIndex,numberSamples] = cc_validate_file(file,elecAn);
    disp(['CC: number of samples: ',num2str(numberSamples)]); 
    
    cases = length(ALLEEG);     
 
    for caseID = 1:cases
        disp(['CC: ',datestr(now),': starting: ',num2str(caseID)]);        
    
        % actual MMSE computation
        for i = 1:length(ALLEEG(caseID).uncuts)
            EEGData = ALLEEG(caseID).uncuts(i).data(labelsIndex,1:numberSamples)';
            ALLEEG(caseID).MMSE.data(i).MMSEValues = cc_mmse_prepare_computation(EEGData);
        end

        disp(['CC: ',datestr(now),': finished: ',num2str(caseID)]);    
    end

    %export results to csv file
    for caseID=1:cases
        for i=1:length(ALLEEG(caseID).uncuts)
            x=struct;
            x.name=[sprintf('%s',ALLEEG(caseID).subject),sprintf('___RUN_%i',i)];
            x.mmse=ALLEEG(caseID).MMSE.data(i).MMSEValues(:,1)'; 
            filename_temp=[x.name,'.csv'];
            writetable(struct2table(x),filename_temp,'Delimiter','\t');
        end
    end
   
    output = table();
    fileNames = dir('*.csv');
    for i=1:numel(fileNames)
         res = readtable(fileNames(i).name);
         output = [output; res];
    end
    filename = [sprintf('%s_',elecAn{:}),sprintf('%i_',numberSamples),datestr(now,'__yyyy_mm_dd___HH_MM_SS'),'.csv'];
    writetable(output,filename,'Delimiter','\t');
  