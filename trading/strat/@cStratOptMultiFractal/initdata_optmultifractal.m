function [] = initdata_optmultifractal(stratfractalopt)
%cStratOptMultiFractal function
    instruments = stratfractalopt.getinstruments;
    n = stratfractalopt.count;
    
    underlierstrlast = '';
    nufound = 0;
    
    for i = 1:n
        try
            samplefreqstr = stratfractalopt.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','SampleFreq');
        catch
            samplefreqstr = '30m';
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
            error('ERROR:%s:initdata_optmultifractal:unsupported sample freq %s of %s',class(stratfractalopt),samplefreqstr,instruments{i}.code_ctp)
        end
        
        [optflag,~,~,underlierstr,~] = isoptchar(instruments{i}.code_ctp);
        if ~optflag
            error('ERROR:%s:initdata_optmultifractal:option is required...',class(stratfractalopt))
        end
        
        if i == 1
            underlierstrlast = underlierstr;
            nufound = 1;
            %
            u = code2instrument(underlierstrlast);
            fprintf('init historical data of %s...\n',underlierstr);
            stratfractalopt.mde_fut_.initcandles(u,'NumberofPeriods',nbdays);
            tdsqlag = stratfractalopt.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqlag');
            tdsqconsecutive = stratfractalopt.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqconsecutive');
            [bs,ss,lvlup,lvldn,bc,sc] = stratfractalopt.mde_fut_.calc_tdsq_(u,'Lag',tdsqlag,'Consecutive',tdsqconsecutive,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            nfractals = stratfractalopt.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','nfractals');
            [~,hh,ll] = stratfractalopt.mde_fut_.calc_fractal_(u,'nperiod',nfractals,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            [jaw,teeth,lips] = stratfractalopt.mde_fut_.calc_alligator_(u,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            wad = stratfractalopt.mde_fut_.calc_wad_(u,'IncludeLastCandle',1,'RemoveLimitPrice',1);
            stratfractalopt.hh_{nufound} = hh;
            stratfractalopt.ll_{nufound} = ll;
            stratfractalopt.jaw_{nufound} = jaw;
            stratfractalopt.teeth_{nufound} = teeth;
            stratfractalopt.lips_{nufound} = lips;
            stratfractalopt.bs_{nufound} = bs;
            stratfractalopt.ss_{nufound} = ss;
            stratfractalopt.bc_{nufound} = bc;
            stratfractalopt.sc_{nufound} = sc;
            stratfractalopt.lvlup_{nufound} = lvlup;
            stratfractalopt.lvldn_{nufound} = lvldn;
            stratfractalopt.wad_{nufound} = wad;
            %
        else
            if ~strcmpi(underlierstr,underlierstrlast)
                underlierstrlast = underlierstr;
                nufound = nufound + 1;
                %
                u = code2instrument(underlierstrlast);
                fprintf('init historical data of %s...\n',underlierstr);
                stratfractalopt.mde_fut_.initcandles(u,'NumberofPeriods',nbdays);
                tdsqlag = stratfractalopt.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqlag');
                tdsqconsecutive = stratfractalopt.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqconsecutive');
                [bs,ss,lvlup,lvldn,bc,sc] = stratfractalopt.mde_fut_.calc_tdsq_(u,'Lag',tdsqlag,'Consecutive',tdsqconsecutive,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                nfractals = stratfractalopt.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','nfractals');
                [~,hh,ll] = stratfractalopt.mde_fut_.calc_fractal_(u,'nperiod',nfractals,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                [jaw,teeth,lips] = stratfractalopt.mde_fut_.calc_alligator_(u,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                wad = stratfractalopt.mde_fut_.calc_wad_(u,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                stratfractalopt.hh_{nufound} = hh;
                stratfractalopt.ll_{nufound} = ll;
                stratfractalopt.jaw_{nufound} = jaw;
                stratfractalopt.teeth_{nufound} = teeth;
                stratfractalopt.lips_{nufound} = lips;
                stratfractalopt.bs_{nufound} = bs;
                stratfractalopt.ss_{nufound} = ss;
                stratfractalopt.bc_{nufound} = bc;
                stratfractalopt.sc_{nufound} = sc;
                stratfractalopt.lvlup_{nufound} = lvlup;
                stratfractalopt.lvldn_{nufound} = lvldn;
                stratfractalopt.wad_{nufound} = wad;
                %
            end
        end
        
        
        
    end

end