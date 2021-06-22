function [] = initdata_futmultifractal(stratfractal)
%cStratFutMultiFractal
    instruments = stratfractal.getinstruments;
    n = stratfractal.count;
    for i = 1:n
        try
            samplefreqstr = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','SampleFreq');
        catch
            samplefreqstr = '15m';
        end

        samplefreqnum = str2double(samplefreqstr(1:end-1));

        if samplefreqnum == 1
            nbdays = 1;
        elseif samplefreqnum == 3
            nbdays = 3;
        elseif samplefreqnum == 5
            nbdays = 5;
        elseif samplefreqnum == 10 || samplefreqnum == 15
            nbdays = 10;
        elseif samplefreqnum == 30
            nbdays = 20;
        elseif samplefreqnum == 1440
            nbdays = 252;
        else
            error('ERROR:%s:initdata_futmultifractal:unsupported sample freq %s of %s',class(stratfractal),samplefreqstr,instruments{i}.code_ctp)
        end
        
        fprintf('init historical data of %s...\n',instruments{i}.code_ctp);
        stratfractal.mde_fut_.initcandles(instruments{i},'NumberofPeriods',nbdays);
 
        tdsqlag = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqlag');
        tdsqconsecutive = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqconsecutive');
        [bs,ss,lvlup,lvldn,bc,sc] = stratfractal.mde_fut_.calc_tdsq_(instruments{i},'Lag',tdsqlag,'Consecutive',tdsqconsecutive,'IncludeLastCandle',1,'RemoveLimitPrice',1);       
        %
        nfractals = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','nfractals');
        [~,hh,ll] = stratfractal.mde_fut_.calc_fractal_(instruments{i},'nperiod',nfractals,'IncludeLastCandle',1,'RemoveLimitPrice',1);
        [jaw,teeth,lips] = stratfractal.mde_fut_.calc_alligator_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
        
        stratfractal.hh_{i} = hh;
        stratfractal.ll_{i} = ll;
        stratfractal.jaw_{i} = jaw;
        stratfractal.teeth_{i} = teeth;
        stratfractal.lips_{i} = lips;
        stratfractal.bs_{i} = bs;
        stratfractal.ss_{i} = ss;
        stratfractal.bc_{i} = bc;
        stratfractal.sc_{i} = sc;
        stratfractal.lvlup_{i} = lvlup;
        stratfractal.lvldn_{i} = lvldn;
    end

end