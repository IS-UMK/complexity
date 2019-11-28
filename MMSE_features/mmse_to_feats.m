function  f=mmse_to_feats(input_file, output_file, scales)

% Reads CSV file with raw MMSE scales, compute 4 basic features (auc,
% max_slope, avg_entropy, diff_std) and save results in CSV format.
    
    if nargin < 3
        scales = 1:12;
    end
   
    if nargin < 2
        output_file = 'features.csv';
    end
    
    features_set = 'basic';

    x = readtable(input_file);
    id_name = x.Properties.VariableNames(1);
    x.Properties.RowNames = x.(id_name{1});
    
    var_names = x.Properties.VariableNames(2:end);
    mmse_vars = var_names(scales);
    
    f = extract_features(x, mmse_vars, features_set);
    writetable(f, output_file, 'Delimiter', ';');
end