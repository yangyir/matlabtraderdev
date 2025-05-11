function [] = onNewSignal(obj,~,eventData)
% a charlotteTraderFX function
    data = eventData.MarketData;
     
    n = size(data.signals_,1);
    for i = 1:n
        signal_i = data.signals_{i};
        if isempty(signal_i)
            continue;
        end
        
        code_i = data.codes_{i};
        ei_i = data.ei_{i};
        freq_i = data.freq_{i};
        nfractal = charlotte_freq2nfracal(freq_i);
        
        if isempty(strfind(signal_i.opkellied,'conditional')) && isempty(strfind(signal_i.opkellied,'potential')) && isempty(strfind(signal_i.opkellied,'not to place'))
            %unconditional signal
            if signal_i.directionkellied == 1 && ~obj.hasLongPosition(code_i)
                if ~signal_i.status.istrendconfirmed
                    % no conditional signal on the previous candle
                    trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.opkellied,1,freq_i,nfractal);
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
                    exporttrade2mt4(trade,ei_i);
                else
%                     trade = fractal_gentrade2(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
%                     if ~isempty(trade)
% %                         trade.opensignal_.mode_ = signal_i.opkellied;
%                         unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
%                             'usecandlelastonly',false,...
%                             'debug',false,...
%                             'updatepnlforclosedtrade',true,...
%                             'extrainfo',ei_i,...
%                             'RunRiskManagementBeforeMktClose',false,...
%                             'KellyTables',data.kellytables_{i},...
%                             'CompulsoryCheckForConditional',true);
%                         if ~isempty(unwindtrade)
%                             trade.status_ = 'closed';
%                         end
%                         obj.book_.push(trade);
%                         exporttrade2mt4(trade,ei_i);
%                     end
                end
            elseif signal_i.directionkellied == 1 && obj.hasLongPosition(code_i)
                %
            elseif signal_i.directionkellied == -1 && ~obj.hasShortPosition(code_i)
                if ~signal_i.status.istrendconfirmed
                    % no conditional signal on the previous candle
                    trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.opkellied,-1,freq_i,nfractal);
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
                    exporttrade2mt4(trade,ei_i);
                else
%                     trade = fractal_gentrade2(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
%                     if ~isempty(trade)
%                         %trade.opensignal_.mode_ = signal_i.opkellied;
%                         unwindtrade = trade.riskmanager_.riskmanagementwithcandle([],...
%                             'usecandlelastonly',false,...
%                             'debug',false,...
%                             'updatepnlforclosedtrade',true,...
%                             'extrainfo',ei_i,...
%                             'RunRiskManagementBeforeMktClose',false,...
%                             'KellyTables',data.kellytables_{i},...
%                             'CompulsoryCheckForConditional',true);
%                         if ~isempty(unwindtrade)
%                             trade.status_ = 'closed';
%                         end
%                         obj.book_.push(trade);
%                         exporttrade2mt4(trade,ei_i);
%                     end
                end
            elseif signal_i.directionkellied == -1 && obj.hasShortPosition(code_i)
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
                    if trade.opendirection_ == 1 && obj.hasLongPosition(code_i)
                        continue;
                    end
                    if trade.opendirection_ == 1 && obj.hasLongPosition(code_i,'status','closed','closedt',datestr(ei_i.px(end,1),'yyyy-mm-dd HH:MM:SS'))
                        continue;
                    end
                    if trade.opendirection_ == -1 && obj.hasShortPosition(code_i)
                        continue;
                    end
                    if trade.opendirection_ == -1 && obj.hasShortPosition(code_i,'status','closed','closedt',datestr(ei_i.px(end,1),'yyyy-mm-dd HH:MM:SS'))
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
                    exporttrade2mt4(trade,ei_i);
                end
            end
        else
            %conditional signal
            trade = fractal_gentrade2(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
            if ~isempty(trade)
                if trade.opendirection_ == 1 && obj.hasLongPosition(code_i)
                    continue;
                end
                if trade.opendirection_ == 1 && obj.hasLongPosition(code_i,'status','closed','closedt',datestr(ei_i.px(end,1),'yyyy-mm-dd HH:MM:SS'))
                    continue;
                end
                if trade.opendirection_ == -1 && obj.hasShortPosition(code_i)
                    continue;
                end
                if trade.opendirection_ == -1 && obj.hasShortPosition(code_i,'status','closed','closedt',datestr(ei_i.px(end,1),'yyyy-mm-dd HH:MM:SS'))
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
                exporttrade2mt4(trade,ei_i);
            else
                pendingtrade = fractal_gentrade3_mt4(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
                if ~isempty(pendingtrade) 
                    if pendingtrade.opendirection_ == 2 && (obj.hasLongPosition(code_i,'direction',2,'status','unset') || obj.hasLongPosition(code_i))
                        continue;
                    elseif pendingtrade.opendirection_ == -2 && (obj.hasShortPosition(code_i,'direction',-2,'status','unset') || obj.hasShortPosition(code_i))
                        continue;
                    end
                    obj.pendingbook_.push(pendingtrade);
                end
                %the pending trade shall be updated when new market data
                %arrived(shall be tick in reality)
            end
        end
    end
end