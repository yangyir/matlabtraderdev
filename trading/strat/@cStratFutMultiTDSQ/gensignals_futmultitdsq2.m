function signals = gensignals_futmultitdsq2(strategy)
%cStratFutMultiTDSQ
    %note:column 1 is for reverse-type signal
    %column 2 is for trend-type signal
    signals = cell(size(strategy.count,1),3);
    instruments = strategy.getinstruments;
    
    if strcmpi(strategy.mode_,'replay')
        runningt = strategy.replay_time1_;
    else
        runningt = now;
    end
    
    runningmm = hour(runningt)*60+minute(runningt);
    if (runningmm >= 538 && runningmm < 540) || ...
            (runningmm >= 778 && runningmm < 780) || ...
            (runningmm >= 1258 && runningmm < 1260)
            %one minute before market open in the morning, afternoon and
            %evening respectively
       for i = 1:strategy.count
           [macdvec,sigvec,p] = strategy.mde_fut_.calc_macd_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
           %
           [bs,ss,levelup,leveldn,bc,sc] = strategy.mde_fut_.calc_tdsq_(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
           %
           strategy.tdbuysetup_{i} = bs;
           strategy.tdsellsetup_{i} = ss;
           strategy.tdbuycountdown_{i} = bc;
           strategy.tdsellcountdown_{i} = sc;
           strategy.tdstlevelup_{i} = levelup;
           strategy.tdstleveldn_{i} = leveldn;
           strategy.macdvec_{i} = macdvec;
           strategy.nineperma_{i} = sigvec;
           %
           strategy.updatetag(instruments{i},p,bs,ss,levelup,leveldn);
           %
           diffvec = macdvec - sigvec;
           [macdbs,macdss] = tdsq_setup(diffvec);
           strategy.macdbs_{i} = macdbs;
           strategy.macdss_{i} = macdss;
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
            %NOTE:class variable _signals not updated if signals are not
            %calculated...^_^
            signals{i,1} = {};
            signals{i,2} = {};
            signals{i,3} = {};
            continue;
        end
        
        samplefreqstr = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','samplefreq');
        includelastcandle = strategy.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','includelastcandle');
        
        [macdvec,sigvec,p] = strategy.mde_fut_.calc_macd_(instruments{i},'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
        
    
        bs = strategy.tdbuysetup_{i};
        ss = strategy.tdsellsetup_{i};
        bc = strategy.tdbuycountdown_{i};
        sc = strategy.tdsellcountdown_{i};
        levelup = strategy.tdstlevelup_{i};
        leveldn = strategy.tdstleveldn_{i};
        
        if size(p,1) - size(bs,1) == 1
            if strategy.printflag_, fprintf('%s:update tdsq variables of %s...\n',strategy.name_,instruments{i}.code_ctp);end
            [bs,ss,levelup,leveldn,bc,sc] = tdsq_piecewise(p,bs,ss,levelup,leveldn,bc,sc);

        elseif size(p,1) < size(bs,1)
            [bs,ss,levelup,leveldn,bc,sc] = strategy.mde_fut_.calc_tdsq_(instruments{i},'IncludeLastCandle',includelastcandle,'RemoveLimitPrice',1);
        elseif size(p,1) - size(bs,1) > 1
            error('unknown error and check is required')
        end
        
        %update strategy-related variables
        strategy.tdbuysetup_{i} = bs;
        strategy.tdsellsetup_{i} = ss;
        strategy.tdbuycountdown_{i} = bc;
        strategy.tdsellcountdown_{i} = sc;
        strategy.tdstlevelup_{i} = levelup;
        strategy.tdstleveldn_{i} = leveldn;
        
        diffvec = macdvec - sigvec;
        [macdbs,macdss] = tdsq_setup(diffvec);
        strategy.macdbs_{i} = macdbs;
        strategy.macdss_{i} = macdss;
            
%         strategy.wr_{i} = wrinfo;
        strategy.macdvec_{i} = macdvec;
        strategy.nineperma_{i} = sigvec;
            
%         scenarioname = tdsq_getscenarioname(bs,ss,levelup,leveldn,bc,sc,p);
%         if strategy.printflag_, fprintf('%s:%s\n',strategy.name_,scenarioname);end
%         tag = tdsq_snbd(scenarioname);
        [~,tag] = strategy.updatetag(instruments{i},p,bs,ss,levelup,leveldn);
        
        %special treatment for perfectbs and perfectss
        if strcmpi(tag,'perfectbs') || strcmpi(tag,'perfectss') && strategy.useperfect_(i)
            hasperfectlivetrade = ~isempty(strategy.getlivetrade_tdsq(instruments{i}.code_ctp,'reverse',tag));
        else
            hasperfectlivetrade = false;
        end
             
        %call a risk management before processing signal if there is any
        %NOTE:we can only guarantee that an entrust with offset flag -1 is
        %placed (in most cases unless there is some network issue and etc)
        %HOWEVER,we cannot guarantee the entrust is sucessfully executed
        %That explained why we would require 'is2closetrade' to indicate
        %whether at this time point, the trade shall be closed or not
  
        strategy.riskmanagement_futmultitdsq2('code',instruments{i}.code_ctp);
                
        %special treatment for perfectbs and perfectss
        %we would not execute any open signal for the perfect bs/ss
        %scenario in case it is the time point on which the existing trade
        %is to be closed
        if hasperfectlivetrade
            typeidx = cTDSQInfo.gettypeidx(tag);
            is2closetrade = strategy.targetportfolio_(i,typeidx) == 0;
        end
        closeperfecttradeatm = hasperfectlivetrade && is2closetrade;
        
        % ---------------------------- reverse-type signals ---------------------------------------------%
       %%
        if isempty(tag)
           signals{i,1} = {};
        else
           signals{i,1} = {};
           if ~closeperfecttradeatm && strcmpi(tag,'perfectbs') && strategy.useperfect_(i)
               signals{i,1} = strategy.gensignal_perfect(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,'perfectbs');
               %
           elseif strcmpi(tag,'semiperfectbs') && strategy.usesemiperfect_(i)
               signals{i,1} = strategy.gensignal_semiperfect(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,'semiperfectbs');
               %
           elseif strcmpi(tag,'imperfectbs') && strategy.useimperfect_(i)
               signals{i,1} = strategy.gensignal_imperfect(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,'imperfectbs');
               %
           elseif ~closeperfecttradeatm && strcmpi(tag,'perfectss') && strategy.useperfect_(i)
               signals{i,1} = strategy.gensignal_perfect(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,'perfectss');
               %
           elseif strcmpi(tag,'semiperfectss') && strategy.usesemiperfect_(i)
               signals{i,1} = strategy.gensignal_semiperfect(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,'semiperfectss');
               %
           elseif strcmpi(tag,'imperfectss') && strategy.useimperfect_(i)
               signals{i,1} = strategy.gensignal_imperfect(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,'imperfectss');
               %
           else
               signals{i,1} = {};
           end
        end
        %
       %%
        % --------------------------------- trend-type signals ------------------------------ %
        signals{i,2} = {};
        if ~isnan(leveldn(end)) && isnan(levelup(end)) && strategy.usesinglelvldn_(i)
            %SINGLE-LVLDN
            signals{i,2} = strategy.gensignal_singlelvldn(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,tag);
            %
        elseif isnan(leveldn(end)) && ~isnan(levelup(end)) && strategy.usesinglelvlup_(i)
            %SINGLE-LVLUP
            signals{i,2} = strategy.gensignal_singlelvlup(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,tag);
            %
        elseif ~isnan(leveldn(end)) && ~isnan(levelup(end))
            %BOTH LVLUP AND LVLDN ARE AVAILABLE IN RANGE
            if levelup(end) > leveldn(end) && strategy.usedoublerange_(i)
                signals{i,2} = strategy.gensignal_doublerange(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,tag,macdbs,macdss);
                %
            elseif levelup(end) < leveldn(end) && (strategy.usedoublebullish_(i) || strategy.usedoublebearish_(i))
                idxbslatest = find(bs == 9,1,'last');
                idxsslatest = find(ss == 9,1,'last');
                if idxbslatest < idxsslatest && strategy.usedoublebullish_(i)
                    signals{i,2} = strategy.gensignal_doublebullish(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,tag);
                elseif idxbslatest > idxsslatest && strategy.usedoublebearish_(i)
                    signals{i,2} = strategy.gensignal_doublebearish(instruments{i},p,bs,ss,levelup,leveldn,macdvec,sigvec,bc,sc,tag);
                    %
                end
            end
            %
        end
       %%
        signals{i,3} = {};
        if strategy.usesimpletrend_(i)
            macdbs = strategy.macdbs_{i};
            macdss = strategy.macdss_{i};
            f1 = ss(end) > 0;
            f2 = diffvec(end) > 0 && diffvec(end-1) < 0;
            f3 = p(end,5) >= p(end,2);
            f4 = macdss(end) > 0;
            if f1 && f2 && f3 && f4
                signals{i,3} = struct('name','tdsq',...
                    'instrument',instruments{i},'frequency',samplefreqstr,...
                    'scenarioname',scenarioname,...
                    'mode','trend','type','simpletrend',...
                    'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99,...
                    'direction',1);
            else
                f1 = bs(end) > 0;
                f2 = diffvec(end) < 0 && diffvec(end-1) > 0;
                f3 = p(end,5) <= p(end,2);
                f4 = macdbs(end) > 0;
                if f1 && f2 && f3 && f4
                    signals{i,3} = struct('name','tdsq',...
                        'instrument',instruments{i},'frequency',samplefreqstr,...
                        'scenarioname',scenarioname,...
                        'mode','trend','type','simpletrend',...
                        'lvlup',levelup(end),'lvldn',leveldn(end),'risklvl',-9.99,...
                        'direction',-1);
                end
            end
            %  
        end
       %%
        fprintf('\n%s->tdsq info:\n',strategy.name_);
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
        
        %%
        strategy.signals_{i,1} = signals{i,1};
        strategy.signals_{i,2} = signals{i,2};
    end
    
    

end