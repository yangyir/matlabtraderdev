function [signal] = gensignal_doublebullish(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
%cStratFutMultiTDSQ
    signal = {};
    if lvlup(end) >= lvldn(end), return;end
    idxbslatest = find(bs == 9,1,'last');
    idxsslatest = find(ss == 9,1,'last');
    if ~(idxbslatest < idxsslatest),return;end
    
    variablenotused(bc);
    variablenotused(tag);
    
    %bullish
    %LONG ONLY IN BULLISH MOMENTUM
    if p(end,5) > lvldn(end)
        sc13idx = -1;
        hassc13inrange = false;
        n = size(p,1);
        for j = max(1,n-11):n
            if sc(j) == 13
                hassc13inrange = true;
                sc13idx = j;
                break
            end
        end
        wasmacdbearish = false;
        if hassc13inrange
            for j = sc13idx:n-1
                if macdvec(j) < sigvec(j)
                    wasmacdbearish = true;break
                end
            end
        else
            for j = n-8:n-1
                if macdvec(j) < sigvec(j)
                    wasmacdbearish = true;break
                end
            end
        end
        if (wasmacdbearish || (hassc13inrange && ~wasmacdbearish )) && macdvec(end) > sigvec(end) && ss(end) > 0 && sc(end) ~=13
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','',...
                'mode','trend','type','double-bullish',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',1);
        end
    end
    
end