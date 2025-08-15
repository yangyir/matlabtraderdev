function [] = onNewSignal(obj,~,eventData)
% a charlotteTraderFX function
    data = eventData.MarketData;
     
    n = size(data.signals_,1);
    for i = 1:n
        signal_i = data.signals_{i};
        if isempty(signal_i)
            continue;
        end
        
        if ~data.newsignals_(i)
            continue;
        end
        
        code_i = data.codes_{i};
        strsplit = regexp(code_i,'-','split');
        code_i = strsplit{1};
        ei_i = data.ei_{i};
        freq_i = data.freq_{i};
        mode_i = data.modes_{i};
        nfractal = charlotte_freq2nfractal(freq_i);
        
        if isempty(strfind(signal_i.opkellied,'conditional')) && isempty(strfind(signal_i.opkellied,'potential')) && isempty(strfind(signal_i.opkellied,'not to place'))
            %unconditional signal
            if signal_i.directionkellied == 1 && ~obj.hasLongPosition(code_i,freq_i)
                if ~signal_i.status.istrendconfirmed
                    % no conditional signal on the previous candle
                    trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.opkellied,1,freq_i,nfractal);
                    trade.riskmanager_.setusefractalupdateflag(0);
                    trade.riskmanager_.setusefibonacciflag(1);
                    unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
                        'usecandlelastonly',true,...
                        'debug',false,...
                        'updatepnlforclosedtrade',true,...
                        'extrainfo',ei_i,...
                        'RunRiskManagementBeforeMktClose',false,...
                        'KellyTables',data.kellytables_{i},...
                        'CompulsoryCheckForConditional',true);
                    if ~isempty(unwindtrade)
                        trade.status_ = 'closed';
                    end
                    obj.book_.push(trade);
                    if strcmpi(mode_i,'realtime')
                        exporttrade2mt4(trade,ei_i);
                    else
                        freq = trade.opensignal_.frequency_;
                        freqappendix = freq2mt4freq(freq);
                        opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                        fn = [getenv('OneDrive'),'\mt4\replay\',trade.code_,'.lmx_',freqappendix,'_trades_',opendtstr,'.txt'];
                        exporttrade2mt4(trade,ei_i,fn);
                    end
                else
                    %
                end
            elseif signal_i.directionkellied == 1 && obj.hasLongPosition(code_i,freq_i)
                %
            elseif signal_i.directionkellied == -1 && ~obj.hasShortPosition(code_i,freq_i)
                if ~signal_i.status.istrendconfirmed
                    % no conditional signal on the previous candle
                    trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.opkellied,-1,freq_i,nfractal);
                    trade.riskmanager_.setusefractalupdateflag(0);
                    trade.riskmanager_.setusefibonacciflag(1);
                    unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
                        'usecandlelastonly',true,...
                        'debug',false,...
                        'updatepnlforclosedtrade',true,...
                        'extrainfo',ei_i,...
                        'RunRiskManagementBeforeMktClose',false,...
                        'KellyTables',data.kellytables_{i},...
                        'CompulsoryCheckForConditional',true);
                    if ~isempty(unwindtrade)
                        trade.status_ = 'closed';
                    end
                    obj.book_.push(trade);
                    if strcmpi(mode_i,'realtime')
                        exporttrade2mt4(trade,ei_i);
                    else
                        freq = trade.opensignal_.frequency_;
                        freqappendix = freq2mt4freq(freq);
                        opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                        fn = [getenv('OneDrive'),'\mt4\replay\',trade.code_,'.lmx_',freqappendix,'_trades_',opendtstr,'.txt'];
                        exporttrade2mt4(trade,ei_i,fn);
                    end
                else
                    if signal_i.status.islvldnbreach
                        trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.opkellied,-1,freq_i,nfractal,0);
                        trade.riskmanager_.setusefractalupdateflag(0);
                        trade.riskmanager_.setusefibonacciflag(1);
                        unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
                            'usecandlelastonly',true,...
                            'debug',false,...
                            'updatepnlforclosedtrade',true,...
                            'extrainfo',ei_i,...
                            'RunRiskManagementBeforeMktClose',false,...
                            'KellyTables',data.kellytables_{i},...
                            'CompulsoryCheckForConditional',true);
                        if ~isempty(unwindtrade)
                            trade.status_ = 'closed';
                        end
                        obj.book_.push(trade);
                        if strcmpi(mode_i,'realtime')
                            exporttrade2mt4(trade,ei_i);
                        else
                            freq = trade.opensignal_.frequency_;
                            freqappendix = freq2mt4freq(freq);
                            opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                            fn = [getenv('OneDrive'),'\mt4\replay\',trade.code_,'.lmx_',freqappendix,'_trades_',opendtstr,'.txt'];
                            exporttrade2mt4(trade,ei_i,fn);
                        end
                    end
                    %
                end
            elseif signal_i.directionkellied == -1 && obj.hasShortPosition(code_i,freq_i)
                %
            elseif signal_i.directionkellied == 0
                %conditional kelly breaks trades....
                %here the trade might be booked twice and we need a work
                %around to avoid this, e.g. a trade was open on the
                %previous bar but close on this bar
                try
                    istrendconfirmed = signal_i.status.istrendconfirmed;
                catch
                    istrendconfirmed = false;
                end
                if ~istrendconfirmed
                    continue;
                end
                
                trade = fractal_gentrade2(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
                if ~isempty(trade)
                    if trade.opendirection_ == 1 && obj.hasLongPosition(code_i,freq_i)
                        continue;
                    end
                    if trade.opendirection_ == 1 && obj.hasLongPosition(code_i,freq_i,'status','closed','closedt',datestr(ei_i.px(end,1),'yyyy-mm-dd HH:MM:SS'))
                        continue;
                    end
                    if trade.opendirection_ == -1 && obj.hasShortPosition(code_i,freq_i)
                        continue;
                    end
                    if trade.opendirection_ == -1 && obj.hasShortPosition(code_i,freq_i,'status','closed','closedt',datestr(ei_i.px(end,1),'yyyy-mm-dd HH:MM:SS'))
                        continue;
                    end
                    unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
                        'usecandlelastonly',false,...
                        'debug',false,...
                        'updatepnlforclosedtrade',true,...
                        'extrainfo',ei_i,...
                        'RunRiskManagementBeforeMktClose',false,...
                        'KellyTables',data.kellytables_{i},...
                        'CompulsoryCheckForConditional',true);
                    if ~isempty(unwindtrade)
                        trade.status_ = 'closed';
                    end
                    obj.book_.push(trade);
                    if strcmpi(mode_i,'realtime')
                        exporttrade2mt4(trade,ei_i);
                    else
                        freq = trade.opensignal_.frequency_;
                        freqappendix = freq2mt4freq(freq);
                        opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                        fn = [getenv('OneDrive'),'\mt4\replay\',trade.code_,'.lmx_',freqappendix,'_trades_',opendtstr,'.txt'];
                        exporttrade2mt4(trade,ei_i,fn);
                    end
                end
            end
        else
            %conditional signal
            trade = fractal_gentrade2(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
            if ~isempty(trade)
                if trade.opendirection_ == 1 && obj.hasLongPosition(code_i,freq_i)
                    continue;
                end
                if trade.opendirection_ == 1 && obj.hasLongPosition(code_i,freq_i,'status','closed','closedt',datestr(ei_i.px(end,1),'yyyy-mm-dd HH:MM:SS'))
                    continue;
                end
                if trade.opendirection_ == -1 && obj.hasShortPosition(code_i,freq_i)
                    continue;
                end
                if trade.opendirection_ == -1 && obj.hasShortPosition(code_i,freq_i,'status','closed','closedt',datestr(ei_i.px(end,1),'yyyy-mm-dd HH:MM:SS'))
                    continue;
                end
                unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
                    'usecandlelastonly',false,...
                    'debug',false,...
                    'updatepnlforclosedtrade',true,...
                    'extrainfo',ei_i,...
                    'RunRiskManagementBeforeMktClose',false,...
                    'KellyTables',data.kellytables_{i},...
                    'CompulsoryCheckForConditional',true);
                if ~isempty(unwindtrade)
                    trade.status_ = 'closed';
                end
                obj.book_.push(trade);
                if strcmpi(mode_i,'realtime')
                    exporttrade2mt4(trade,ei_i);
                else
                    freq = trade.opensignal_.frequency_;
                    freqappendix = freq2mt4freq(freq);
                    opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                    fn = [getenv('OneDrive'),'\mt4\replay\',trade.code_,'.lmx_',freqappendix,'_trades_',opendtstr,'.txt'];
                    exporttrade2mt4(trade,ei_i,fn);
                end
            else
                pendingtrade = fractal_gentrade3_mt4(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
                if ~isempty(pendingtrade) 
                    if pendingtrade.opendirection_ == 2
                        if obj.hasLongPosition(code_i,freq_i)
                            continue;
                        else
                            [flag,existingtrade] = obj.hasLongPosition(code_i,freq_i,'direction',2,'status','unset');
                            if flag
                                if existingtrade.openprice_ == pendingtrade.openprice_
                                    continue;
                                else
                                    existingtrade.id_ = pendingtrade.id_;
                                    existingtrade.openprice_ = pendingtrade.openprice_;
                                    existingtrade.opensignal_ = pendingtrade.opensignal_;
                                    existingtrade.riskmanager_ = pendingtrade.riskmanager_;
                                    existingtrade.opendatetime1_ = pendingtrade.opendatetime1_;
                                    continue;
                                end
                            end
                        end
                        %
                    elseif pendingtrade.opendirection_ == -2 
                        if obj.hasShortPosition(code_i,freq_i)
                            continue;
                        else
                            [flag,existingtrade] = obj.hasShortPosition(code_i,freq_i,'direction',-2,'status','unset');
                            if flag
                                if existingtrade.openprice_ == pendingtrade.openprice_
                                    continue;
                                else
                                    existingtrade.id_ = pendingtrade.id_;
                                    existingtrade.openprice_ = pendingtrade.openprice_;
                                    existingtrade.opensignal_ = pendingtrade.opensignal_;
                                    existingtrade.riskmanager_ = pendingtrade.riskmanager_;
                                    existingtrade.opendatetime1_ = pendingtrade.opendatetime1_;
                                    continue;
                                end
                            end
                        end
                    end
                    %the conditional order can be placed even if a same
                    %directional trade was just unwinded
                    obj.pendingbook_.push(pendingtrade);
                    if strcmpi(mode_i,'realtime')
                        exporttrade2mt4(pendingtrade,ei_i);
                    else
                        freq = pendingtrade.opensignal_.frequency_;
                        freqappendix = freq2mt4freq(freq);
                        opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                        fn = [getenv('OneDrive'),'\mt4\replay\',pendingtrade.code_,'.lmx_',freqappendix,'_trades_',opendtstr,'.txt'];
                        exporttrade2mt4(pendingtrade,ei_i,fn);
                    end
                end
                %the pending trade shall be updated when new market data
                %arrived(shall be tick in reality)
            end
        end
    end
end