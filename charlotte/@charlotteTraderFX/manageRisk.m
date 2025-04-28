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
           fprintf('stoploss:%4.2f\n',trade_i.riskmanager_.pxstoploss_);
       end
        
    end
    
end