function d = pdist3(x, y, distance)
    % Row-wise distance between X and Y.
    % distance: 'euclidean' , 'chebychev',  'cosine' , 'max_diff_id'
    
    if nargin < 3
        distance = 'euclidean';
    end

    assert(isequal(size(x), size(y)))
    
    n = size(x, 1);
    d = zeros(n, 1);

    if strcmp(distance, 'max_diff_id')
        for i=1:n
            [~, d(i)] = max(abs(x(i,:)-y(i,:)), [], 2); 
        end
    else
        for i=1:n
            d(i) = pdist2(x(i,:), y(i,:), distance);
        end
    end
end
