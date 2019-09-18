function [signal] = gensignal_perfect(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
%cStratFutMultiTDSQ
    variablenotused(bc);
    variablenotused(sc);
    signal = {};
    riskmode = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','riskmode');
    usesetups = strcmpi(riskmode,'macd-setup');
    
    if strcmpi(tag,'perfectbs')
        ibs = find(bs == 9,1,'last');
        %note:the stoploss shall be calculated using the perfect 9 bars
        truelow = min(p(ibs-8:ibs,4));
        idxtruelow = find(p(ibs-8:ibs,4) == truelow,1,'first');
        idxtruelow = idxtruelow + ibs - 9;
        truelowbarsize = p(idxtruelow,3) - truelow;
        stoploss = truelow - truelowbarsize;
        
        np = size(p,1);
        if np > ibs
            stillvalid = isempty(find(p(ibs:end,5)<stoploss,1,'first'));
            %
            if stillvalid
                if p(end,5) < lvldn(ibs), stillvalid = false;end
            end
            %
            if stillvalid
                if p(end,5) < truelow, stillvalid = false;end
            end
            %
            if stillvalid && usesetups
                if bs(end) >= 4 && bs(end) < 9, stillvalid = false;end
            end
        else
            stillvalid = true;
        end

        haslvlupbreachedwithmacdbearishafterwards = false;
        if stillvalid
            ibreach = find(p(ibs:end,5) > lvlup(ibs),1,'first');
            if ~isempty(ibreach)
                %lvlup has been breached
                ibreach = ibreach + ibs-1;
                diffvec = macdvec(ibreach:end)-sigvec(ibreach:end);
                haslvlupbreachedwithmacdbearishafterwards = ~isempty(find(diffvec<0,1,'first'));
            end
        end

        if ~stillvalid
            signal = {};
        else
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            if haslvlupbreachedwithmacdbearishafterwards
                risklvl = p(end,5) - (p(ibs,5) - stoploss);
            else
                risklvl = stoploss;
            end
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname',tag,...
                'mode','reverse','type','perfectbs',...
                'lvlup',lvlup(ibs),'lvldn',lvldn(ibs),'risklvl',risklvl);
        end
        return
    end
    %
    if strcmpi(tag,'perfectss')
        iss = find(ss == 9,1,'last');
        %note:the stoploss shall be calculated using the perfect 9 bars
        truehigh = max(p(iss-8:iss,3));
        idxtruehigh = find(p(iss-8:iss,3) == truehigh,1,'first');
        idxtruehigh = idxtruehigh + iss - 9;
        truehighbarsize = truehigh - p(idxtruehigh,4);
        stoploss = truehigh + truehighbarsize;
        
        np = size(p,1);
        if np > iss
            stillvalid = isempty(find(p(iss:end,5)>stoploss,1,'first'));
            if stillvalid
                if p(end,5) > lvlup(iss), stillvalid = false;end
            end
            %
            if stillvalid
                if p(end,5) > truehigh, stillvalid = false;end
            end
            %
            if stillvalid && usesetups
                if ss(end) >= 4 && ss(end) < 9, stillvalid = false;end
            end
            %
        else
            stillvalid = true;
        end
        
        haslvldnbreachedwithmacdbullishafterwards = false;
        if stillvalid
            ibreach = find(p(iss:end,5) < lvldn(iss),1,'first');
            if ~isempty(ibreach)
                %lvldn has been breached
                ibreach = ibreach + iss-1;
                diffvec = macdvec(ibreach:end)-sigvec(ibreach:end);
                haslvldnbreachedwithmacdbullishafterwards = ~isempty(find(diffvec>0,1,'first'));
            end
        end
        
        if ~stillvalid
            signal = {};
        else
            if haslvldnbreachedwithmacdbullishafterwards
                risklvl = p(end,5) + (stoploss-p(iss,5));
            else
                risklvl = stoploss;
            end
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname',tag,...
                'mode','reverse','type','perfectss',...
                'lvlup',lvlup(iss),'lvldn',lvldn(iss),'risklvl',risklvl);
        end
        return
    end
    

end