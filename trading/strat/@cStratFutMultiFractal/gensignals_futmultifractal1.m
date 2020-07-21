function signals = gensignals_futmultifractal1(stratfractal)
%cStratFutMultiFractal
    n = stratfractal.count;
    signals = zeros(n,6);
    %column1:direction
    %column2:fractal hh
    %column3:fractal ll
    %column4:use flag
    %column5:hh1:open candle high
    %column6:ll1:open candle low
    
    
    if stratfractal.displaysignalonly_, return;end
    
    if strcmpi(stratfractal.mode_,'replay')
        runningt = stratfractal.replay_time1_;
    else
        runningt = now;
    end
    runningmm = hour(runningt)*60+minute(runningt);
    
    is2minbeforemktopen = (runningmm >= 538 && runningmm < 540) || ...      %08:58 to 08:59
            (runningmm >= 778 && runningmm < 780) || ...                    %12:58 to 12:59
            (runningmm >= 1258 && runningmm < 1260);                        %20:58 to 21:00
    
    calcsignalbeforemktclose = false;
    if (runningmm == 899 || runningmm == 914) && second(runningt) >= 56
        cobd = floor(runningt);
        nextbd = businessdate(cobd);
        calcsignalbeforemktclose = nextbd - cobd <= 3;
    end
    
    is2minbeforemktopen_govtbond = runningmm >= 553 && runningmm < 555;
    is2minbeforemktopen_eqindex = runningmm >= 568 && runningmm < 570;
    
    if is2minbeforemktopen_govtbond
        ntrades = stratfractal.helper_.trades_.latest_;
        for itrade = 1:ntrades
            trade_i = stratfractal.helper_.trades_.node_(itrade);
            if strcmpi(trade_i.instrument_.asset_name,'govtbond_10y') || ...
                    strcmpi(trade_i.instrument_.asset_name,'govtbond_5y')
                [~,idx_trade] = stratfractal.hasinstrument(trade_i.instrument_);
                techvar = stratfractal.calctechnicalvariable(trade_i.instrument_,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                p = techvar(:,1:5);
                stratfractal.hh_{idx_trade} = techvar(:,8);
                stratfractal.ll_{idx_trade} = techvar(:,9);
                stratfractal.jaw_{idx_trade} = techvar(:,10);
                stratfractal.teeth_{idx_trade} = techvar(:,11);
                stratfractal.lips_{idx_trade} = techvar(:,12);
                stratfractal.bs_{idx_trade} = techvar(:,13);
                stratfractal.ss_{idx_trade} = techvar(:,14);
                stratfractal.lvlup_{idx_trade} = techvar(:,15);
                stratfractal.lvldn_{idx_trade} = techvar(:,16);
                stratfractal.bc_{idx_trade} = techvar(:,17);
                stratfractal.sc_{idx_trade} = techvar(:,18);
                stratfractal.wad_{idx_trade} = techvar(:,19);
                %re-adj wad as the initial calc point changes
                iopen = find(p(:,1) <= trade_i.opendatetime1_,1,'last')-1;
                if trade_i.opendirection_ == 1
                    trade_i.riskmanager_.wadopen_ = stratfractal.wad_{idx_trade}(iopen);
                    trade_i.riskmanager_.wadhigh_ = max(stratfractal.wad_{idx_trade}(iopen:end));
                elseif trade_i.opendirection_ == -1
                    trade_i.riskmanager_.wadopen_ = stratfractal.wad_{idx_trade}(iopen);
                    trade_i.riskmanager_.wadlow_ = min(stratfractal.wad_{idx_trade}(iopen:end));
                end
            end
        end        
    end
    
    if is2minbeforemktopen_eqindex
        ntrades = stratfractal.helper_.trades_.latest_;
        for itrade = 1:ntrades
            trade_i = stratfractal.helper_.trades_.node_(itrade);
            if strcmpi(trade_i.instrument_.asset_name,'eqindex_300') || ...
                    strcmpi(trade_i.instrument_.asset_name,'eqindex_50') || ...
                    strcmpi(trade_i.instrument_.asset_name,'eqindex_500')
                [~,idx_trade] = stratfractal.hasinstrument(trade_i.instrument_);
                techvar = stratfractal.calctechnicalvariable(trade_i.instrument_,'IncludeLastCandle',1,'RemoveLimitPrice',1);
                p = techvar(:,1:5);
                stratfractal.hh_{idx_trade} = techvar(:,8);
                stratfractal.ll_{idx_trade} = techvar(:,9);
                stratfractal.jaw_{idx_trade} = techvar(:,10);
                stratfractal.teeth_{idx_trade} = techvar(:,11);
                stratfractal.lips_{idx_trade} = techvar(:,12);
                stratfractal.bs_{idx_trade} = techvar(:,13);
                stratfractal.ss_{idx_trade} = techvar(:,14);
                stratfractal.lvlup_{idx_trade} = techvar(:,15);
                stratfractal.lvldn_{idx_trade} = techvar(:,16);
                stratfractal.bc_{idx_trade} = techvar(:,17);
                stratfractal.sc_{idx_trade} = techvar(:,18);
                stratfractal.wad_{idx_trade} = techvar(:,19);
                %re-adj wad as the initial calc point changes
                iopen = find(p(:,1) <= trade_i.opendatetime1_,1,'last')-1;
                if trade_i.opendirection_ == 1
                    trade_i.riskmanager_.wadopen_ = stratfractal.wad_{idx_trade}(iopen);
                    trade_i.riskmanager_.wadhigh_ = max(stratfractal.wad_{idx_trade}(iopen:end));
                elseif trade_i.opendirection_ == -1
                    trade_i.riskmanager_.wadopen_ = stratfractal.wad_{idx_trade}(iopen);
                    trade_i.riskmanager_.wadlow_ = min(stratfractal.wad_{idx_trade}(iopen:end));
                end
            end
        end        
    end
    
    instruments = stratfractal.getinstruments;
        
    if is2minbeforemktopen || calcsignalbeforemktclose
        for i = 1:n
            techvar = stratfractal.calctechnicalvariable(instruments{i},'IncludeLastCandle',1,'RemoveLimitPrice',1);
            p = techvar(:,1:5);
            stratfractal.hh_{i} = techvar(:,8);
            stratfractal.ll_{i} = techvar(:,9);
            stratfractal.jaw_{i} = techvar(:,10);
            stratfractal.teeth_{i} = techvar(:,11);
            stratfractal.lips_{i} = techvar(:,12);
            stratfractal.bs_{i} = techvar(:,13);
            stratfractal.ss_{i} = techvar(:,14);
            stratfractal.lvlup_{i} = techvar(:,15);
            stratfractal.lvldn_{i} = techvar(:,16);
            stratfractal.bc_{i} = techvar(:,17);
            stratfractal.sc_{i} = techvar(:,18);
            stratfractal.wad_{i} = techvar(:,19);
        end
        
        if is2minbeforemktopen
            ntrades = stratfractal.helper_.trades_.latest_;
            for itrade = 1:ntrades
                trade_i = stratfractal.helper_.trades_.node_(itrade);
                [~,idx_trade] = stratfractal.hasinstrument(trade_i.instrument_);
                %re-adj wad as the initial calc point changes
                iopen = find(p(:,1) <= trade_i.opendatetime1_,1,'last')-1;
                if trade_i.opendirection_ == 1
                    trade_i.riskmanager_.wadopen_ = stratfractal.wad_{idx_trade}(iopen);
                    trade_i.riskmanager_.wadhigh_ = max(stratfractal.wad_{idx_trade}(iopen:end));
                elseif trade_i.opendirection_ == -1
                    trade_i.riskmanager_.wadopen_ = stratfractal.wad_{idx_trade}(iopen);
                    trade_i.riskmanager_.wadlow_ = min(stratfractal.wad_{idx_trade}(iopen:end));
                end
            end          
        end
        
        if is2minbeforemktopen, return;end
    end
    
    calcsignalflag = zeros(n,1);
    for i = 1:n
        try
            calcsignalflag(i) = stratfractal.getcalcsignalflag(instruments{i});
        catch e
            calcsignalflag(i) = 0;
            msg = ['ERROR:%s:getcalcsignalflag:',class(stratfractal),e.message,'\n'];
            fprintf(msg);
%             if strcmpi(stratfractal.onerror_,'stop'), stratfractal.stop; end
        end
    end
    %
    if sum(calcsignalflag) == 0, return;end
    
    fprintf('\n%s->%s:signal calculated...\n',stratfractal.name_,datestr(runningt,'yyyy-mm-dd HH:MM'));
    
    for i = 1:n
        if ~calcsignalflag(i) && ~calcsignalbeforemktclose;continue;end
        
        if calcsignalflag(i) && ~calcsignalbeforemktclose
            techvar = stratfractal.calctechnicalvariable(instruments{i},'IncludeLastCandle',0,'RemoveLimitPrice',1);
            p = techvar(:,1:5);
            idxHH = techvar(:,6);
            idxLL = techvar(:,7);
            hh = techvar(:,8);
            ll = techvar(:,9);
            jaw = techvar(:,10);
            teeth = techvar(:,11);
            lips = techvar(:,12);
            bs = techvar(:,13);
            ss = techvar(:,14);
            lvlup = techvar(:,15);
            lvldn = techvar(:,16);
            bc = techvar(:,17);
            sc = techvar(:,18);
            wad = techvar(:,19); 
            %
            stratfractal.hh_{i} = hh;
            stratfractal.ll_{i} = ll;
            stratfractal.jaw_{i} = jaw;
            stratfractal.teeth_{i} = teeth;
            stratfractal.lips_{i} = lips;
            stratfractal.bs_{i} = bs;
            stratfractal.ss_{i} = ss;
            stratfractal.lvlup_{i} = lvlup;
            stratfractal.lvldn_{i} = lvldn;
            stratfractal.bc_{i} = bc;
            stratfractal.sc_{i} = sc;
            stratfractal.wad_{i} = wad;
            
            nfractal = stratfractal.riskcontrols_.getconfigvalue('code',instruments{i}.code_ctp,'propname','nfractals');
            
            try
                ticksize = instruments{i}.tick_size;
            catch
                ticksize = 0;
            end
            
            validbreachhh = p(end,5)-hh(end-1)>ticksize & p(end-1,5)<=hh(end-1) &...
                abs(hh(end-1)/hh(end)-1)<0.002 &...
                p(end,3)>lips(end) &...
                ~isnan(lips(end))&~isnan(teeth(end))&~isnan(jaw(end))&... 
                hh(end)-teeth(end)>=ticksize;
            
            if validbreachhh
                if teeth(end)>jaw(end)
                    b1type = 3;
                else
                    b1type = 2;
                end
                extrainfo = struct('px',p,'ss',ss,'sc',sc,'lvlup',lvlup,'lvldn',lvldn,...
                    'idxhh',idxHH,'hh',hh,...
                    'idxll',idxLL,'ll',ll,...
                    'lips',lips,'teeth',teeth,'jaw',jaw,...
                    'wad',wad);
                op = fractal_filterb1_singleentry(b1type,nfractal,extrainfo);
                validbreachhh = op.use;
                if ~validbreachhh
                    %special treatment when market jumps
                    tick = stratfractal.mde_fut_.getlasttick(instruments{i});
                    if ~isempty(tick)
                        ask = tick(3);
                        if ask>lvlup(end) && p(end,5)<lvlup(end)
                            validbreachhh = 1;
                            op.comment = 'breachup-lvlup';
                        end
                    end
                end
                if ~validbreachhh
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(0),op.comment);
                    continue;
                end
                if validbreachhh && ...
                        p(end,5) > p(end,3)-0.382*(p(end,3)-ll(end)) && ...
                        p(end,5) < hh(end)+1.618*(hh(end)-ll(end)) && ...
                        p(end,5) > lips(end)
                    signals(i,1) = 1;                                           %breach hh buy
                    signals(i,2) = hh(end);
                    signals(i,3) = ll(end);
                    signals(i,5) = p(end,3);
                    signals(i,6) = p(end,4);
                    switch op.comment
                        case 'breachup-lvlup'
                            signals(i,4) = 1;
                        case 'volblowup'
                            signals(i,4) = 1;
                        otherwise
                            signals(i,4) = 0;
                    end
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(1),op.comment);
                    continue;
                end
            end
                  
            validbreachll = p(end,5)-ll(end-1)<-ticksize & p(end-1,5)>=ll(end-1)&...
                abs(ll(end-1)/ll(end)-1)<0.002 &...
                p(end,4)<lips(end) &...
                ~isnan(lips(end))&~isnan(teeth(end))&~isnan(jaw(end))&...
                ll(end)-teeth(end)<=-ticksize;
            
            if validbreachll
                if teeth(end)<jaw(end)
                    s1type = 3;
                else
                    s1type = 2;
                end
                extrainfo = struct('px',p,'bs',bs,'bc',bc,'lvlup',lvlup,'lvldn',lvldn,...
                    'idxhh',idxHH,'hh',hh,...
                    'idxll',idxLL,'ll',ll,...
                    'lips',lips,'teeth',teeth,'jaw',jaw,...
                    'wad',wad);
                op = fractal_filters1_singleentry(s1type,nfractal,extrainfo);
                validbreachll = op.use;
                if ~validbreachll
                    %special treatment when market jumps
                    tick = stratfractal.mde_fut_.getlasttick(instruments{i});
                    if ~isempty(tick)
                        bid = tick(2);
                        if bid < lvldn(end) && p(end,5)>lvldn(end)
                            validbreachll = 1;
                            op.comment = 'breachdn-lvldn';
                        end
                    end
                end
                if ~validbreachll
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(0),op.comment);
                    continue;
                end
                if validbreachll && ...
                        p(end,5) < p(end,4)+0.382*(hh(end)-p(end,4)) && ...
                        p(end,5) > ll(end)-1.618*(hh(end)-ll(end)) && ...
                        p(end,5) < lips(end)
                    signals(i,1) = -1;                                          %breach ll sell
                    signals(i,2) = hh(end);
                    signals(i,3) = ll(end);
                    signals(i,5) = p(end,3);
                    signals(i,6) = p(end,4);
                    switch op.comment
                        case 'breachdn-lvldn'
                            signals(i,4) = 1;
                        case 'volblowup'
                            signals(i,4) = 1;
                        case 'breachdn-bshighvalue'
                            signals(i,4) = 1;
                        otherwise
                            signals(i,4) = 0;
                    end
                    fprintf('\t%6s:%4s\t%10s\n',instruments{i}.code_ctp,num2str(-1),op.comment);
                    continue;
                end
            end
            
        end
    end
   
    
    
    
    if sum(abs(signals(:,1))) == 0, return;end
    
    fprintf('\n');
end