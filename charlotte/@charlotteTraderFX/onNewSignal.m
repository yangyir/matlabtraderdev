function [] = OnNewSignal(obj,~,eventData)
% a charlotteTraderFX function
    data = eventData.MarketData;
     
    mode_ = data.modes;
    n = size(data.signals,1);
    
    % GIVEN THE SIGNAL WE FIRST CREATE TRADES...
    for i = 1:n
        signal_i = data.signals{i};
        if isempty(signal_i)
            continue;
        end
        
        if ~data.newsignals(i)
            continue;
        end

        obj.signals_{i} = signal_i;
        
        % NOT SURE WE SHALL UPDATED HERE OR IN A SEPERATE CALLBACK FUNCTION
        % ARE THERE ANY DELAY?
        obj.ei_signal_{i} = data.extrainfo{i};
        
        code_i = signal_i.code;
        freq_i = signal_i.frequency;
        ei_i = data.extrainfo{i};
        
        nfractal = charlotte_freq2nfractal(freq_i);
        
        if strcmpi(freq_i,'m15')
            strat_i = obj.kellytables_m15_;
        elseif strcmpi(freq_i,'m30')
            strat_i = obj.kellytables_m30_;
        elseif strcmpi(freq_i,'h1')
            strat_i = obj.kellytables_h1_;
        elseif strcmpi(freq_i,'h4')
            strat_i = obj.kellytables_h4_;
        end
        
        if signal_i.type == 0
            %unconditional signal
            if signal_i.directionkellied == 1 && ~obj.hasLongPosition(code_i,freq_i)
                if ~signal_i.status.istrendconfirmed
                    % no conditional signal on the previous candle
                    if ~(strcmpi(signal_i.opkellied,'breachup-lvlup') || strcmpi(signal_i.opkellied,'breachup-sshighvalue')), continue;end
                    trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.opkellied,1,freq_i,nfractal);
                    trade.riskmanager_.setusefractalupdateflag(0);
                    trade.riskmanager_.setusefibonacciflag(1);
                    trade.opensignal_.kelly_ = signal_i.kelly;
                    unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
                        'usecandlelastonly',true,...
                        'debug',false,...
                        'updatepnlforclosedtrade',true,...
                        'extrainfo',ei_i,...
                        'RunRiskManagementBeforeMktClose',false,...
                        'KellyTables',strat_i,...
                        'CompulsoryCheckForConditional',true);
                    if ~isempty(unwindtrade)
                        trade.status_ = 'closed';
                    end
                    if strcmpi(freq_i,'h1')
                        tradeopendtstr = datestr(trade.opendatetime1_ + 1/24,'yyyy-mm-dd HH:MM');
                    elseif strcmpi(freq_i,'h4')
                        tradeopendtstr = datestr(trade.opendatetime1_ + 1/6,'yyyy-mm-dd HH:MM');
                    else
                        tradeopendtstr = 'not implemented yet';
                    end
                    fprintf('%10s:-->%s:trade:plc B market order at %7.3f...\n',[trade.code_,'-',upper(freq_i)],tradeopendtstr,trade.openprice_);
                    obj.book_.push(trade);
                    if strcmpi(mode_,'realtime')
                        exporttrade2mt4(trade,ei_i);
                    else
                        opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                        fn = [getenv('OneDrive'),'\mt4\replay\trade\',trade.code_,'.lmx_',upper(freq_i),'_trades_',opendtstr,'.txt'];
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
                    if ~(strcmpi(signal_i.opkellied,'breachdn-lvldn') || strcmpi(signal_i.opkellied,'breachdn-bshighvalue')), continue;end
                    trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.opkellied,-1,freq_i,nfractal);
                    trade.riskmanager_.setusefractalupdateflag(0);
                    trade.riskmanager_.setusefibonacciflag(1);
                    trade.opensignal_.kelly_ = signal_i.kelly;
                    unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
                        'usecandlelastonly',true,...
                        'debug',false,...
                        'updatepnlforclosedtrade',true,...
                        'extrainfo',ei_i,...
                        'RunRiskManagementBeforeMktClose',false,...
                        'KellyTables',strat_i,...
                        'CompulsoryCheckForConditional',true);
                    if ~isempty(unwindtrade)
                        trade.status_ = 'closed';
                    end
                     if strcmpi(freq_i,'h1')
                        tradeopendtstr = datestr(trade.opendatetime1_ + 1/24,'yyyy-mm-dd HH:MM');
                    elseif strcmpi(freq_i,'h4')
                        tradeopendtstr = datestr(trade.opendatetime1_ + 1/6,'yyyy-mm-dd HH:MM');
                    else
                        tradeopendtstr = 'not implemented yet';
                    end
                    fprintf('%10s:-->%s:trade:plc S market order at %7.3f...\n',[trade.code_,'-',upper(freq_i)],tradeopendtstr,trade.openprice_);
                    obj.book_.push(trade);
                    if strcmpi(mode_,'realtime')
                        exporttrade2mt4(trade,ei_i);
                    else
                        opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                        fn = [getenv('OneDrive'),'\mt4\replay\trade\',trade.code_,'.lmx_',upper(freq_i),'_trades_',opendtstr,'.txt'];
                        exporttrade2mt4(trade,ei_i,fn);
                    end
                else
                    continue;
                    %DISABLE THE FOLLOWING PART OF CODE FOR NOW
                    %MORE ROBUST TESTS REQUIRED
                    if signal_i.status.islvldnbreach
                        trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.op.comment,-1,freq_i,nfractal,0);
                        if ~isempty(trade)
                            trade.riskmanager_.setusefractalupdateflag(0);
                            trade.riskmanager_.setusefibonacciflag(1);
                            unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
                                'usecandlelastonly',true,...
                                'debug',false,...
                                'updatepnlforclosedtrade',true,...
                                'extrainfo',ei_i,...
                                'RunRiskManagementBeforeMktClose',false,...
                                'KellyTables',strat_i,...
                                'CompulsoryCheckForConditional',true);
                            if ~isempty(unwindtrade)
                                trade.status_ = 'closed';
                            end
                            obj.book_.push(trade);
                            if strcmpi(mode_,'realtime')
                                exporttrade2mt4(trade,ei_i);
                            else
                                opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                                fn = [getenv('OneDrive'),'\mt4\replay\trade\',trade.code_,'.lmx_',upper(freq_i),'_trades_',opendtstr,'.txt'];
                                exporttrade2mt4(trade,ei_i,fn);
                            end
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
                
                trade = fractal_gentrade2(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables);
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
                    fprintf('i hope this line will never reached...\n');
                    unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
                        'usecandlelastonly',false,...
                        'debug',false,...
                        'updatepnlforclosedtrade',true,...
                        'extrainfo',ei_i,...
                        'RunRiskManagementBeforeMktClose',false,...
                        'KellyTables',strat_i,...
                        'CompulsoryCheckForConditional',true);
                    if ~isempty(unwindtrade)
                        trade.status_ = 'closed';
                    end
                    obj.book_.push(trade);
                    if strcmpi(mode_,'realtime')
                        exporttrade2mt4(trade,ei_i);
                    else
                        opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
                        fn = [getenv('OneDrive'),'\mt4\replay\trade\',trade.code_,'.lmx_',freq_i,'_trades_',opendtstr,'.txt'];
                        exporttrade2mt4(trade,ei_i,fn);
                    end
                end
            end
        else
            % %unconditional signal
            % THIS IS PROCESSED SEPERATELY IN OTHER CALL BACK FUNCTIONS
        end
    end
    %
    %
    % GIVEN THE SIGNALS WE NEED TO RISK MANAGEMENT THE TRADES AS WELL
    for i = 1:obj.book_.latest_
        trade_i = obj.book_.node_(i);
        if strcmpi(trade_i.status_,'closed'), continue;end
        
        indexfound = -1;
        signal_i = [];
        ei_i= [];
        for j = 1:n
            if strcmpi(trade_i.code_, obj.signals_{j}.code) && ...
                    strcmpi(trade_i.opensignal_.frequency_,obj.signals_{j}.frequency)
                ei_i = obj.ei_signal_{j};
                signal_i = obj.signals_{j};
                indexfound = j;
                break
            end
        end
        
        if indexfound <= 0
            error('charlotteTraderFX:OnNewSignal:internal error')
        end
        
        if isempty(signal_i), continue;end
        
        if abs(signal_i.time - trade_i.opendatetime1_) < 1e-6, continue;end
        
        % HAS THE FOLLOWING PIECE OF CODE MOVED INTO riskmanagementwithcandle?
        % MAYBE NOT AND DOUBLE-CHECK
        if signal_i.type == 0 && signal_i.directionkellied == 0
            % unconditional signal
            if  (strcmpi(signal_i.op.comment,trade_i.opensignal_.mode_) || ...
                    (~strcmpi(signal_i.op.comment,trade_i.opensignal_.mode_) && ...
                    (signal_i.kelly < 0 || isnan(signal_i.kelly))))
                trade_i.status_ = 'closed';
                trade_i.riskmanager_.status_ = 'closed';
                trade_i.riskmanager_.closestr_ = ['kelly is too low: ',num2str(signal_i.kelly)];
                trade_i.runningpnl_ = 0;
                trade_i.closeprice_ = ei_i.px(end,5);
                trade_i.closedatetime1_ = ei_i.px(end,1);
                fut = code2instrument(trade_i.code_);
                trade_i.closepnl_ = trade_i.opendirection_*(trade_i.closeprice_-trade_i.openprice_) /fut.tick_size * fut.tick_value;
                
                closedtstr2display = datestr(trade_i.closedatetime1_ + 1/24,'yyyy-mm-dd HH:MM');
                if strcmpi(trade_i.code_,'XAUUSD')
                    fprintf('%10s-->%s:trade:unwind at %4.2f with pnl:%4.2f\n',[trade_i.code_,'-',upper(signal_i.frequency)],closedtstr2display,trade_i.closeprice_,trade_i.closepnl_);
                elseif strcmpi(trade_i.code_,'USDJPY')
                    fprintf('%10s-->%s:trade:unwind at %4.3f with pnl:%4.3f\n',[trade_i.code_,'-',upper(signal_i.frequency)],closedtstr2display,trade_i.closeprice_,trade_i.closepnl_);
                else
                    fprintf('%10s-->%s:trade:unwind at %4.5f with pnl:%4.5f\n',[trade_i.code_,'-',upper(signal_i.frequency)],closedtstr2display,trade_i.closeprice_,trade_i.closepnl_);
                end
            end
            %
        elseif signal_i.type == 1 && signal_i.directionkellied == 0
            % conditional signal
            if strcmpi(trade_i.opensignal_.mode_,'breachup-lvlup')
                samesignal = signal_i.flags.islvlupbreach;
            elseif strcmpi(trade_i.opensignal_.mode_,'breachup-sshighvalue')
                samesignal = signal_i.flags.issshighbreach;
            elseif strcmpi(trade_i.opensignal_.mode_,'breachup-highsc13')
                samesignal = signal_i.flags.isschighbreach;
            elseif strcmpi(trade_i.opensignal_.mode_,'breachdn-lvldn')
                samesignal = signal_i.flags.islvldnbreach;
            elseif strcmpi(trade_i.opensignal_.mode_,'breachdn-bshighvalue')
                samesignal = signal_i.flags.isbslowbreach;
            elseif strcmpi(trade_i.opensignal_.mode_,'breachdn-lowbc13')
                samesignal = signal_i.flags.isbclowbreach;
            elseif ~isempty(strfind(trade_i.opensignal_.mode_,'-trendconfirmed'))
                samesignal = 1;
            elseif ~isempty(strfind(trade_i.opensignal_.mode_,'-conditional'))
                %not yet implemented correctly
                samesignal = 1;
            else
                %other non-trended signal
                samesignal = 0;
            end
            if samesignal || (~samesignal && (signal_i.kelly < 0 || isnan(signal_i.kelly)))
                trade_i.status_ = 'closed';
                trade_i.riskmanager_.status_ = 'closed';
                trade_i.riskmanager_.closestr_ = ['conditional kelly is too low: ',num2str(signal_i.kelly)];
                trade_i.runningpnl_ = 0;
                trade_i.closeprice_ = ei_i.px(end,5);
                trade_i.closedatetime1_ = ei_i.px(end,1);
                fut = code2instrument(trade_i.code_);
                trade_i.closepnl_ = trade_i.opendirection_*(trade_i.closeprice_-trade_i.openprice_) /fut.tick_size * fut.tick_value;
                
                closedtstr2display = datestr(trade_i.closedatetime1_ + 1/24,'yyyy-mm-dd HH:MM');
                if strcmpi(trade_i.code_,'XAUUSD')
                    fprintf('%10s:-->%s:trade:unwind at %4.2f with pnl:%4.2f\n',[trade_i.code_,'-',upper(signal_i.frequency)],closedtstr2display,trade_i.closeprice_,trade_i.closepnl_);
                elseif strcmpi(trade_i.code_,'USDJPY')
                    fprintf('%10s:-->%s:trade:unwind at %4.3f with pnl:%4.3f\n',[trade_i.code_,'-',upper(signal_i.frequency)],closedtstr2display,trade_i.closeprice_,trade_i.closepnl_);
                else
                    fprintf('%10s:-->%s:trade:unwind at %4.5f with pnl:%4.5f\n',[trade_i.code_,'-',upper(signal_i.frequency)],closedtstr2display,trade_i.closeprice_,trade_i.closepnl_);
                end
                
            end
        end
        
        if ~strcmpi(trade_i.status_,'closed'), continue;end
        % ONLY EXPORT CLOSED TRADES
        if strcmpi(mode_,'realtime')
            exporttrade2mt4(trade_i,ei_i);
        else
            opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
            fn = [getenv('OneDrive'),'\mt4\replay\trade\',trade_i.code_,'.lmx_',upper(signal_i.frequency),'_trades_',opendtstr,'.txt'];
            exporttrade2mt4(trade_i,ei_i,fn);
        end
    end
    
end