function [signal] = gensignal_doublerange(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
    signal = {};
    if isnan(lvldn(end)) || isnan(lvlup(end)), return;end
    
    if lvlup(end) <= lvldn(end), return;end
    
    isperfectbs = strcmpi(tag,'perfectbs');
    isperfectss = strcmpi(tag,'perfectss');
    
    isabove = p(end,5) > lvlup(end);
    isbelow = p(end,5) < lvldn(end);
    isbetween = p(end,5) <= lvlup(end) && p(end,5) >= lvldn(end);
    
    samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
    
    if isbetween
        %check whether it was above the lvlup
        idxlastabove = find(p(end-8:end-1,5)>lvlup(end),1,'last');
        wasabovelvlup = ~isempty(idxlastabove);
        %and check whether it was below the lvldn
        idxlastbelow = find(p(end-8:end-1,5)<lvldn(end),1,'last');
        wasbelowlvldn = ~isempty(idxlastbelow);
        if wasabovelvlup && wasbelowlvldn
            %interesting case
            if idxlastabove > idxlastbelow
                wasbelowlvldn = false;
            else
                wasabovelvlup = false;
            end
        end
        hassc13inrange = ~isempty(find(sc(end-11:end)==13, 1));
        hasbc13inrange = ~isempty(find(bc(end-11:end)==13, 1));
        %
        if wasabovelvlup && macdvec(end)<sigvec(end) && bs(end)>0 && ~isperfectbs && ~hasbc13inrange
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','',...
                'mode','trend','type','double-range',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',-1);
        elseif wasbelowlvldn && macdvec(end)>sigvec(end) && ss(end)>0 && ~isperfectss && ~hassc13inrange
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','',...
                'mode','trend','type','double-range',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',1);
        end
        % end of isbetween
    elseif isabove
        idxlastbelow = find(p(end-8:end-1,5)<lvlup(end),1,'last');
        wasbelowlvlup = ~isempty(idxlastbelow);
        diffvec = macdvec - sigvec;
        idxlastmacdbearish = find(diffvec(end-8:end-1)<0,1,'last');
        wasmacdbearish = ~isempty(idxlastmacdbearish);
        hassc13inrange = ~isempty(find(sc(end-11:end)==13, 1));
        if (wasbelowlvlup || wasmacdbearish ) && macdvec(end)>sigvec(end) && ss(end)>0 && ~isperfectss && ~hassc13inrange
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','',...
                'mode','trend','type','double-range',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',1);
        end
        % end of isabove
    elseif isbelow
        idxlastabove = find(p(end-8:end-1,5)>lvldn(end),1,'last');
        wasabovelvldn = ~isempty(idxlastabove);
        diffvec = macdvec - sigvec;
        idxlastmacdbullish = find(diffvec(end-8:end-1)>0,1,'last');
        wasmacdbullish = ~isempty(idxlastmacdbullish);
        hasbc13inrange = ~isempty(find(bc(end-11:end)==13, 1));
        if (wasabovelvldn || wasmacdbullish) && macdvec(end)<sigvec(end) && bs(end) > 0 && ~isperfectbs && ~hasbc13inrange
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','',...
                'mode','trend','type','double-range',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',-1);
        end
        % end of isbelow
    end
    
    
end