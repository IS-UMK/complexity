function  d=mmse_distances(input_file1, input_file2, output_file, scales)

% Reads pair of CSV file with raw MMSE scales, compute distances for each subject (row-wise)

    if nargin < 4
        scales = 1:12;
    end
    
    % distances = { 'euclidean' , 'chebychev',  'cosine' , 'max_diff_id'};
    distances = { 'euclidean' , 'chebychev',  'cosine' };
    
    if nargin < 3
        output_file = 'distances.csv';
    end

    x = readtable(input_file1);
    x_id_name = x.Properties.VariableNames(1);
    x.Properties.RowNames = x.(x_id_name{1});
    
    y = readtable(input_file2);
    y_id_name = y.Properties.VariableNames(1);
    y.Properties.RowNames = y.(y_id_name{1});
    
    x_var_names = x.Properties.VariableNames(2:end);
    x_mmse_vars = x_var_names(scales);
    
    y_var_names = y.Properties.VariableNames(2:end);
    y_mmse_vars = y_var_names(scales);
    
    d = x(:, x_id_name);
    
    for dst = distances
        distance = dst{1};
        d.(distance) = pdist3(x{:, x_mmse_vars}, y{:, y_mmse_vars}, distance);
    end
    
    writetable(d, output_file, 'Delimiter', ';');
end