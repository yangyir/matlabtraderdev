function hasbc13inrange = tdsq_hasbc13inrange(bs,ss,bc,sc)
    variablenotused(sc);
    lastidxbs = find(bs == 9,1,'last');
    
    hasbc13inrange = ~isempty(find(bc(end-11:end) == 13,1,'last'));
    if hasbc13inrange
        lastidxbc13 = find(bc == 13,1,'last');
        if lastidxbc13 < lastidxbs, hasbc13inrange = false;end
    end
    %when a bs that began before,on,or after
    %the developing buycountdown, but prior to
    %a bullish price flip, extends to 18 bars,
    %the buycountdown shall be recycled
    if hasbc13inrange
        lastidxbs18 = find(bs == 18,1,'last');
        if ~isempty(lastidxbs18)
            if  lastidxbc13 <= lastidxbs18
                hasbc13inrange = false;
            elseif lastidxbc13 > lastidxbs18
                %make sure there is no bullish price
                %between
                hasbc13inrange = ~isempty(find(ss(lastidxbs18+1:lastidxbc13)==1,1,'first'));
            end
        end
    end
end