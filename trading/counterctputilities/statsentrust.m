function [allEntrusts,pendingEntrusts,filledEntrusts,withdrawnEntrusts] = statsentrust(counter,codestr)
    %function to break all entrusts that queried with the CTP counter 
    %the function shall return all the entrusts in case the ctp code is not
    %presented while it filters out the entrusts associated with the
    %specified ctp code if it is given
    
    if nargin < 2, codestr = '';end
    
    if ~isa(counter,'CounterCTP')
        error('statsentrust:invalid ctp counter input')
    end
    
    entrustArray = counter.loadEntrusts;
    nEntrust = length(entrustArray);
    allEntrusts = cell(nEntrust,1);
    
    if ~isempty(codestr)
        count = 0;
        for i = 1:length(entrustArray)
            if strcmpi(entrustArray(i).asset_code,codestr)
                count = count+1;
                allEntrusts{count} = entrustArray(i);
            end
        end
        allEntrusts = allEntrusts(1:count);
    else
        for i = 1:length(entrustArray)
            allEntrusts{i} = entrustArray(i);
        end
    end
    
    nEntrust = length(allEntrusts);
    pendingEntrusts = cell(nEntrust,1);
    filledEntrusts = cell(nEntrust,1);
    withdrawnEntrusts = cell(nEntrust,1);
    
    countPending = 0;
    countFilled = 0;
    countWithdrawn = 0;
    
    for i = 1:nEntrust
        e = allEntrusts{i};
        if  e.deal_volume == e.target_volume
            countFilled = countFilled + 1;
            filledEntrusts{countFilled} = e;
        elseif e.deal_volume < e.target_volume && e.cancel_volume == 0
            countPending = countPending + 1;
            pendingEntrusts{countPending} = e;
        elseif e.deal_volume < e.target_volume && e.cancel_volume == e.target_volume
            countWithdrawn = countWithdrawn + 1;
            withdrawnEntrusts{countWithdrawn} = e;
        else
            error('statsentrust:internal error')
        end
    end
    
    if countPending == 0
        pendingEntrusts = {};
    else
        pendingEntrusts = pendingEntrusts(1:countPending);
    end
    
    if countFilled == 0
        filledEntrusts = {};
    else
        filledEntrusts = filledEntrusts(1:countFilled);
    end
    
    if countWithdrawn == 0
        withdrawnEntrusts = {};
    else
        withdrawnEntrusts = withdrawnEntrusts(1:countWithdrawn);
    end
    
    
end