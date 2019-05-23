function [] = cc_mmse_on_memd_load_save(file)
 
% INPUT ARGUMENTS 
% 1. file (string): Preprocessed EEG data in EEGLAB format (ALLEEG file) which
% includes MEMD structure calculated using cc_memd, e.g.,
% file = 'ALLEEG_preprocessed_MEMD.mat'
% NOTE: this function assumes correct form of input file, no checks
% are performed.    

    load(file);
    cases = length(ALLEEG);

    for caseID = 1:cases
        disp(['CC: ',datestr(now),': starting: ',num2str(caseID)])
        % actual MMSE computation
        IMFData = ALLEEG(caseID).MEMD.IMF;
        ALLEEG(caseID).MEMD.MMSEValues = cc_mmse_on_memd_prepare_computation(IMFData); 
        
        disp(['CC: ',datestr(now),': finished: ',num2str(caseID)]);
    end

    %iff all went well, results are saved...
    filename = ['ALLEEG_preprocessed_MEMD_MMSE_',sprintf('%s_',ALLEEG(1).METADATA.elecAn{:}),sprintf('%i_',ALLEEG(1).METADATA.numberSamples),datestr(now,'__yyyy_mm_dd___HH_MM_SS'),'.mat'];
    save(filename,'ALLEEG','-v7.3')
    
    %...and exported to csv files
    ID={ALLEEG.subject}';
    MMSEValuesExport=cell(cases,1);
    for i=1:cases
        MMSEValuesExport{i}=ALLEEG(i).MEMD.MMSEValues(:,1)';
    end
    % minimum number of IMFs among subjects is used for analysis
    min_size=min(cellfun('size', MMSEValuesExport, 2));
    MMSEValuesFinal = cell2mat(cellfun(@(x) x(1:min_size), MMSEValuesExport, 'un', 0));
    
    filename = ['ALLEEG_preprocessed_MEMD_MMSE_',sprintf('%s_',ALLEEG(1).METADATA.elecAn{:}),sprintf('%i_',ALLEEG(1).METADATA.numberSamples),datestr(now,'__yyyy_mm_dd___HH_MM_SS'),'.csv'];
    writetable(table(ID,MMSEValuesFinal),filename,'Delimiter','\t');
