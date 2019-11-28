function out_t=extract_features(x)
% For given table contigning entropy scales creates new table with extracted features:
% * 'auc'         - area under curve
% * 'max_slope'   - maximum slope value in small scales (original 1-7, here 1-4) 
% * 'avg_entropy' - average entropy in large scales (org. last 5 scales, here last 3 scales)
% * 'diff_std'    - variation betwen two subsequent scales in the first
%                   half of the scales

out_t = table();

n = size(x, 2);

out_t.auc = auc(x);
out_t.Properties.VariableDescriptions{'auc'} = 'AUC';

scales = 1:ceil(n*(7/20));
out_t.max_slope = max_slope(x, scales);
out_t.Properties.VariableDescriptions{'max_slope'} = 'Max slope in low scales';

scales = n-ceil(n*(5/20))+1:n;
out_t.avg_entropy = avg_entropy(x, scales);
out_t.Properties.VariableDescriptions{'avg_entropy'} = 'Avg. entropy in high scales';

scales = 1:ceil(n/2);
out_t.diff_std = diff_std(x, scales);
out_t.Properties.VariableDescriptions{'diff_std'} = 'Differences variation';

end

function y = auc(x, scales)
    if nargin < 2
       scales = 1:size(x, 2);   % by default take all scales
    end
    
    tmp = x(:, scales);
    y = sum(0.5 * (tmp(:, 1:end-1) + tmp(:, 2:end)), 2);
end

function y = max_slope(x, scales)
    if nargin < 2
       scales = 1:7;   % by default take small scales [1:7]
    end
    
    tmp = x(:, scales);
    [min_v, min_id]=min(tmp, [], 2);
    [max_v, max_id]=max(tmp, [], 2);
    y = (max_v - min_v) ./ (max_id - min_id);
end

function y = avg_entropy(x, scales)
    if nargin < 2
        n = size(x, 2);
        scales = n-5:n;   % by default take last 5 scales
    end
    
    y = mean(x(:, scales), 2);
end

function y = diff_std(x, scales)
    if nargin < 2
       n=size(x, 2) / 2;
       scales = 1:n;   % by default take first half of the scales   end
    end
    
    tmp = x(:, scales);
    y = std(abs(tmp(:, 2:end) - tmp(:, 1:end-1)), 0, 2);
end

