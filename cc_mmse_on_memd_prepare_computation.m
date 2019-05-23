function MMSEValues = cc_mmse_on_memd_prepare_computation(IMFs)

% embedding dimension
embedDim = 2;
% time lag value
timeLagValue = 1;
% similarity tolerance level
similarityTolLev = 0.15;
% self-explanatory
[numChan,numIMFs,numPnts] = size(IMFs); 

% cumulative sums of IMFs
summedIMFs = cell(1,numIMFs-1);
% current IMF to be added starting with the first IMF as advised in Mandic's
% papers (the last IMF is the trend)
summedIMFs{1} = transpose(squeeze(IMFs(:,1,:)));
% adding rest of cumulative IMFs sums
for i = 2:numIMFs-1
    tempIMF = transpose(squeeze(IMFs(:,i,:)));
    summedIMFs{i} = summedIMFs{i-1}+tempIMF;
end

% normalizing time series to be within [0,1] as done in mmse.m function by Rehman and Mandic
% note however, that this is redundant, as z-score is computed afterwards
for i = 1:numIMFs-1
    for j = 1:numChan
        m = min(summedIMFs{i}(:,j));
        M = max(summedIMFs{i}(:,j));
        summedIMFs{i}(:,j) = (summedIMFs{i}(:,j)-m)/(M-m);
    end
    summedIMFs{i} = zscore(summedIMFs{i});
end

% r,M,tau parameters are selected as in Ahmed and Mandic's papers
sd = numChan; % sum(std(summedIMFs{i})) = numChan, as z-score ensures std=1
     % for each signal;
r = similarityTolLev*sd;    
M = embedDim*ones(1,numChan);
tau = timeLagValue*ones(1,numChan);

% the first column of MMSEValues stores MMSE values, the second
% column stores indices of these values, from i=1 corresponding to
% first IMF, to i=numIMFs-1 corresponding to cumulative sum of all
% IMFs considered: from the first IMF to the penultimate IMF
MMSEValues = zeros(numIMFs-1,2);
for i=1:numIMFs-1
    % actual MMSE computation
    e = mvsampen_full(M,r,tau,transpose(summedIMFs{i}));

    MMSEValues(i,:) = [e i];
end

