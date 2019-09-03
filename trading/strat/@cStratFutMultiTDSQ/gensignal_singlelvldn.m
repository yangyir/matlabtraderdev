function [signal] = gensignal_singlelvldn(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
%cStratFutMultiTDSQ
    variablenotused(ss);
    variablenotused(sc);
    variablenotused(tag);
    signal = {};
    if ~(~isnan(lvldn(end)) && isnan(lvlup(end))), return;end
    
    if p(end,5) >= lvldn(end), return; end
    
    wasabovelvldn = ~isempty(find(p(end-8:end-1,5) > lvldn(end),1,'first'));
    
    diffvec = macdvec - sigvec;
    
    wasmacdbullish = ~isempty(find(diffvec(end-8:end-1) > 0,1,'first'));
    
    if (wasabovelvldn || wasmacdbullish) && diffvec(end) < 0 && bs(end) > 0 && bc(end) ~= 13
        samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
        signal = struct('name','tdsq',...
            'instrument',instrument,'frequency',samplefreqstr,...
            'scenarioname','',...
             'mode','trend','type','single-lvldn',...
             'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
             'direction',-1);
    end
    
end