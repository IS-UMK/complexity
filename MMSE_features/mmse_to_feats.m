function  f=mmse_to_feats(input_file, output_file)

% Reads CSV file with raw MMSE scales, compute 4 basic features (auc,
% max_slope, avg_entropy, diff_std) and save results in CSV format.

    selected_scales = 1:11;
    features_set = 'basic';
    
    if nargin < 2
        output_file = 'features.csv';
    end

    x = readtable(input_file);
    x.Properties.RowNames = x.ID;
    mmse_vars = regex_table_vars(x, '^MMSEValuesFinal_[0-9]+$');
    
    f = extract_features(x, mmse_vars(selected_scales), features_set);
    writetable(f, output_file, 'Delimiter', ';');
end