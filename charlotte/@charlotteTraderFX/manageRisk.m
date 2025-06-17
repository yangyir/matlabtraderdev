function [] = manageRisk(obj,data)
% a charlotteTraderFX function
% input extrainfo is given in onNewSignal
    n = obj.book_.latest_;
    if n == 0, return; end
    
    nLive = 0;
    liveTrades = cTradeOpenArray;
    for i = 1:n
        trade_i = obj.book_.node_(i);
        if ~strcmpi(trade_i.status_,'closed')
            nLive = nLive + 1;
            liveTrades.push(trade_i);
        end
    end
    if nLive == 0, return; end
    
    codes = data.codes_;
    ei = data.ei_;
    kellytables = data.kellytables_;
    signals = data.signals_;
    newindicators = data.newindicators_;
    modes = data.modes_;
    for i = 1:nLive
        trade_i = liveTrades.node_(i);
        idxfound = 0;
        for j = 1:size(codes,1)
            if strcmpi(codes{j},[trade_i.code_,'-',trade_i.opensignal_.frequency_])
                idxfound = j;
                break
            end
        end
        if idxfound <= 0
            notify(obj,'ErrorOccurred',charlotteErrorEventData('internal error'));
        end
        
        if ~newindicators(idxfound)
            continue;
        end
        
        unwindtrade = trade_i.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',ei{idxfound},...
            'RunRiskManagementBeforeMktClose',false,...
            'KellyTables',kellytables{idxfound},...
            'CompulsoryCheckForConditional',true);
        if ~isempty(unwindtrade)
            unwindtrade.status_ = 'closed';
            %note here:this shall be checked later in MT4 to make sure it
            %happens
            if strcmpi(trade_i.code_,'XAUUSD')
                fprintf('trade closed at %4.2f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
            elseif strcmpi(trade_i.code_,'USDJPY')
                fprintf('trade closed at %4.3f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
            else
                fprintf('trade closed at %4.4f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
            end
        else
            if ~isempty(signals{idxfound})
                signal = signals{idxfound};
                if isempty(strfind(signal.opkellied,'conditional')) && isempty(strfind(signal.opkellied,'potential')) && isempty(strfind(signal.opkellied,'not to place'))
                    if signal.directionkellied == 0 && (strcmpi(signal.op.comment,trade_i.opensignal_.mode_) || ...
                            (~strcmpi(signal.op.comment,trade_i.opensignal_.mode_) && ...
                            (signal.kelly < 0 || isnan(signal.kelly))))
                        trade_i.status_ = 'closed';
                        trade_i.riskmanager_.status_ = 'closed';
                        trade_i.riskmanager_.closestr_ = ['kelly is too low: ',num2str(signal.kelly)];
                        trade_i.runningpnl_ = 0;
                        trade_i.closeprice_ = ei{idxfound}.px(end,5);
                        trade_i.closedatetime1_ = ei{idxfound}.px(end,1);
                        fut = code2instrument(trade_i.code_);
                        trade_i.closepnl_ = trade_i.opendirection_*(trade_i.closeprice_-trade_i.openprice_) /fut.tick_size * fut.tick_value;
                        
                        if strcmpi(trade_i.code_,'XAUUSD')
                            fprintf('trade closed at %4.2f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
                        elseif strcmpi(trade_i.code_,'USDJPY')
                            fprintf('trade closed at %4.3f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
                        else
                            fprintf('trade closed at %4.4f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
                        end
                        
                    end
                elseif ~isempty(strfind(signal.opkellied,'conditional')) || ~isempty(strfind(signal.opkellied,'potential')) || ~isempty(strfind(signal.opkellied,'not to place'))
                    if signal.directionkellied == 0
                        if strcmpi(trade_i.opensignal_.mode_,'breachup-lvlup')
                            samesignal = signal.flags.islvlupbreach;
                        elseif strcmpi(trade_i.opensignal_,'breachup-sshighvalue')
                            samesignal = signal.flags.issshighbreach;
                        elseif strcmpi(trade_i.opensignal_.mode_,'breachup-highsc13')
                            samesignal = signal.flags.isschighbreach;
                        elseif strcmpi(trade_i.opensignal_.mode_,'breachdn-lvldn')
                            samesignal = signal.flags.islvldnbreach;
                        elseif strcmpi(trade_i.opensignal_.mode_,'breachdn-bshighvalue')
                            samesignal = signal.flags.isbslowbreach;
                        elseif strcmpi(trade_i.opensignal_.mode_,'breachdn-lowbc13')
                            samesignal = signal.flags.isbclowbreach;
                        elseif ~isempty(strfind(trade_i.opensignal_.mode_,'-trendconfirmed'))
                            samesignal = 1;
                        elseif ~isempty(strfind(trade_i.opensignal_.mode_,'-conditional'))
                            %not yet implemented correctly
                            samesignal = 1;
                        else
                            %other non-trended signal
                            samesignal = 0;
                        end
                        if samesignal || (~samesignal && (signal.kelly < 0 || isnan(signal.kelly)))
                            trade_i.status_ = 'closed';
                            trade_i.riskmanager_.status_ = 'closed';
                            trade_i.riskmanager_.closestr_ = ['conditional kelly is too low: ',num2str(signal.kelly)];
                            trade_i.runningpnl_ = 0;
                            trade_i.closeprice_ = ei{idxfound}.px(end,5);
                            trade_i.closedatetime1_ = ei{idxfound}.px(end,1);
                            fut = code2instrument(trade_i.code_);
                            trade_i.closepnl_ = trade_i.opendirection_*(trade_i.closeprice_-trade_i.openprice_) /fut.tick_size * fut.tick_value;
                            
                            if strcmpi(trade_i.code_,'XAUUSD')
                                fprintf('trade closed at %4.2f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
                            elseif strcmpi(trade_i.code_,'USDJPY')
                                fprintf('trade closed at %4.3f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
                            else
                                fprintf('trade closed at %4.4f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
                            end
                            
                        end
                    end
                end
            end
            
            if ~strcmpi(trade_i.status_,'closed')
                fprintf('stoploss:%4.4f\n',trade_i.riskmanager_.pxstoploss_);
            end
            
        end
        %
        if strcmpi(modes{idxfound},'realtime')
            exporttrade2mt4(trade_i,ei{idxfound});
        else
            freq = trade_i.opensignal_.frequency_;
            freqappendix = freq2mt4freq(freq);
            opendtstr = datestr(ei{idxfound}.px(end,1),'yyyymmdd');
            fn = [getenv('OneDrive'),'\mt4\replay\',trade_i.code_,'.lmx_',freqappendix,'_trades_',opendtstr,'.txt'];
            exporttrade2mt4(trade_i,ei{idxfound},fn);
        end
        %
        %here is a tricky part, i.e. the trade_i is closed but there still
        %a (conditional) signal
        if strcmpi(trade_i.status_,'closed') && ~isempty(signals{idxfound})
            signal = signals{idxfound};
            if ~(~isempty(strfind(signal.opkellied,'conditional')) || ~isempty(strfind(signal.opkellied,'potential')))
                continue;
            end
            freq = trade_i.opensignal_.frequency_;
            nfractal = charlotte_freq2nfractal(freq);
            pendingtrade = fractal_gentrade3_mt4(ei{idxfound},trade_i.code_,size(ei{idxfound}.px,1),freq,nfractal,kellytables{idxfound});
            if isempty(pendingtrade)
                continue;
            end
            if pendingtrade.opendirection_ == 2 && (obj.hasLongPosition(trade_i.code_,freq) || obj.hasLongPosition(trade_i.code_,freq,'direction',2,'status','unset'))
                continue;
            elseif pendingtrade.opendirection_ == -2 && (obj.hasShortPosition(trade_i.code_,freq) || obj.hasShortPosition(trade_i.code_,freq,'direction',-2,'status','unset'))
                continue;
            end
            obj.pendingbook_.push(pendingtrade);
            if strcmpi(modes{idxfound},'realtime')
                exporttrade2mt4(pendingtrade,ei{idxfound});
            else
                freqappendix = freq2mt4freq(freq);
                opendtstr = datestr(ei{idxfound}.px(end,1),'yyyymmdd');
                fn = [getenv('OneDrive'),'\mt4\replay\',trade_i.code_,'.lmx_',freqappendix,'_trades_',opendtstr,'.txt'];
                exporttrade2mt4(pendingtrade,ei{idxfound},fn);
            end
        end
        
        
    end
    
end