function [ret] = withdrawpendingentrusts(counter,codestr)
    if ~isa(counter,'CounterCTP')
        error('withdrawentrust:invalid ctp counter input')
    end
    
    %note: this function shall withdraw all pending entrusts if the ctp
    %code is not provided while it only withdraw pending entrusts
    %associated with the given ctp code
    
    if nargin < 2
        [~,pendingEntrusts] = statsentrust(counter);
    else
        [~,pendingEntrusts] = statsentrust(counter,codestr);
    end
    
    nPending = length(pendingEntrusts);
    
    if nPending == 0
        return;
    end
    
    ret = zeros(nPending,1);
    for i = 1:nPending
        ret(i) = withdrawentrust(counter,pendingEntrusts{i});
    end
    
end