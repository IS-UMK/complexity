function out_t=extract_features(x)
% For given table contigning entropy scales creates new table with extracted features:
% * 'auc'         - area under curve
% * 'max_slope'   - maximum slope value in small scales (original 1-7, here 1-4) 
% * 'avg_entropy' - average entropy in large scales (org. last 5 scales, here last 3 scales)

out_t = table();

n = size(x, 2);

out_t.auc = auc(x);
out_t.Properties.VariableDescriptions{'auc'} = 'AUC';

out_t.max_slope = max_slope(x);
out_t.Properties.VariableDescriptions{'max_slope'} = 'Max slope in low scales';

out_t.avg_entropy = avg_entropy(x);
out_t.Properties.VariableDescriptions{'avg_entropy'} = 'Avg. entropy in high scales';

end

function y = auc(x)
    scales = 1:size(x, 2);   % by default take all scales
    
    tmp = x(:, scales);
    
    y = sum(0.5 * (tmp(:, 1:end-1) + tmp(:, 2:end)), 2);
end

function y = max_slope(x)
    scales = 1:4;   % by default take small scales [1:4]
    
    tmp = x(:, scales);
    [min_v, min_id]=min(tmp, [], 2);
    [max_v, max_id]=max(tmp, [], 2);
    
    y = (max_v - min_v) ./ (max_id - min_id);
end

function y = avg_entropy(x)
    n = size(x, 2);
    scales = n-3:n;   % by default take last 4 scales
    
    y = mean(x(:, scales), 2);
end
