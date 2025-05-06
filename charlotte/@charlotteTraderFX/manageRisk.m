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
    for i = 1:nLive
        trade_i = liveTrades.node_(i);
        idxfound = 0;
        for j = 1:size(codes,1)
            if strcmpi(codes{j},trade_i.code_)
                idxfound = j;
                break
            end
        end
        if idxfound <= 0
            notify(obj,'ErrorOccurred',charlotteErrorEventData('internal error'));
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
           fprintf('trade closed at %4.2f with pnl:%4.2f\n',trade_i.closeprice_,trade_i.closepnl_);
       else
           if ~isempty(signals{idxfound})
               signal = signals{idxfound};
               if isempty(strfind(signal.opkellied,'conditional')) && isempty(strfind(signal.opkellied,'potential'))
                   if signal.directionkellied == 0 && (strcmpi(signal.op.comment,trade_i.opensignal_.mode_) || ...
                           (~strcmpi(signal.op.comment,trade_i.opensignal_.mode_) && ...
                           (signal.kelly < 0 || isnan(signal.kelly))))
                        trade_i.status_ = 'closed';
                        trade_i.riskmanager_.status_ = 'closed';
                        trade_i.riskmanager_.closestr_ = ['kelly is too low: ',num2str(signal.kelly)];
                        trade_i.runningpnl_ = 0;
                        trade_i.closeprice_ = ei{idxfound}.latestopen;
                        trade_i.closedatetime1_ = ei{idxfound}.latestdt;
                        fut = code2instrument(trade_i.code_);
                        trade_i.closepnl_ = trade_i.opendirection_*(trade_i.closeprice_-trade_i.openprice_) /fut.tick_size * fut.tick_value;
                   end
               end
           end
           
           if ~strcmpi(trade_i.status_,'closed')
               fprintf('stoploss:%4.4f\n',trade_i.riskmanager_.pxstoploss_);
           end
       end
        
    end
    
end