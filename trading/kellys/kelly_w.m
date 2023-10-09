function w = kelly_w(signalStr,assetStr,signallistCell,assetlistCell,wMat)
    if ~ischar(signalStr)
        error('kelly_w:invalid signal input, a string is required');
    end
    %    
    if ~ischar(assetStr)
        error('kelly_w:invalid asset input, a string is required');
    end
    %
    if ~iscell(signallistCell)
        error('kelly_w:invalid signallist input, a cell is required');
    end
    %
    if ~iscell(assetlistCell)
        error('kelly_w:invalid assetlist input, a cell is required');
    end
    %
    if ~isnumeric(wMat)
        error('kelly_w:invalid kmat input, a numeric matrix is required');
    end
    
    [m,n] = size(wMat);
    if m ~= length(signallistCell)
        error('kelly_w:mismatch between signallist and kmat');
    end
    %
    if n ~= length(assetlistCell)
        error('kelly_w:mismatch between assetlist and kmat')
    end
    
    idxSignal = 0;
    for i = 1:m
        if strcmpi(signalStr,signallistCell{i})
            idxSignal = i;
            break;
        end
    end
    if idxSignal <= 0
        error('kelly_w:invalid signal or signallist input as signal cannot be found')
    end
    idxAsset = 0;
    for i = 1:n
        if strcmpi(assetStr,assetlistCell{i})
            idxAsset = i;
            break
        end
    end
    if idxAsset <= 0
        error('kelly_w:invalid asset or assetlist input as signal cannot be found')
    end
    
    w_ = wMat(idxSignal,idxAsset);
    if ~isnan(w_)
        w = w_;
    else
        for i = 1:n
           if strcmpi('all',assetlistCell{i})
               idxAsset = i;
               break
           end 
        end
        w = wMat(idxSignal,idxAsset);
    end
end