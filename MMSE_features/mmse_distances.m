function  d=mmse_distances(input_file1, input_file2, output_file)

% Reads pair of CSV file with raw MMSE scales, compute distances for each subject (row-wise)

    selected_scales = 1:11;
    
    % distances = { 'euclidean' , 'chebychev',  'cosine' , 'max_diff_id'};
    distances = { 'euclidean' , 'chebychev',  'cosine' };
    
    if nargin < 3
        output_file = 'distances.csv';
    end

    x = readtable(input_file1);
    x.Properties.RowNames = x.ID;
    
    y = readtable(input_file2);
    y.Properties.RowNames = y.ID;
    
    mmse_vars = regex_table_vars(x, '^MMSEValuesFinal_[0-9]+$');
    
    d = x(:, 'ID');
    
    for dst = distances
        distance = dst{1};
        d.(distance) = pdist3(x{:, mmse_vars(selected_scales)}, y{:, mmse_vars(selected_scales)}, distance);
    end
    
    writetable(d, output_file, 'Delimiter', ';');
end