function val = getavailablefund(obj)
%cStrat
    currentmargin = obj.getcurrentmargin;
    frozenmargin = obj.getfrozenmargin;
    if isempty(obj.preequity_)
        val = 0;
        fprintf('cStrat:getavailablefund:initial level of fund not set,pls call setavailablefund func\n');
    else
        [runningpnl,closedpnl] = obj.helper_.calcpnl('mdefut',obj.mde_fut_);
        totalpnl = sum(sum(runningpnl+closedpnl));
        obj.currentequity_ = obj.preequity_ + totalpnl;
        val = obj.currentequity_ - currentmargin - frozenmargin;
    end
end