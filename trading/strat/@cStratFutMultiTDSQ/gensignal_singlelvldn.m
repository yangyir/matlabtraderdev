function [signal] = gensignal_singlelvldn(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag,macdbs,macdss)
%cStratFutMultiTDSQ
    variablenotused(ss);
    variablenotused(sc);
    variablenotused(tag);
    signal = {};
    if ~(~isnan(lvldn(end)) && isnan(lvlup(end))), return;end
    
    diffvec = macdvec - sigvec;
    
    if p(end,5) > lvldn(end)
        %bullish
        %we use the low prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded below the lvldn
        wasbelowlvldn = ~isempty(find(p(end-8:end,4) < lvldn(end),1,'first'));
        wasmacdbearish = ~isempty(find(diffvec(end-8:end-1) < 0,1,'first'));
        
        if (wasbelowlvldn||wasmacdbearish ) && diffvec(end)>0 && ss(end)>0 && sc(end) ~= 13 && macdss(end)>0
            %special treatment if ss(i) is greater or equal to 9
            f1 = false;
            if ss(end) >= 9
                lastssidx = find(ss == 9,1,'last');
                high6 = p(lastssidx-3,3);
                high7 = p(lastssidx-2,3);
                high8 = p(lastssidx-1,3);
                high9 = p(lastssidx,3);
                close8 = p(lastssidx-1,5);
                close9 = p(lastssidx,5);
                %check whether sell sequential itself is perfect???
                %if it is perfect, we'd better not open up a trade
                %with long position
                f1 = (high8 > max(high6,high7) || high9 > max(high6,high7)) && (close9>close8);
            end
            
            if ~f1
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname','',...
                    'mode','trend','type','single-lvldn',...
                    'lvlup',-9.99,'lvldn',lvldn(end),'risklvl',-9.99,...
                    'direction',1);
            end
        end
        %
    elseif p(end,5) < lvldn(end)
        %bearish
        %we use the high prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded above the lvldn
        wasabovelvldn = ~isempty(find(p(end-8:end,3) > lvldn(end),1,'first'));
%         wasmacdbullish = ~isempty(find(diffvec(end-8:end-1) > 0,1,'first'));
        if wasabovelvldn && diffvec(end)<0 && bs(end)>0 && bc(end) ~= 13 && macdbs(end)>0
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
            'instrument',instrument,'frequency',samplefreqstr,...
            'scenarioname','',...
             'mode','trend','type','single-lvldn',...
             'lvlup',-9.99,'lvldn',lvldn(end),'risklvl',-9.99,...
             'direction',-1);
        end
    end    
end