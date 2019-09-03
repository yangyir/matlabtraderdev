function [signal] = gensignal_singlelvlup(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
%cStratFutMultiTDSQ
    variablenotused(bs);
    variablenotused(bc);
    variablenotused(tag);
    signal = {};
    if ~(isnan(lvldn(end)) && ~isnan(lvlup(end))), return;end
    
    if p(end,5) <= lvlup(end), return; end
    
    wasbelowlvlup = ~isempty(find(p(end-8:end-1,5) < lvlup(end),1,'first'));
    
    diffvec = macdvec - sigvec;
    
    wasmacdbearish = ~isempty(find(diffvec(end-8:end-1) < 0,1,'first'));
    
    if (wasbelowlvlup || wasmacdbearish) && diffvec(end) > 0 && ss(end) > 0 && sc(end) ~= 13
        samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
        signal = struct('name','tdsq',...
            'instrument',instrument,'frequency',samplefreqstr,...
            'scenarioname','',...
             'mode','trend','type','single-lvlup',...
             'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99,...
             'direction',1);
    end
    
end