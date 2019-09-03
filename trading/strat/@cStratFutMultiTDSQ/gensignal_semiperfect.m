function [signal] = gensignal_semiperfect(strategy,instrument,p,bs,ss,lvlup,lvldn,macdvec,sigvec,bc,sc,tag)
%cStratFutMultiTDSQ
    signal = {};
    variablenotused(p);
    variablenotused(lvlup);
    variablenotused(lvldn);
    variablenotused(bc);
    variablenotused(sc);
    if strcmpi(tag,'semiperfectbs')
        if macdvec(end) > sigvec(end) || bs(end) >= 24
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname',tag,...
                'mode','reverse','type',tag,...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99);
        end
        return
    end
    %
    if strcmpi(tag,'semiperfectss')
        if macdvec(end) < sigvec(end) || ss(end) >= 24
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','samplefreq');
            signal = struct('name','tdsq',...
                'instrument',instrument,'frequency',samplefreqstr,...
                'scenarioname',tag,...
                'mode','reverse','type',tag,...
                'lvlup',lvlup(end),'lvldn',lvldn(end),'risklvl',-9.99);
        end
        return
    end
end