function MMSEValues = cc_mmse_prepare_computation(EEGData)
    
% embedding dimension
    embedDim = 2;
    % time lag value
    timeLagValue = 1;
    % similarity tolerance level
    similarityTolLev = 0.15;
    % number of scale factors 
    scaleFactor = 12;
    % self-explanatory
    [numPnts,numChan] = size(EEGData); 

    % normalizing time series
    EEGData = zscore(EEGData);

    % r,M,tau parameters
    sd = numChan; % sum(std(EEGData)) = numChan, as z-score ensures std=1
                  % for each signal;
    r = similarityTolLev*sd;
    M = embedDim*ones(1,numChan);
    tau = timeLagValue*ones(1,numChan);

    % the first column of MMSEValues stores MMSE values, the second
    % column stores indices of these values, from i=1 corresponding to
    % scale=1, to scale=scaleFactor corresponding to maximum scale considered
    for j = 1:scaleFactor
        disp(['CC: scale factor: ',num2str(j),'...']);
        % time series graining
        for p = 1:numChan
            for i = 1:numPnts/j
                y(i)=0;
                for k=1:j
                    y(i)=y(i)+EEGData((i-1)*j+k,p);
                end
                y(i)=y(i)/j;
            end
            z=y(1:floor(numPnts/j));
            X(:,p)=z;
        end
        % actual MMSE computation
        e = mvsampen_full(M,r,tau,X');

        MMSEValues(j,:) = [e j];
        clear X;
    end

end