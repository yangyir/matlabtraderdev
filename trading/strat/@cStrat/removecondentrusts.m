function [] = removecondentrusts(strategy,condentrusts2remove,varargin)
%cStrat
    n2remove = condentrusts2remove.latest;
    for k = 1:n2remove
        e2remove = condentrusts2remove.node(k);
        npending = strategy.helper_.condentrustspending_.latest;
        for kk = npending:-1:1
            e = strategy.helper_.condentrustspending_.node(kk);
            if strcmpi(e.instrumentCode,e2remove.instrumentCode) && ...
                    (e.direction == e2remove.direction) && ...
                    (e.volume == e2remove.volume) && ...
                    (e.price == e2remove.price)
                rmidx = kk;
                strategy.helper_.condentrustspending_.removeByIndex(rmidx);
                break
            end
        end
    end

end
