function hassc13inrange = tdsq_hassc13inrange(bs,ss,bc,sc)
    variablenotused(bc);
    lastidxss = find(ss == 9,1,'last');
    hassc13inrange = ~isempty(find(sc(end-11:end) == 13,1,'last'));
    if hassc13inrange
        lastidxsc13 = find(sc == 13,1,'last');
        if lastidxsc13 < lastidxss, hassc13inrange = false;end
    end
    %when a ss that began before,on,or after
    %the developing sellcountdown, but prior to
    %a bearish price flip, extends to 18 bars,
    %the sellcountdown shall be recycled
    if hassc13inrange
        lastidxss18 = find(ss == 18,1,'last');
        if ~isempty(lastidxss18)
            if  lastidxsc13 <= lastidxss18
                hassc13inrange = false;
            elseif lastidxsc13 > lastidxss18
                %make sure there is no bearish price
                %between
                hassc13inrange = ~isempty(find(bs(lastidxss18+1:lastidxsc13)==1,1,'first'));
            end
        end
    end
end