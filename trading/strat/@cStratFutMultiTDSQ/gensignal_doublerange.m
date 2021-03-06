function [signal] = gensignal_doublerange(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag,macdbs,macdss)
    signal = {};
    if isnan(lvldn(end)) || isnan(lvlup(end)), return;end
    
    if lvlup(end) <= lvldn(end), return;end
    
    isperfectbs = strcmpi(tag,'perfectbs');
    isperfectss = strcmpi(tag,'perfectss');
    buffer = 2*instrument.tick_size;
    diffvec = macdvec - sigvec;
    
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
    isabove = p(end,5) > lvlup(end)+buffer;
    isbelow = p(end,5) < lvldn(end)-buffer;
    isbetween = p(end,5) <= lvlup(end) && p(end,5) >= lvldn(end);
       
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
        if wasabovelvlup && diffvec(end)<0 && bs(end)>0 && ~isperfectbs && bc(end) ~= 13 && macdbs(end)>0
            lastidxbc13 = find(bc == 13,1,'last');
            if isempty(lastidxbc13)
                openflag = true;
            else
                np = size(p,1);
                if np - lastidxbc13 > 11
                    openflag = true;
                else
                    %has macd been positive
                    openflag = ~isempty(find(diffvec(lastidxbc13:end) > 0,1,'last'));
                end
            end
            
            if openflag
                openflag = tdsq_validsell1(p,bs,ss,lvlup,lvldn,macdvec,sigvec);
            end
            
            if openflag
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname','isbetween',...
                    'mode','trend','type','double-range',...
                    'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                    'direction',-1);
            end
        elseif wasbelowlvldn && diffvec(end)>0 && ss(end)>0 && ~isperfectss && sc(end) ~= 13 && macdss(end)>0
            lastidxsc13 = find(sc == 13,1,'last');
            if isempty(lastidxsc13)
                openflag = true;
            else
                np = size(p,1);
                if np - lastidxsc13 > 11
                    openflag = true;
                else
                    %has macd been negative
                    openflag = ~isempty(find(diffvec(lastidxsc13:end) < 0,1,'last'));
                end
            end
            
            if openflag
                openflag = tdsq_validbuy1(p,bs,ss,lvlup,lvldn,macdvec,sigvec);
            end
            
            if openflag
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname','isbetween',...
                    'mode','trend','type','double-range',...
                    'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                    'direction',1);
            end
        end
        % end of isbetween
    elseif isabove
        %we use the low prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded below the lvlup
        wasbelowlvlup = ~isempty(find(p(end-8:end,4)<lvlup(end),1,'first'));
        if wasbelowlvlup && diffvec(end)>0 && ss(end)>0 && ~isperfectss && sc(end) ~= 13 && macdss(end)>0
            lastidxsc13 = find(sc == 13,1,'last');
            if isempty(lastidxsc13)
                openflag = true;
            else
                np = size(p,1);
                if np - lastidxsc13 > 11
                    openflag = true;
                else
                    %has macd been negative
                    openflag = ~isempty(find(diffvec(lastidxsc13:end) < 0,1,'last'));
                end
            end
            
            if openflag
                openflag = tdsq_validbuy1(p,bs,ss,lvlup,lvldn,macdvec,sigvec);
            end
            
            if openflag
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname','isabove',...
                    'mode','trend','type','double-range',...
                    'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                    'direction',1);
            end
        end
        % end of isabove
    elseif isbelow
        %we use the high prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded above the lvldn
        wasabovelvldn = ~isempty(find(p(end-8:end,3)>lvldn(end),1,'first'));
%         wasmacdbullish = ~isempty(find(diffvec(end-8:end-1)>0,1,'first'));
        if wasabovelvldn && diffvec(end)<0 && bs(end) > 0 && ~isperfectbs && bc(end) ~= 13 && macdbs(end)>0
            lastidxbc13 = find(bc == 13,1,'last');
            if isempty(lastidxbc13)
                openflag = true;
            else
                np = size(p,1);
                if np - lastidxbc13 > 11
                    openflag = true;
                else
                    %has macd been positive
                    openflag = ~isempty(find(diffvec(lastidxbc13:end) > 0,1,'last'));
                end
            end
            
            if openflag
                openflag = tdsq_validsell1(p,bs,ss,lvlup,lvldn,macdvec,sigvec);
            end
            
            if openflag
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname','isbelow',...
                    'mode','trend','type','double-range',...
                    'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                    'direction',-1);
            end
        end
        % end of isbelow
    end
    
    
end