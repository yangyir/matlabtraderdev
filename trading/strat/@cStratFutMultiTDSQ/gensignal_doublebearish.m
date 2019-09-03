function [signal] = gensignal_doublebearish(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
%cStratFutMultiTDSQ
    signal = {};
    if lvlup(end) >= lvldn(end), return;end
    idxbslatest = find(bs == 9,1,'last');
    idxsslatest = find(ss == 9,1,'last');
    if ~(idxbslatest > idxsslatest),return;end
    
    variablenotused(sc);
    variablenotused(tag);
    
    %bearish
    %SHORT ONLY IN BEARISH MOMENTUM
    if p(end,5) < lvlup(end)
        bc13idx = -1;
        hasbc13inrange = false;
        n = size(p,1);
        for j = max(1,n-11):n
            if bc(j) == 13
                hasbc13inrange = true;
                bc13idx = j;
                break
            end
        end
        wasmacdbullish = false;
        if hasbc13inrange
            for j = bc13idx:n-1
                if macdvec(j) > sigvec(j)
                    wasmacdbullish = true;break
                end
            end
        else
            for j = max(1,n-8):n-1
                if macdvec(j) > sigvec(j)
                    wasmacdbullish = true;break
                end
            end
        end
        if (wasmacdbullish || (hasbc13inrange && ~wasmacdbullish)) && macdvec(end) < sigvec(end) && bs(end) > 0 && bc(end) ~= 13
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname','',...
                'mode','trend','type','double-bearish',...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
                'direction',-1);
        end
    end
end
    
end