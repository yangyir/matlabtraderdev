function val = getavailablefund(obj)
%cStrat
    try
        currentmargin = obj.getcurrentmargin;
    catch err
        error('error in getcurrentmargin:%s',err.message)
    end
    %
    try
        frozenmargin = obj.getfrozenmargin;
    catch err
        error('error in getfrozenmargin:%s',err.message)
    end
    %
    if isempty(obj.preequity_)
        val = 0;
        fprintf('%s:getavailablefund:initial level of fund not set,pls call setavailablefund func\n',class(obj));
    else
        try
            [runningpnl,closedpnl] = obj.helper_.calcpnl('mdefut',obj.mde_fut_);
        catch err
            error('error in ops.calcpnl:%s',err.message)
        end
        totalpnl = sum(sum(runningpnl+closedpnl));
        obj.currentequity_ = obj.preequity_ + totalpnl;
        val = obj.currentequity_ - currentmargin - frozenmargin;
    end
end