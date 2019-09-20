function [signal] = gensignal_doublebullish(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag,macdbs,macdss)
%cStratFutMultiTDSQ
    signal = {};
    if lvlup(end) >= lvldn(end), return;end
    idxbslatest = find(bs == 9,1,'last');
    idxsslatest = find(ss == 9,1,'last');
    if ~(idxbslatest < idxsslatest),return;end
    
    variablenotused(bc);
    variablenotused(tag);
    
    diffvec = macdvec - sigvec;
    buffer = 2*instrument.tick_size;
    
    %bullish
    if p(end,5) > lvldn(end) + buffer
        %we use the low prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded below the lvldn
        wasbelowlvldn = ~isempty(find(p(end-8:end,4) < lvldn(end),1,'first'));
        wasmacdbearish = ~isempty(find(diffvec(end-8:end-1) < 0,1,'first'));
        
        if (wasbelowlvldn||wasmacdbearish ) && diffvec(end)>0 && ss(end)>0 && sc(end) ~= 13 && macdss(end)>0
            high6 = p(idxsslatest-3,3);
            high7 = p(idxsslatest-2,3);
            high8 = p(idxsslatest-1,3);
            high9 = p(idxsslatest,3);
            close8 = p(idxsslatest-1,5);
            close9 = p(idxsslatest,5);
            %check whether sell sequential itself is perfect???
            %if it is perfect, we'd better not open up a trade
            %with long position
            f1 = (high8 > max(high6,high7) || high9 > max(high6,high7)) && (close9>close8);
            
            np = size(p,1);
            if ~f1 || (f1 && np-idxsslatest>24)
                lastidxsc13 = find(sc == 13,1,'last');
                if isempty(lastidxsc13)
                    openflag = true;
                else
                    if np - lastidxsc13 > 11
                        openflag = true;
                    else
                        %has macd been negative
                        openflag = ~isempty(find(diffvec(lastidxsc13:end) < 0,1,'last'));
                    end
                end
            else
                openflag = false;
            end
            
            if openflag
                samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
                signal = struct('name','tdsq',...
                    'instrument',instrument,'frequency',samplefreqstr,...
                    'scenarioname','',...
                    'mode','trend','type','double-bullish',...
                    'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                    'direction',1);
            end
        end
        %
    elseif p(end,5) < lvldn(end) - buffer
        %we use the high prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded above the lvldn
        wasabovelvldn = ~isempty(find(p(end-8:end,3) > lvldn(end),1,'first'));
        if wasabovelvldn && diffvec(end)<0 && bs(end)>0 && bc(end) ~= 13 && macdbs(end)>0
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
        else
            openflag = false;
        end
        
        if openflag
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','',...
                'mode','trend','type','double-bullish',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',-1);
        end
    end
    
end