function [signal] = gensignal_doublerange(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag,macdbs,macdss)
    signal = {};
    if isnan(lvldn(end)) || isnan(lvlup(end)), return;end
    
    if lvlup(end) <= lvldn(end), return;end
    
    isperfectbs = strcmpi(tag,'perfectbs');
    isperfectss = strcmpi(tag,'perfectss');
    
    %IDENTIFY WHETHER PEFECT IS STILL VALID,I.E.STOPLOSS IS BREACHED OR
    if isperfectbs
        ibs = find(bs == 9,1,'last');
        truelow = min(p(ibs-8:ibs,4));
        idxtruelow = find(p(ibs-8:ibs,4) == truelow,1,'first');
        idxtruelow = idxtruelow + ibs - 9;
        truelowbarsize = p(idxtruelow,3) - truelow;
        stoploss = truelow - truelowbarsize;
        if ~isempty(find(p(ibs+1:end,5) < stoploss,1,'first'))
            isperfectbs = false;
        end
    end
    %
    if isperfectss
        iss = find(ss == 9,1,'last');
        truehigh = max(p(iss-8:iss,3));
        idxtruehigh = find(p(iss-8:iss,3) == truehigh,1,'first');
        idxtruehigh = idxtruehigh + iss - 9;
        truehighbarsize = truehigh - p(idxtruehigh,4);
        stoploss = truehigh + truehighbarsize;
        if ~isempty(find(p(iss+1:end,5) > stoploss,1,'first'))
            isperfectss = false;
        end
    end
    
    %we use the close price of the bar to determine the momentum
    isabove = p(end,5) > lvlup(end);
    isbelow = p(end,5) < lvldn(end);
    isbetween = p(end,5) <= lvlup(end) && p(end,5) >= lvldn(end);
    
    hassc13inrange = ~isempty(find(sc(end-11:end)==13, 1));
    hasbc13inrange = ~isempty(find(bc(end-11:end)==13, 1));
    
    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
    
    if isbetween
        %check whether it was above the lvlup
        %we use the high prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded above the lvlup
        idxlastabove = find(p(end-8:end,3)>lvlup(end),1,'last');
        wasabovelvlup = ~isempty(idxlastabove);
        
        %and check whether it was below the lvldn
        %we use the low prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded below the lvldn
        idxlastbelow = find(p(end-8:end,4)<lvldn(end),1,'last');
        wasbelowlvldn = ~isempty(idxlastbelow);
        if wasabovelvlup && wasbelowlvldn
            %interesting case
            if idxlastabove > idxlastbelow
                wasbelowlvldn = false;
            elseif idxlastabove < idxlastbelow
                wasabovelvlup = false;
            else
                %idxlastabove == idxlastbelow
                if p(idxlastabove,5) > lvlup(end)
                    wasbelowlvldn = false;
                end
                if p(idxlastabove,5) < lvldn(end)
                    wasabovelvlup = false;
                end
            end
        end
        %
        if wasabovelvlup && macdvec(end)<sigvec(end) && bs(end)>0 && ~isperfectbs && ~hasbc13inrange && macdbs(end)>0
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','isbetween',...
                'mode','trend','type','double-range',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',-1);
        elseif wasbelowlvldn && macdvec(end)>sigvec(end) && ss(end)>0 && ~isperfectss && ~hassc13inrange && macdss(end)>0
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','isbetween',...
                'mode','trend','type','double-range',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',1);
        end
        % end of isbetween
    elseif isabove
        %we use the low prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded below the lvlup
        idxlastbelow = find(p(end-8:end,4)<lvlup(end),1,'last');
        wasbelowlvlup = ~isempty(idxlastbelow);
        diffvec = macdvec - sigvec;
        idxlastmacdbearish = find(diffvec(end-8:end-1)<0,1,'last');
        wasmacdbearish = ~isempty(idxlastmacdbearish);
        if (wasbelowlvlup || wasmacdbearish ) && macdvec(end)>sigvec(end) && ss(end)>0 && ~isperfectss && ~hassc13inrange && macdss(end)>0
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','isabove',...
                'mode','trend','type','double-range',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',1);
        end
        % end of isabove
    elseif isbelow
        %we use the high prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded above the lvldn
        idxlastabove = find(p(end-8:end,3)>lvldn(end),1,'last');
        wasabovelvldn = ~isempty(idxlastabove);
        diffvec = macdvec - sigvec;
        idxlastmacdbullish = find(diffvec(end-8:end-1)>0,1,'last');
        wasmacdbullish = ~isempty(idxlastmacdbullish);
        hasbc13inrange = ~isempty(find(bc(end-11:end)==13, 1));
        if (wasabovelvldn || wasmacdbullish) && macdvec(end)<sigvec(end) && bs(end) > 0 && ~isperfectbs && ~hasbc13inrange && macdbs(end)>0
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','isbelow',...
                'mode','trend','type','double-range',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',-1);
        end
        % end of isbelow
    end
    
    
end