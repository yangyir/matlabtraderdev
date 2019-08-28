function signals = gensignals_futmultitdsq2(strategy)
%cStratFutMultiTDSQ
    %note:column 1 is for reverse-type signal
    %column 2 is for trend-type signal
    signals = cell(size(strategy.count,1),2);
    
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
%            samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
%            wrnperiod = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','wrnperiod');
%            wrinfo = strategy.mde_fut_.calc_wr_(instruments{i},'NumOfPeriods',wrnperiod,'IncludeLastCandle',1,'RemoveLimitPrice',1);
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
           strategy.tdsellcountdown_{i} = sc;
           strategy.tdstlevelup_{i} = levelup;
           strategy.tdstleveldn_{i} = leveldn;
%            strategy.wr_{i} = wrinfo;
           strategy.macdvec_{i} = macdvec;
           strategy.nineperma_{i} = sigvec;    
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
            signals{i,2} = {};
            continue;
        end
        
        samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
%         wrnperiod = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','wrnperiod');
%         macdlead = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlead');
%         macdlag = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdlag');
%         macdnavg = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','macdnavg');
%         tdsqlag = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqlag');
%         tdsqconsecutive = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','tdsqconsecutive');
        includelastcandle = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','includelastcandle');
            
%         wrinfo = strategy.mde_fut_.calc_wr_(instruments{i},'NumOfPeriods',wrnperiod,'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
%         [macdvec,sigvec] = strategy.mde_fut_.calc_macd_(instruments{i},'Lead',macdlead,'Lag',macdlag,'Average',macdnavg,'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
%         [bs,ss,levelup,leveldn,bc,sc] = strategy.mde_fut_.calc_tdsq_(instruments{i},'Lag',tdsqlag,'Consecutive',tdsqconsecutive,'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
        [macdvec,sigvec] = strategy.mde_fut_.calc_macd_(instruments{i},'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
%         [bs,ss,levelup,leveldn,bc,sc] = strategy.mde_fut_.calc_tdsq_(instruments{i},'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
            
        candlesticks = strategy.mde_fut_.getallcandles(instruments{i});
        p = candlesticks{1};
        if ~includelastcandle, p = p(1:end-1,:);end
        %remove intraday 
        idxkeep = ~(p(:,2)==p(:,3)&p(:,2)==p(:,4)&p(:,2)==p(:,5));
        p = p(idxkeep,:);
        
        bs = strategy.tdbuysetup_{i};
        ss = strategy.tdsellsetup_{i};
        bc = strategy.tdbuycountdown_{i};
        sc = strategy.tdsellcountdown_{i};
        levelup = strategy.tdstlevelup_{i};
        leveldn = strategy.tdstleveldn_{i};
        
        if size(p,1) - size(bs,1) == 1
            fprintf('%s:update tdsq variables of %s...\n',strategy.name_,instruments{i}.code_ctp);
            [bs,ss,levelup,leveldn,bc,sc] = tdsq_piecewise(p,bs,ss,levelup,leveldn,bc,sc);
            %update strategy-related variables
            strategy.tdbuysetup_{i} = bs;
            strategy.tdsellsetup_{i} = ss;
            strategy.tdbuycountdown_{i} = bc;
            strategy.tdsellcountdown_{i} = sc;
            strategy.tdstlevelup_{i} = levelup;
            strategy.tdstleveldn_{i} = leveldn;
        end
%         strategy.wr_{i} = wrinfo;
        strategy.macdvec_{i} = macdvec;
        strategy.nineperma_{i} = sigvec;
            
        scenarioname = tdsq_getscenarioname(bs,ss,levelup,leveldn,bc,sc,p);
        fprintf('%s\n',scenarioname);
        tag = tdsq_snbd(scenarioname);
            
        %call a risk management before processing signal if there is any
        strategy.riskmanagement_futmultitdsq2('code',instruments{i}.code_ctp);
        
        % ------------------ reverse-type signals --------------------%
       %%
        if isempty(tag)
           signals{i,1} = {};
        else
           if strcmpi(tag,'perfectbs')
%                [~,~,~,~,~,idxtruelow,truelowbarsize] = tdsq_lastbs(bs,ss,levelup,leveldn,bc,sc,p);
%                truelow = p(idxtruelow,4);
%                risklvl = truelow - truelowbarsize;
               ibs = find(bs == 9,1,'last');
               %note:the stoploss shall be calculated using the perfect 9
               %bars
               truelow = min(p(ibs-8:ibs,4));
               idxtruelow = find(p(ibs-8:ibs,4) == truelow,1,'first');
               idxtruelow = idxtruelow + ibs - 9;
               truelowbarsize = p(idxtruelow,3) - truelow;
               stoploss = truelow - truelowbarsize;
               
               %note:hard-coded here:
               %todo:implement in cStratConfigTDSQ
               usesetups = false;
               
               np = size(p,1);
               if np > ibs    
                   stillvalid = isempty(find(p(ibs:end,5)<stoploss,1,'first'));
                   if stillvalid
                       if p(end,5) < leveldn(ibs), stillvalid = false;end
                   end
                   %
                   if stillvalid
                       if p(end,5) < truelow, stillvalid = false;end
                   end
                   %
                   if stillvalid && usesetups
                       if bs(end) >= 4 && bs(end) < 9, stillvalid = false;end
                   end
               else
                   stillvalid = true;
               end
               
               haslvlupbreachedwithmacdbearishafterwards = false;
               if stillvalid
                   ibreach = find(p(ibs:end,5) < levelup(ibs),1,'first');
                   if ~isempty(ibreach)
                       %lvlup has been breached
                       ibreach = ibreach + ibs-1;
                       diffvec = macdvec(ibreach:end-1)-sigvec(ibreach:end-1);
                       haslvlupbreachedwithmacdbearishafterwards = ~isempty(find(diffvec<0,1,'first'));
                   end
               end
               
%                if p(end,5) < risklvl
%                    signals{i,1} = {};
%                elseif p(end,5) < leveldn(end)
%                    signals{i,1} = {};
%                elseif bs(end) >= 4 && bs(end) < 9
%                    signals{i,1} = {};
               if ~stillvalid
                   signals{i,1} = {};
                   
               else
                   if haslvlupbreachedwithmacdbearishafterwards
                       risklvl = p(end,5) - (p(ibs,5) - stoploss);
                   else
                       risklvl = stoploss;
                   end
                   signals{i,1} = struct('name','tdsq',...
                       'instrument',instruments{i},'frequency',samplefreqstr,...
                       'scenarioname',scenarioname,...
                       'mode','reverse','type','perfectbs',...
                       'lvlup',levelup(ibs),'lvldn',leveldn(ibs),'risklvl',risklvl);
               end
           elseif strcmpi(tag,'semiperfectbs') || strcmpi(tag,'imperfectbs')
               if macdvec(end) > sigvec(end) && ~(bs(end) >= 4 && bs(end) <= 9)
                   signals{i,1} = struct('name','tdsq',...
                       'instrument',instruments{i},'frequency',samplefreqstr,...
                       'scenarioname',scenarioname,...
                       'mode','reverse','type',tag,...
                       'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99);
               end
           elseif strcmpi(tag,'perfectss')
               [~,~,~,~,~,idxtruehigh,truehighbarsize] = tdsq_lastss(bs,ss,levelup,leveldn,bc,sc,p);
               truehigh = p(idxtruehigh,3);
               risklvl = truehigh + truehighbarsize;
               if p(end,5) > risklvl
                   signals{i,1} = {};
               elseif p(end,5) > levelup(end)
                   signals{i,1} = {};
               elseif ss(end) >= 4 && ss(end) < 9
                   signals{i,1} = {};
               else
                   signals{i,1} = struct('name','tdsq',...
                       'instrument',instruments{i},'frequency',samplefreqstr,...
                       'scenarioname',scenarioname,'mode','reverse',...
                       'type','perfectss',...
                       'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',risklvl);
               end
           elseif strcmpi(tag,'semiperfectss') || strcmpi(tag,'imperfectss')
               if macdvec(end) < sigvec(end) && ~(ss(end) >= 4 && ss(end) <= 9)
                   signals{i,1} = struct('name','tdsq',...
                       'instrument',instruments{i},'frequency',samplefreqstr,...
                       'scenarioname',scenarioname,...
                       'mode','reverse','type',tag,...
                       'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99);
               end
           else
               error('%s:invalid tag name:%s\n',class(strategy),tag)
           end
        end
        %
       %%
        % ---- trend-type signals ------------------------------ %
        if isnan(leveldn(end)) && isnan(levelup(end))
            %NEITHER LVLUP NOR LVLDN IS AVAILABLE
            signals{i,2} = {};
        elseif ~isnan(leveldn(end)) && isnan(levelup(end))
            %SINGLE-LVLDN
            if p(end,5) < leveldn(end)
                wasabovelvldn = false;
                n = size(p,1);
                for j = max(1,n-8):max(1,n-1)
                    if p(j,5) > leveldn(end)
                        wasabovelvldn = true;break
                    end
                end
                wasmacdbullish = false;
                for j = max(1,n-8):max(1,n-1)
                    if macdvec(j) > sigvec(j)
                        wasmacdbullish = true;break
                    end
                end
                if (wasabovelvldn || wasmacdbullish) && macdvec(end) < sigvec(end) && bs(end) > 0 && bc(end) ~= 13
                    signals{i,2} = struct('name','tdsq',...
                       'instrument',instruments{i},'frequency',samplefreqstr,...
                       'scenarioname',scenarioname,...
                       'mode','trend','type','single-lvldn',...
                       'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99);
                else
                    signals{i,2} = {};
                end
            else
                signals{i,2} = {};
            end
        elseif isnan(leveldn(end)) && ~isnan(levelup(end))
            %SINGLE-LVLUP
            if p(end,5) > levelup(end)
                wasbelowlvlup = false;
                n = size(p,1);
                for j = max(1,n-8):max(1,n-1)
                    if p(j,5) < levelup(end)
                        wasbelowlvlup = true;break
                    end
                end
                wasmacdbearish = false;
                for j = max(1,n-8):max(1,n-1)
                    if macdvec(j) < sigvec(j)
                        wasmacdbearish = true;break
                    end
                end
                if(wasbelowlvlup || wasmacdbearish) && macdvec(end) < sigvec(end) && ss(end) > 0 && sc(end) ~= 13
                    signals{i,2} = struct('name','tdsq',...
                       'instrument',instruments{i},'frequency',samplefreqstr,...
                       'scenarioname',scenarioname,...
                       'mode','trend','type','single-lvlup',...
                       'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99);
                else
                    signals{i,2} = {};
                end
            else
                signals{i,2} = {};
            end
        else
            %BOTH LVLUP AND LVLDN ARE AVAILABLE
            isperfectbs = strcmpi(tag,'perfectbs');
            isperfectss = strcmpi(tag,'perfectss');
            %IN RANGE
            if levelup(end) > leveldn(end)
                isabove = p(end,5) > levelup(end);
                isbelow = p(end,5) < leveldn(end);
                isbetween = p(end,5) <= levelup(end) && p(end,5) >= leveldn(end);
                if isbetween
                    %check whether it was above the lvlup
                    idxlastabove = find(p(max(end-8,1):max(end-1,1),5)>levelup(end),1,'last');
                    wasabovelvlup = ~isempty(idxlastabove);
                    %and check whether it was below the lvldn
                    idxlastbelow = find(p(max(end-8,1):max(end-1,1),5)<leveldn(end),1,'last');
                    wasbelowlvldn = ~isempty(idxlastbelow);
                    if wasabovelvlup && wasbelowlvldn
                        %interesting case
                        if idxlastabove > idxlastbelow
                            wasbelowlvldn = false;
                        else
                            wasabovelvlup = false;
                        end
                    end
                    hassc13inrange = ~isempty(find(sc(end-11:end)==13, 1));
                    hasbc13inrange = ~isempty(find(bc(end-11:end)==13, 1));
                    %
                    if wasabovelvlup && macdvec(end)<sigvec(end) && bs(end)>0 && ~isperfectbs && ~hasbc13inrange
                        signals{i,2} = struct('name','tdsq',...
                            'instrument',instruments{i},'frequency',samplefreqstr,...
                            'scenarioname',scenarioname,...
                            'mode','trend','type','double-range',...
                            'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99,...
                            'direction',-1);
                    elseif wasbelowlvldn && macdvec(end)>sigvec(end) && ss(end)>0 && ~isperfectss && ~hassc13inrange
                        signals{i,2} = struct('name','tdsq',...
                            'instrument',instruments{i},'frequency',samplefreqstr,...
                            'scenarioname',scenarioname,...
                            'mode','trend','type','double-range',...
                            'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99,...
                            'direction',1);
                    else
                        signals{i,2} = {};
                    end
                    %
                elseif isabove
                    idxlastbelow = find(p(max(end-8,1):max(end-1,1),5)<levelup(end),1,'last');
                    wasbelowlvlup = ~isempty(idxlastbelow);
                    diffvec = macdvec - sigvec;
                    idxlastmacdbearish = find(diffvec(max(end-8,1):max(end-1,1),1)<0,1,'last');
                    wasmacdbearish = ~isempty(idxlastmacdbearish);
                    hassc13inrange = ~isempty(find(sc(end-11:end)==13, 1));
                    if (wasbelowlvlup || wasmacdbearish ) && macdvec(end)>sigvec(end) && ss(end)>0 && ~isperfectss && ~hassc13inrange
                        signals{i,2} = struct('name','tdsq',...
                            'instrument',instruments{i},'frequency',samplefreqstr,...
                            'scenarioname',scenarioname,...
                            'mode','trend','type','double-range',...
                            'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99,...
                            'direction',1);
                    else
                        signals{i,2} = {};
                    end
                    %
                elseif isbelow
                    idxlastabove = find(p(max(end-8,1):max(end-1,1),5)>leveldn(end),1,'last');
                    wasabovelvldn = ~isempty(idxlastabove);
                    diffvec = macdvec - sigvec;
                    idxlastmacdbullish = find(diffvec(max(end-8,1):max(end-1,1),1)>0,1,'last');
                    wasmacdbullish = ~isempty(idxlastmacdbullish);
                    hasbc13inrange = ~isempty(find(bc(end-11:end)==13, 1));
                    if (wasabovelvldn || wasmacdbullish) && macdvec(end)<sigvec(end) && bs(end) > 0 && ~isperfectbs && ~hasbc13inrange
                        signals{i,2} = struct('name','tdsq',...
                            'instrument',instruments{i},'frequency',samplefreqstr,...
                            'scenarioname',scenarioname,...
                            'mode','trend','type','double-range',...
                            'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99,...
                            'direction',-1);
                    else
                        signals{i,2} = {};
                    end
                end
            elseif levelup(end) < leveldn(end)
                idxbslatest = find(bs == 9,1,'last');
                idxsslatest = find(ss == 9,1,'last');
                if idxbslatest < idxsslatest
                    %bullish
                    %LONG ONLY IN BULLISH MOMENTUM
                    if p(end,5) > leveldn(end)
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
                            for j = max(1,n-8):n-1
                                if macdvec(j) < sigvec(j)
                                    wasmacdbearish = true;break
                                end
                            end
                        end
                        if (wasmacdbearish || (hassc13inrange && ~wasmacdbearish )) && macdvec(end) > sigvec(end) && ss(end) > 0 && sc(end) ~=13
                            signals{i,2} = struct('name','tdsq',...
                                'instrument',instruments{i},'frequency',samplefreqstr,...
                                'scenarioname',scenarioname,...
                                'mode','trend','type','double-bullish',...
                                'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99,...
                                'direction',1);
                        else
                            signals{i,2} = {};
                        end
                    else
                        signals{i,2} = {};
                    end
                else
                    %bearish
                    %SHORT ONLY IN BEARISH MOMENTUM
                    if p(end,5) < levelup(end)
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
                            signals{i,2} = struct('name','tdsq',...
                                'instrument',instruments{i},'frequency',samplefreqstr,...
                                'scenarioname',scenarioname,...
                                'mode','trend','type','double-bearish',...
                                'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99,...
                                'direction',-1);
                        else
                            signals{i,2} = {};
                        end
                    else
                        signals{i,2} = {};
                    end
                end                
            end
        end
                   
       %%  
        if strategy.printflag_
            if i == 1
                fprintf('%10s%11s%10s%8s%8s%10s%10s%10s%10s\n',...
                    'contract','time','px','bs','ss','levelup','leveldn','macd','sig');
            end
            tick = strategy.mde_fut_.getlasttick(instruments{i});
            timet = datestr(tick(1),'HH:MM:SS');
            
            dataformat = '%10s%11s%10s%8s%8s%10s%10s%10.1f%10.1f\n';
            fprintf(dataformat,instruments{i}.code_ctp,...
                timet,...
                num2str(p(end,5)),...
                num2str(bs(end)),num2str(ss(end)),num2str(levelup(end)),num2str(leveldn(end)),...
                macdvec(end),sigvec(end));
        end
        
    end
    
    
    

end