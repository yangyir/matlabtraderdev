function [continuousfutures,continuousret,continuousindex] = bkfunc_buildcontinuousfutures(rollinfo,oidata)

    %to find the first index with continous rolling information
    rollFirstIdx = 1;
    i = rollFirstIdx;
    while i < size(rollinfo,1)
        for i = rollFirstIdx:size(rollinfo,1)
            if isempty(rollinfo{i,1})
                rollFirstIdx = i+1;
                break
            end
        end
    end
    
    count = 0;
    for i = rollFirstIdx:size(rollinfo,1)
        if isempty(rollinfo{i,1})
            continue
        end

        if i ==  1 && ~isempty(rollinfo{i,1})
            count = count + rollinfo{i,2};
        elseif i > 1 && isempty(rollinfo{i-1,1})
            count = count + rollinfo{i,2};
        else
            count = count + rollinfo{i,2} - rollinfo{i-1,3};
        end
    end
    count = count + size(oidata{end},1)-rollinfo{end,3};
    continuousfutures = zeros(count,6);
    idx = 0;
    %on the roll date, we choose the 
    for i = rollFirstIdx:size(rollinfo,1)
        if isempty(rollinfo{i,1})
            continue
        end
        if i == 1 && ~isempty(rollinfo{i,1})
            idx = idx+rollinfo{i,2};
            continuousfutures(1:idx,1:5) = oidata{i}(1:idx,1:5);
            continuousfutures(idx,6) = 1;%roll date indicator
        elseif i > 1 && isempty(rollinfo{i-1,1})
            idx = idx + rollinfo{i,2};
            continuousfutures(1:idx,1:5) = oidata{i}(1:idx,1:5);
            continuousfutures(idx,6) = 1;%roll date indicator
        else
            numNewEntry = rollinfo{i,2} - rollinfo{i-1,3};
            continuousfutures(idx+1:idx+numNewEntry,1:5) = oidata{i}(rollinfo{i-1,3}+1:rollinfo{i,2},1:5);
            continuousfutures(idx+numNewEntry,6) = 1;%roll date indicator
            idx = idx + numNewEntry;
        end
    end
    numNewEntry = size(oidata{end},1)-rollinfo{end,3};
    continuousfutures(idx+1:idx+numNewEntry,1:5) = oidata{end}(rollinfo{end,3}+1:size(oidata{end},1),1:5);
    %
    %
    %we record the close price as of the first futures contract on the roll
    %date and we record the close price as of the second futures contract
    %on the next business date after the roll date
    continuousret = [continuousfutures(2:end,1),...
        log(continuousfutures(2:end,2)./continuousfutures(1:end-1,5)),...
        log(continuousfutures(2:end,3)./continuousfutures(1:end-1,5)),...
        log(continuousfutures(2:end,4)./continuousfutures(1:end-1,5)),...
        log(continuousfutures(2:end,5)./continuousfutures(1:end-1,5))];
    for i = 1:size(rollinfo,1)
        if ~isempty(rollinfo{i,1})
            tRoll = rollinfo{i,1};
            idx1 = rollinfo{i,2};
            idx2 = rollinfo{i,3};
            %sanity check to make sure that both prices on recored on the
            %same business date
            if oidata{i}(idx1,1) ~= tRoll || ...
                    oidata{i+1}(idx2,1) ~= tRoll
                error('internal error')
            end
            %we'd take the return of the second futures contract after the
            %roll date
            if idx2 == size(oidata{i+1},1)
                continue;
            end
            ret2 = [log(oidata{i+1}(idx2+1,2)/oidata{i+1}(idx2,5)),...
                log(oidata{i+1}(idx2+1,3)/oidata{i+1}(idx2,5)),...
                log(oidata{i+1}(idx2+1,4)/oidata{i+1}(idx2,5)),...
                log(oidata{i+1}(idx2+1,5)/oidata{i+1}(idx2,5))];
            idx = find(continuousret(:,1) == tRoll)+1;
            continuousret(idx,2:end) = ret2;
        end
    end
    %
    %
    continuousindex = zeros(size(continuousfutures,1),5);
    continuousindex(:,1) = continuousfutures(:,1);
    continuousindex(1,2:end) = 1;
    for i = 2:size(continuousindex,1)
        continuousindex(i,2) = continuousindex(i-1,5)*exp(continuousret(i-1,2));
        continuousindex(i,3) = continuousindex(i-1,5)*exp(continuousret(i-1,3));
        continuousindex(i,4) = continuousindex(i-1,5)*exp(continuousret(i-1,4));
        continuousindex(i,5) = continuousindex(i-1,5)*exp(continuousret(i-1,5));
    end



end