function val = getavailablefund(obj)
    currentmargin = obj.getcurrentmargin;
    frozenmargin = obj.getfrozenmargin;
    if isempty(obj.totalequity_)
        val = 0;
        fprintf('cStrat:getavailablefund:initial level of fund not set,pls call setavailablefund func\n');
    else
        val = obj.totalequity_ - currentmargin - frozenmargin;  
    end
end