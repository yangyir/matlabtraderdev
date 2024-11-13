function [] = riskmanagement(obj,dtnum)
%cStrat:base class
    ismarketopen = zeros(obj.count,1);
    instruments = obj.getinstruments;
    for i = 1:obj.count
        %firstly to check whether this is in trading hours
        ismarketopen(i) = istrading(dtnum,instruments{i}.trading_hours,...
            'tradingbreak',instruments{i}.trading_break);
    end
    
    if sum(ismarketopen) == 0, return; end
    
    ntrades = obj.helper_.trades_.latest_;
    %set risk manager
    for i = 1:ntrades
        trade_i = obj.helper_.trades_.node_(i);
        instrument = trade_i.instrument_;
        if strcmpi(trade_i.status_,'closed'), continue; end
        if ~isempty(trade_i.riskmanager_), continue;end
        if isempty(trade_i.opensignal_) && isa(obj,'cStratFutPairCointegration'), continue;end
        
        if isa(trade_i.opensignal_,'cManualInfo')
            pxtarget = trade_i.opensignal_.pxtarget_;
            if pxtarget == -9.99, pxtarget = trade_i.opendirection_*inf;end
            pxstoploss = trade_i.opensignal_.pxstoploss_;
            if pxstoploss == -9.99,pxstoploss = trade_i.opendirection_*(-inf);end
            if strcmpi(trade_i.opensignal_.riskmanagername_,'standard')
                extrainfo = struct('pxtarget_',pxtarget,'pxstoploss_',pxstoploss);
            elseif strcmpi(trade_i.opensignal_.riskmanagername_,'batman')
                try
                    bandwidthmin = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmin');
                catch
                    bandwidthmin = 0.3333;  %default value 1/3
                end
                try
                    bandwidthmax = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmax');
                catch
                    bandwidthmax = 0.5;     %default value 1/2
                end
                extrainfo = struct('pxtarget_',pxtarget,...
                    'pxstoploss_',pxstoploss,...
                    'bandstoploss_',-9.99,...
                    'bandtarget_',-9.99,...
                    'bandwidthmin_',bandwidthmin,...
                    'bandwidthmax_',bandwidthmax);
            elseif strcmpi(trade_i.opensignal_.riskmanagername_,'wrstep')
                error('ERROR:%s:riskmanagement:invalid riskmangername for manual trading',class(obj))
            end
            trade_i.setriskmanager('name',trade_i.opensignal_.riskmanagername_,'extrainfo',extrainfo);
            %
        elseif isa(trade_i.opensignal_,'cFractalInfo')
            hh = trade_i.opensignal_.hh_;
            ll = trade_i.opensignal_.ll_;
            type = trade_i.opensignal_.type_;
            instrument = trade_i.instrument_;
            riskmanagername = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','riskmanagername');
            if strcmpi(riskmanagername,'standard')
                if strcmpi(type,'breachup-B')
                    pxstoploss = hh-(hh-ll)*0.382;
                    pxtarget = hh+hh-ll;
                elseif strcmpi(type,'reverse-B')
                    error('ERROR:%s:riskmanagement:reverse-B not implemented for FRACTAL...',class(obj))
                elseif strcmpi(type,'breachdn-S')
                    pxstoploss = ll+(hh-ll)*0.382;
                    pxtarget = ll-(hh-ll);
                elseif strcmpi(type,'reverse-S')
                    error('ERROR:%s:riskmanagement:reverse-S not implemented for FRACTAL...',class(obj))
                else
                    error('ERROR:%s:riskmanagment:invalid type for FRACTAL...',class(obj))
                end
                extrainfo = struct('pxtarget_',pxtarget,'pxstoploss_',pxstoploss);
            elseif strcmpi(riskmanagername,'spiderman')
                if strcmpi(trade_i.opensignal_.mode_,'conditional-uptrendconfirmed-2') || ...
                        strcmpi(trade_i.opensignal_.mode_,'conditional-uptrendconfirmed-3') || ...
                        strcmpi(trade_i.opensignal_.mode_,'conditional-dntrendconfirmed-2') || ...
                        strcmpi(trade_i.opensignal_.mode_,'conditional-dntrendconfirmed-3')
                    [bs,ss,~,~,bc,sc,px] = obj.mde_fut_.calc_tdsq_(instrument,'includelastcandle',0,'removelimitprice',0);
                    if strcmpi(trade_i.opensignal_.mode_,'conditional-uptrendconfirmed-2')
                        sslastidx = find(ss>=9,1,'last');
                        sslastval = ss(sslastidx);
                        tdhigh_ = max(px(sslastidx-sslastval+1:sslastidx,3));
                        tdidx_ = find(px(sslastidx-sslastval+1:sslastidx,3) == tdhigh_,1,'last') + sslastidx-sslastval;
                        tdlow_ = px(tdidx_,4);
                        td13low_ = NaN;
                        td13high_ = NaN;
                    elseif strcmpi(trade_i.opensignal_.mode_,'conditional-uptrendconfirmed-3')
                        sclastidx = find(sc==13,1,'last');
                        td13low_ = px(sclastidx,4);
                        td13high_ = NaN;
                        tdhigh_ = NaN;
                        tdlow_ = NaN;
                    elseif strcmpi(trade_i.opensignal_.mode_,'conditional-dntrendconfirmed-2')
                        bslastidx = find(bs>=9,1,'last');
                        bslastval = bs(bslastidx);
                        tdlow_ = min(px(bslastidx-bslastval+1:bslastidx,4));
                        tdidx_ = find(px(bslastidx-bslastval+1:bslastidx,4) == tdlow_,1,'last') + bslastidx-bslastval;
                        tdhigh_ = px(tdidx_,3);
                        td13low_ = NaN;
                        td13high_ = NaN;
                    elseif strcmpi(trade_i.opensignal_.mode_,'conditional-dntrendconfirmed-3')
                        bclastidx = find(bc==13,1,'last');
                        td13high_ = px(bclastidx,3);
                        td13low_ = NaN;
                        tdhigh_ = NaN;
                        tdlow_ = NaN;
                    end
                else
                    td13high_ = NaN;
                    td13low_ = NaN;
                    tdlow_ = NaN;
                    tdhigh_ = NaN;
                end
                
                
                if trade_i.opendirection_ == 1
                    hh1 = trade_i.opensignal_.hh1_;
                    extrainfo = struct('hh0_',hh,'hh1_',hh,'ll0_',ll,'ll1_',ll,...
                        'type_',type,...
                        'fibonacci1_',0.618*hh+0.382*hh1,...
                        'fibonacci0_',ll,...
                        'status_','unset',...
                        'pxtarget_',-9.99,...
                        'pxstoploss_',-9.99,...
                        'tdlow_',tdlow_,...
                        'tdhigh_',tdhigh_,...
                        'td13high_',td13high_,...
                        'td13low_',td13low_,...
                        'closestr_','none');
                else
                    ll1 = trade_i.opensignal_.ll1_;
                    extrainfo = struct('hh0_',hh,'hh1_',hh,'ll0_',ll,'ll1_',ll,...
                        'type_',type,...
                        'fibonacci1_',hh,...
                        'fibonacci0_',0.618*ll+0.382*ll1,...
                        'status_','unset',...
                        'pxtarget_',-9.99,...
                        'pxstoploss_',-9.99,...
                        'tdlow_',tdlow_,...
                        'tdhigh_',tdhigh_,...
                        'td13high_',td13high_,...
                        'td13low_',td13low_,...
                        'closestr_','none');
                end
                
            else
                error('ERROR:%s;riskmanagement:unsupported risk manger name for FRACTAL...',class(obj))
            end
            trade_i.setriskmanager('name',riskmanagername,'extrainfo',extrainfo);
            usefracalupdateflag = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','usefractalupdate');
            usefibonacciflag = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','usefibonacci');
            trade_i.riskmanager_.setusefractalupdateflag(usefracalupdateflag);
            trade_i.riskmanager_.setusefibonacciflag(usefibonacciflag);
            %    
        else
            %other opensignal
            instrument = trade_i.instrument_;
            overrideriskmanagername = trade_i.opensignal_.overrideriskmanagername_;
            if ~isempty(overrideriskmanagername)
                riskmanagername = overrideriskmanagername;
            else
                riskmanagername = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','riskmanagername');
            end
            
            overridepxstoploss = trade_i.opensignal_.overridepxstoploss_;
            if abs(overridepxstoploss + 9.99) > 1e-6
                pxstoploss = overridepxstoploss;
            else
                stoptype = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','stoptypepertrade');
                stopamount = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','stopamountpertrade');
                if stopamount == -9.99
                    pxstoploss = -trade_i.opendirection_*inf;
                else
                    if strcmpi(stoptype,'rel')
                        pxstoploss = trade_i.openprice_ * (1+trade_i.opendirection_*stopamount);
                    elseif strcmpi(stoptype,'abs')
                        pxstoploss = trade_i.openprice_ + trade_i.opendirection_*stopamount/(instrument.tick_value*trade_i.openvolume_)*instrument.tick_size;
                    elseif strcmpi(stoptype,'opt')
                        nperiod = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','numofperiod');
                        includelastcandle = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','includelastcandle');
                        %
                        vol = obj.mde_fut_.calc_hv(instrument,'numofperiods',nperiod,'includelastcandle',includelastcandle,'method','linear');
                        retstoploss = blkprice(1,1,0,1,vol)*abs(stopamount);
                        pxstoploss = trade_i.openprice_ - trade_i.opendirection_*retstoploss*trade_i.openprice_;
                    else
                        error('ERROR:%s:riskmanagement:invalid stoptypepertrade',class(obj))
                    end
                    %
                    if trade_i.opendirection_ == 1
                        pxstoploss = ceil(pxstoploss/instrument.tick_size)*instrument.tick_size;
                    else
                        pxstoploss = floor(pxstoploss/instrument.tick_size)*instrument.tick_size;
                    end
                end
            end
            %
            overridepxtarget = trade_i.opensignal_.overridepxtarget_;
            if abs(overridepxtarget + 9.99) > 1e-6
                pxtarget = overridepxtarget;
            else
                limittype = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','limittypepertrade');
                limitamount = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','limitamountpertrade');
                if limitamount == -9.99
                    pxtarget = trade_i.opendirection_*inf;
                else
                    if strcmpi(limittype,'rel')
                        pxtarget = trade_i.openprice_ * (1+trade_i.opendirection_*limitamount);
                    elseif strcmpi(limittype,'abs')
                        pxtarget = trade_i.openprice_ + trade_i.opendirection_*limitamount/(instrument.tick_value*trade_i.openvolume_)*instrument.tick_size;
                    else
                        error('ERROR:%s:riskmanagement:invalid limittypepertrade',class(obj))
                    end
                end
            end
            %
            if strcmpi(riskmanagername,'standard')
                extrainfo = struct('pxtarget_',pxtarget,'pxstoploss_',pxstoploss);
            elseif strcmpi(riskmanagername,'wrstep')
                try
                    stepvalue = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','stepvalue');
                catch
                    stepvalue = 10;
                end
                try
                    buffer = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','buffer');
                catch
                    buffer = 1;
                end
                extrainfo = struct('pxstoploss_',pxstoploss,'stepvalue_',stepvalue,'buffer_',buffer);
            elseif strcmpi(riskmanagername,'batman')
                try
                    bandtype = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandtype');
                catch
                    bandtype = 1;
                end
                try
                    bandwidthmin = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmin');
                catch
                    bandwidthmin = 0.3333;  %default value 1/3
                end
                try
                    bandwidthmax = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandwidthmax');
                catch
                    bandwidthmax = 0.5;     %default value 1/2
                end
                if bandtype == 0
                    %conventional set-up with bandtype == 0
                    bandstoploss = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandstoploss');
                    bandtarget = obj.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','bandtarget');
                    extrainfo = struct('pxtarget_',pxtarget,...
                        'pxstoploss_',pxstoploss,...
                        'bandstoploss_',bandstoploss,...
                        'bandtarget_',bandtarget,...
                        'bandwidthmin_',bandwidthmin,...
                        'bandwidthmax_',bandwidthmax);
                elseif bandtype == 1
                    try
                        wrmode = trade_i.opensignal_.wrmode_;
                        isflash = strcmpi(wrmode,'flash');
                    catch
                        isflash = false;
                    end
                    if isflash
                        if trade_i.opendirection_ == 1
                            pxstoploss = trade_i.opensignal_.lowestlow_;
                        else
                            pxstoploss = trade_i.opensignal_.highesthigh_;
                        end
                        pxtarget = trade_i.openprice_ + trade_i.opendirection_*abs(trade_i.openprice_-pxstoploss)*0.5;
                        extrainfo = struct('pxtarget_',pxtarget,...
                            'pxstoploss_',pxstoploss,...
                            'bandstoploss_',-9.99,...
                            'bandtarget_',-9.99,...
                            'bandwidthmin_',bandwidthmin,...
                            'bandwidthmax_',bandwidthmax);
                        trade_i.status_ = 'set';
                    else
                        extrainfo = struct('pxtarget_',pxtarget,...
                            'pxstoploss_',pxstoploss,...
                            'bandstoploss_',-9.99,...
                            'bandtarget_',-9.99,...
                            'bandwidthmin_',bandwidthmin,...
                            'bandwidthmax_',bandwidthmax);
                    end
                end
            end
            trade_i.setriskmanager('name',riskmanagername,'extrainfo',extrainfo);
        end
    end
    %
    %
    %set status of trade with risk management in place
    if isa(obj,'cStratFutPairCointegration')
    elseif isa(obj,'cStratFutMultiFractal')
        for i = 1:ntrades
            trade_i = obj.helper_.trades_.node_(i);
            if strcmpi(trade_i.status_,'closed'), continue; end
            
            if strcmpi(trade_i.opensignal_.frequency_,'30m') || strcmpi(trade_i.opensignal_.frequency_,'5m') || ...
                    strcmpi(trade_i.opensignal_.frequency_,'15m')
                kellytables = obj.tbl_all_intraday_;
            else
                kellytables = obj.tbl_all_daily_;
            end
            unwindtrade = trade_i.riskmanager_.riskmanagement('MDEFut',obj.mde_fut_,...
                'UpdatePnLForClosedTrade',false,'Strategy',obj,'KellyTables',kellytables);
        
            if ~isempty(unwindtrade)
                obj.unwindtrade(unwindtrade);
                if ~isempty(strfind(unwindtrade.closestr_,'conditional')) || ...
                        ~isempty(strfind(unwindtrade.closestr_,'conditional')) || ...
                        ~isempty(strfind(unwindtrade.closestr_,'fractal:upupdate')) || ...
                        ~isempty(strfind(unwindtrade.closestr_,'fractal:dnupdate')) || ...
                        ~isempty(strfind(unwindtrade.closestr_,'wad'))
                    instrument = unwindtrade.instrument_;
                    flag = obj.helper_.book_.hasposition(instrument);
                    nloopmax = 119;
                    iloop = 0;
                    while flag && iloop <= nloopmax
                        obj.helper_.refresh;
                        flag = obj.helper_.book_.hasposition(instrument);
                        iloop = iloop + 1;
                    end
                    %make sure we are not gen any signals just before
                    %market close in case there is any trade being unwinded
                    %here
                    if strcmpi(obj.mode_,'replay')
                        runningt = obj.replay_time1_;
                    else
                        runningt = now;
                    end
                    lasttick = obj.mde_fut_.getlasttick(instrument);
                    ticktime = lasttick(1);
                    if ticktime - runningt < -1e-3
                        fprintf('time discrepancy is found between tick and calendar time...\n');
                        return;
                    end
                    runningmm = hour(runningt)*60+minute(runningt);
                    tickm = hour(ticktime)*60+minute(ticktime);
                    freq = obj.mde_fut_.getcandlefreq(instrument);
                    runriskmanagementbeforemktclose = false;
                    if freq ~= 1440
                        if runningmm == unwindtrade.oneminb4close1_ && tickm == unwindtrade.oneminb4close1_ && (second(runningt) >= 59 || second(ticktime) >= 59)
                            runriskmanagementbeforemktclose = true;
                        elseif runningmm == unwindtrade.oneminb4close2_ && tickm == unwindtrade.oneminb4close2_ && (second(runningt) >= 59 || second(ticktime) >= 59)
                            runriskmanagementbeforemktclose = true;
                        end
                    else
                        if runningmm == unwindtrade.oneminb4close1_ && tickm == unwindtrade.oneminb4close1_ && (second(runningt) >= 59 || second(ticktime) >= 59)
                            runriskmanagementbeforemktclose = true;
                        end
                    end
                    if ~runriskmanagementbeforemktclose && isempty(strfind(unwindtrade.closestr_,'shadowline')) && ...
                            isempty(strfind(unwindtrade.closestr_,'sc13')) && isempty(strfind(unwindtrade.closestr_,'bc13')) && ...
                            isempty(strfind(unwindtrade.closestr_,'lowkelly'))
                        %avoid to reopen conditional trade in case the
                        %market is about to close or the previous unwinded
                        %trade is due to shadowline
                        signals_ = obj.gensignalssingle('instrument',instrument);
                        obj.autoplacenewentrustssingle('instrument',instrument,'signals',signals_);
                    end
                end
            end
        end
    else
        for i = 1:ntrades
            trade_i = obj.helper_.trades_.node_(i);
            if strcmpi(trade_i.status_,'closed'), continue; end
        
            unwindtrade = trade_i.riskmanager_.riskmanagement('MDEFut',obj.mde_fut_,...
                'UpdatePnLForClosedTrade',false);
        
            if ~isempty(unwindtrade)
                obj.unwindtrade(unwindtrade);
            end
        end
        %cStratFutPairCointegration
%         instruments = obj.getinstruments;
%         leg1 = instruments{1};
%         leg2 = instruments{2};
%         
%         
%         for i = 1:ntrades
%             trade_i = obj.helper_.trades_.node_(i);
%             if strcmpi(trade_i.status_,'closed'), continue; end
%             if strcmpi(trade_i.code,leg1.code_ctp),trade1 = trade_i; continue;end
%             if strcmpi(trade_i.code,leg2.code_ctp),trade2 = trade_i; continue;end
%         end
        
        
                
    end

end