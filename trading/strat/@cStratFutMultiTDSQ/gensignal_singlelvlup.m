function [signal] = gensignal_singlelvlup(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag,macdbs,macdss)
%cStratFutMultiTDSQ
    variablenotused(bs);
    variablenotused(bc);
    variablenotused(tag);
    signal = {};
    if ~(isnan(lvldn(end)) && ~isnan(lvlup(end))), return;end
    
    diffvec = macdvec - sigvec;
    
    if p(end,5) < lvlup(end)
        %bearish momentum
        %we use the high prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded above the lvlup
        wasabovelvlup = ~isempty(find(p(end-8:end,3) > lvlup(end),1,'first'));
        wasmacdbullish = ~isempty(find(diffvec(end-8:end-1) > 0,1,'first'));
        if (wasabovelvlup||wasmacdbullish ) && diffvec(end)<0 && bs(end)>0 && bc(end) ~= 13 && macdbs(end)>0
            %special treatement if bs(end) is greater than or equal to 9
            f1 = false;
            if bs(end) >= 9
                lastbsidx = find(bs == 9,1,'last');
                low6 = p(lastbsidx-3,4);
                low7 = p(lastbsidx-2,4);
                low8 = p(lastbsidx-1,4);
                low9 = p(lastbsidx,4);
                close8 = p(lastbsidx-1,5);
                close9 = p(lastbsidx,5);
                %check whether buy sequential itself is perfect???
                %if it is perfect, we'd better not open up a trade
                %with short position
                f1 = (low8 < min(low6,low7) || low9 < min(low6,low7)) && close9 < close8;
            end
            
            if ~f1
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname','',...
                    'mode','trend','type','double-bearish',...
                    'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                    'direction',-1);
            end
        end
        %
    elseif p(end,5) > lvlup(end)
        %bullish momentum
        %we use the low prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded below the lvlup
        wasbelowlvlup = ~isempty(find(p(end-8:end,4) < lvlup(end),1,'first'));
        wasmacdbearish = ~isempty(find(diffvec(end-8:end-1) < 0,1,'first'));
        if  (wasbelowlvlup || wasmacdbearish) && diffvec(end)>0 && ss(end)>0 && sc(end) ~= 13 && macdss(end)>0
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','',...
                'mode','trend','type','single-lvlup',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',1);
        end
    end
        
end