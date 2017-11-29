function [] = updateentrusts(strategy)
    n = strategy.entrustspending_.count;
    for i = 1:n
        e = strategy.entrustspending_.node(i);
        if e.entrustStatus ~= -1
            updateportfoliowithentrust(strategy,e);
        end
    end
end
%end of updateentrusts