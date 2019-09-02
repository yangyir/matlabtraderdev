function [] = initdata_futmultitdsq(obj)
%cStratFutMultiTDSQ
    instruments = obj.getinstruments;
    for i = 1:obj.count
        try
            samplefreqstr = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','SampleFreq');
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
        elseif samplefreqnum == 15
            nbdays = 10;
        elseif samplefreqnum == 30
            nbdays = 20;
        else
            error('ERROR:%s:initdata_futmultitdsq:unsupported sample freq %s of %s',class(obj),samplefreqstr,instruments{i}.code_ctp)
        end
        
        fprintf('init historical data of %s...\n',instruments{i}.code_ctp);
        obj.mde_fut_.initcandles(instruments{i},'NumberofPeriods',nbdays);
        %
%         wrnperiod = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','wrnperiod');
%         wrinfo = obj.mde_fut_.calc_wr_(instruments{i},'NumOfPeriods',wrnperiod,'IncludeLastCandle',1);
        %
        macdlead = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlead');
        macdlag = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlag');
        macdnavg = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdnavg');
        [macdvec,sigvec,diffvec] = obj.mde_fut_.calc_macd_(instruments{i},'Lead',macdlead,'Lag',macdlag,'Average',macdnavg,'IncludeLastCandle',1);
        %
        tdsqlag = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqlag');
        tdsqconsecutive = obj.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqconsecutive');
        [bs,ss,levelup,leveldn,bc,sc] = obj.mde_fut_.calc_tdsq_(instruments{i},'Lag',tdsqlag,'Consecutive',tdsqconsecutive,'IncludeLastCandle',1);       
        
        obj.tdbuysetup_{i} = bs;
        obj.tdsellsetup_{i} = ss;
        obj.tdbuycountdown_{i} = bc;
        obj.tdsellcountdown_{i} = sc;
        obj.tdstlevelup_{i} = levelup;
        obj.tdstleveldn_{i} = leveldn;
%         obj.wr_{i} = wrinfo;
        obj.macdvec_{i} = macdvec;
        obj.nineperma_{i} = sigvec;
        
        if obj.usesimpletrend_(i)
            [macdbs,macdss] = tdsq_setup(diffvec);
            obj.macdbs_{i} = macdbs;
            obj.macdss_{i} = macdss;
        end
        
    end
    
    ntypes = cTDSQInfo.numoftype;
    obj.targetportfolio_ = zeros(obj.count,ntypes);
    
    
end