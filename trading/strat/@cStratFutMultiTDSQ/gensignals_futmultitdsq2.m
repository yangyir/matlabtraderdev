function signals = gensignals_futmultitdsq2(strategy)
%cStratFutMultiTDSQ
    signals = cell(size(strategy.count,1),1);
    instruments = strategy.getinstruments;
    
    if strcmpi(strategy.mode_,'replay')
        runningt = strategy.replay_time1_;
    else
        runningt = now;
    end
    
    runningmm = hour(runningt)*60+minute(runningt);
    if (runningmm >= 539 && runningmm < 540) || ...
            (runningmm >= 779 && runningmm < 780) || ...
            (runningmm >= 1259 && runningmm < 1260)
            %one minute before market open in the morning, afternoon and
            %evening respectively
       for i = 1:strategy.count
           samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
           wrnperiod = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','wrnperiod');
           wrinfo = strategy.mde_fut_.calc_wr_(instruments{i},'NumOfPeriods',wrnperiod,'IncludeLastCandle',1,'RemoveLimitPrice',1);
           %
           macdlead = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlead');
           macdlag = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlag');
           macdnavg = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdnavg');
           [macdvec,sigvec] = strategy.mde_fut_.calc_macd_(instruments{i},'Lead',macdlead,'Lag',macdlag,'Average',macdnavg,'IncludeLastCandle',1,'RemoveLimitPrice',1);
           %
           tdsqlag = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqlag');
           tdsqconsecutive = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqconsecutive');
           [bs,ss,levelup,leveldn,bc,sc] = strategy.mde_fut_.calc_tdsq_(instruments{i},'Lag',tdsqlag,'Consecutive',tdsqconsecutive,'IncludeLastCandle',1,'RemoveLimitPrice',1);
           %
           strategy.tdbuysetup_{i} = bs;
           strategy.tdsellsetup_{i} = ss;
           strategy.tdbuycountdown_{i} = bc;
           strategy.tdsellcoundown_{i} = sc;
           strategy.tdstlevelup_{i} = levelup;
           strategy.tdstleveldn_{i} = leveldn;
           strategy.wr_{i} = wrinfo;
           strategy.macdvec_{i} = macdvec;
           strategy.nineperma_{i} = sigvec;
           
           candlesticks = strategy.mde_fut_.getallcandles(instruments{i});
           p = candlesticks{1};
           idxkeep = ~(p(:,2)==p(:,3)&p(:,2)==p(:,4)&p(:,2)==p(:,5));
           p = p(idxkeep,:);
           
           scenarioname = tdsq_getscenarioname(bs,ss,levelup,leveldn,bc,sc,p);
           fprintf('%s\n',scenarioname);
           tag = tdsq_snbd(scenarioname);
           
           if isempty(tag)
               signals{i,1} = {};
           else
               if strcmpi(tag,'perfectbs')
                   signals{i,1} = struct('name','tdsq',...
                       'instrument',instruments{i},...
                       'frequency',samplefreqstr,...
                       'scenarioname',scenarioname,...
                       'mode','reverse',...
                       'reversetype','perfectbs');
               else
                   %TODO
                   signals{i,1} = {};
               end
           end
    
       end
       
       return
    end
    
    for i = 1:strategy.count
        try
            calcsignalflag = strategy.getcalcsignalflag(instruments{i});
        catch e
            calcsignalflag = 0;
            msg = ['ERROR:%s:getcalcsignalflag:',class(strategy),e.message,'\n'];
            fprintf(msg);
            if strcmpi(strategy.onerror_,'stop'), strategy.stop; end
        end
        
        if ~calcsignalflag
            signals{i,1} = {};
        else
            if i == 1 && strategy.printflag_
                fprintf('%10s%11s%10s%10s%10s%8s%8s%10s%10s%10s%10s\n',...
                    'contract','time','wr','max','min','bs','ss','levelup','leveldn','macd','sig');
            end
            
            tick = strategy.mde_fut_.getlasttick(instruments{i});
            timet = datestr(tick(1),'HH:MM:SS');
            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
            wrnperiod = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','wrnperiod');
            macdlead = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlead');
            macdlag = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlag');
            macdnavg = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdnavg');
            tdsqlag = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqlag');
            tdsqconsecutive = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqconsecutive');
            includelastcandle = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','includelastcandle');
            
            wrinfo = strategy.mde_fut_.calc_wr_(instruments{i},'NumOfPeriods',wrnperiod,'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
            [macdvec,sigvec] = strategy.mde_fut_.calc_macd_(instruments{i},'Lead',macdlead,'Lag',macdlag,'Average',macdnavg,'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
            [bs,ss,levelup,leveldn,bc,sc] = strategy.mde_fut_.calc_tdsq_(instruments{i},'Lag',tdsqlag,'Consecutive',tdsqconsecutive,'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
            
            candlesticks = strategy.mde_fut_.getallcandles(instruments{i});
            p = candlesticks{1};
            if ~includelastcandle, p = p(1:end-1,:);end
            idxkeep = ~(p(:,2)==p(:,3)&p(:,2)==p(:,4)&p(:,2)==p(:,5));
            p = p(idxkeep,:);
            
            strategy.tdbuysetup_{i} = bs;
            strategy.tdsellsetup_{i} = ss;
            strategy.tdbuycountdown_{i} = bc;
            strategy.tdsellcoundown_{i} = sc;
            strategy.tdstlevelup_{i} = levelup;
            strategy.tdstleveldn_{i} = leveldn;
            strategy.wr_{i} = wrinfo;
            strategy.macdvec_{i} = macdvec;
            strategy.nineperma_{i} = sigvec;
            
            scenarioname = tdsq_getscenarioname(bs,ss,levelup,leveldn,bc,sc,p);
            fprintf('%s\n',scenarioname);
            tag = tdsq_snbd(scenarioname);
            
            %call a risk management before processing additional signal if
            %there is any
            
            
            if isempty(tag)
               signals{i,1} = {};
            else
               if strcmpi(tag,'perfectbs')
                   signals{i,1} = struct('name','tdsq',...
                       'instrument',instruments{i},...
                       'frequency',samplefreqstr,...
                       'scenarioname',scenarioname,...
                       'mode','reverse',...
                       'reversetype','perfectbs');
               else
                   %TODO
                   signals{i,1} = {};
               end
           end
            
            if strategy.printflag_
                dataformat = '%10s%11s%10.1f%10s%10s%8s%8s%10s%10s%10.1f%10.1f\n';
                fprintf(dataformat,instruments{i}.code_ctp,...
                    timet,...
                    wrinfo(1),num2str(wrinfo(2)),num2str(wrinfo(3)),...
                    num2str(bs(end)),num2str(ss(end)),num2str(levelup(end)),num2str(leveldn(end)),...
                    macdvec(end),sigvec(end));
            end
        end
    end
    
    
    

end