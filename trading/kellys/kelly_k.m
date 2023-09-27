function k = kelly_k(signalStr,assetStr,signallistCell,assetlistCell,kMat)
    if ~ischar(signalStr)
        error('kelly_k:invalid signal input, a string is required');
    end
    %    
    if ~ischar(assetStr)
        error('kelly_k:invalid asset input, a string is required');
    end
    %
    if ~iscell(signallistCell)
        error('kelly_k:invalid signallist input, a cell is required');
    end
    %
    if ~iscell(assetlistCell)
        error('kelly_k:invalid assetlist input, a cell is required');
    end
    %
    if ~isnumeric(kMat)
        error('kelly_k:invalid kmat input, a numeric matrix is required');
    end
    
    [m,n] = size(kMat);
    if m ~= length(signallistCell)
        error('kelly_k:mismatch between signallist and kmat');
    end
    %
    if n ~= length(assetlistCell)
        error('kelly_k:mismatch between assetlist and kmat')
    end
    
    idxSignal = 0;
    for i = 1:m
        if strcmpi(signalStr,signallistCell{i})
            idxSignal = i;
            break;
        end
    end
    if idxSignal <= 0
        error('kelly_k:invalid signal or signallist input as signal cannot be found')
    end
    idxAsset = 0;
    for i = 1:n
        if strcmpi(assetStr,assetlistCell{i})
            idxAsset = i;
            break
        end
    end
    if idxAsset <= 0
        error('kelly_k:invalid asset or assetlist input as signal cannot be found')
    end
    
    k_ = kMat(idxSignal,idxAsset);
    if ~isnan(k_)
        k = k_;
    else
        for i = 1:n
           if strcmpi('all',assetlistCell{i})
               idxAsset = i;
               break
           end 
        end
        k = kMat(idxSignal,idxAsset);
    end
end