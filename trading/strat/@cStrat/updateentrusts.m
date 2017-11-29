function [] = updateentrusts(strategy)
%note:the function loop through all the pending entrusts and check whether
%the entrust is closed,i.e.fully filled or canceled. Then it will remove
%the closed entrust from the pending entrust array and insert the entrust
%into the finished entrust array. For the entrust which is closed, the
%portfolio shall be updated
    n = strategy.entrustspending_.count;
    for i = n:-1:1
        e = strategy.entrustspending_.node(i);
        f1 = strategy.counter_.queryEntrust(e);
        f2 = e.is_entrust_closed;
        if f1&&f2
            %we shall remove the entrust from entrustspending and push it
            %into entrustsfinished instead
            rmidx = i;
            strategy.entrustspending_.removeByIndex(rmidx);
            strategy.entrustsfinished_.push(e);
            updateportfoliowithentrust(strategy,e);
        end
    end
end
%end of updateentrusts