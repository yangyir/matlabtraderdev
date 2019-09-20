function [signal] = gensignal_doublebearish(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag,macdbs,macdss)
%cStratFutMultiTDSQ
    signal = {};
    if lvlup(end) >= lvldn(end), return;end
    idxbslatest = find(bs == 9,1,'last');
    idxsslatest = find(ss == 9,1,'last');
    if ~(idxbslatest > idxsslatest),return;end
    
    variablenotused(sc);
    variablenotused(tag);
    
    diffvec = macdvec - sigvec;
    buffer = 2*instrument.tick_size;
    %bearish momentum
    if p(end,5) < lvlup(end) - buffer
        %we use the high prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded above the lvlup
        wasbelowlvlup = ~isempty(find(p(end-8:end,3) > lvlup(end),1,'first'));
        wasmacdbullish = ~isempty(find(diffvec(end-8:end-1) > 0,1,'first'));
        
        if (wasbelowlvlup||wasmacdbullish ) && diffvec(end)<0 && bs(end)>0 && bc(end) ~= 13 && macdbs(end)>0
            %special treatement if bs(end) is greater than or equal to 9
            low6 = p(idxbslatest-3,4);
            low7 = p(idxbslatest-2,4);
            low8 = p(idxbslatest-1,4);
            low9 = p(idxbslatest,4);
            close8 = p(idxbslatest-1,5);
            close9 = p(idxbslatest,5);
            %check whether buy sequential itself is perfect???
            %if it is perfect, we'd better not open up a trade
            %with short position
            f1 = (low8 < min(low6,low7) || low9 < min(low6,low7)) && close9 < close8;
            
            np = size(p,1);
            if ~f1 && (np-idxbslatest>24)
                lastidxbc13 = find(bc == 13,1,'last');
                if isempty(lastidxbc13)
                    openflag = true;
                else
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
                    'mode','trend','type','double-bearish',...
                    'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                    'direction',-1);
            end
        end
    elseif p(end,5) > lvlup(end) + buffer
        %we use the low prices of the previous 9 bars including
        %the most recent bar to determine whether the market
        %was traded below the lvlup
        wasbelowlvlup = ~isempty(find(p(end-8:end,4) < lvlup(end),1,'first'));
        if wasbelowlvlup && diffvec(end)>0 && ss(end)>0 && sc(end) ~= 13 && macdss(end)>0
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
        else
            openflag = false;
        end
        
        if openflag
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','',...
                'mode','trend','type','double-bearish',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',1);
        end
    end
end