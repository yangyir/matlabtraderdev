function [] = onNewSignal(obj,~,eventData)
% a charlotteTraderFX function
    data = eventData.MarketData;
     
    n = size(data.signals_,1);
    for i = 1:n
        if isempty(data.signals_{i}), continue;end
        
        code_i = data.codes_{i};
        signal_i = data.signals_{i};
        
        if signal_i.directionkellied == 0, continue;end
        
        ei_i = data.ei_{i};
        freq_i = data.freq_{i};
        nfractal = charlotte_freq2nfracal(freq_i);
        
        if isempty(strfind(signal_i.opkellied,'conditional'))
            %unconditional signal
            if signal_i.directionkellied == 1 && ~obj.hasLongPosition(code_i)
                if ~signal_i.status.istrendconfirmed
                    % no conditional signal on the previous candle
                    trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.opkellied,1,freq_i,nfractal);
                    obj.book_.push(trade);
                    % export csv file for MT4
                    
                else
                    trade = fractal_gentrade2(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
                    if ~isempty(trade)
                        trade.opensignal_.mode_ = signal_i.opkellied;
                        obj.book_.push(trade);
                    end
                end
            elseif signal_i.directionkellied == 1 && obj.hasLongPosition(code_i)
                %
            elseif signal_i.directionkellied == -1 && ~obj.hasShortPosition(code_i)
                if ~signal_i.status.istrendconfirmed
                    % no conditional signal on the previous candle
                    trade = fractal_gentrade(ei_i,code_i,size(ei_i.px,1),signal_i.opkellied,-1,freq_i,nfractal);
                    obj.book_.push(trade);
                else
                    trade = fractal_gentrade2(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
                    if ~isempty(trade)
                        trade.opensignal_.mode_ = signal_i.opkellied;
                        obj.book_.push(trade);
                    end
                end
            end
        else
            %conditional signal
            trade = fractal_gentrade2(ei_i,code_i,size(ei_i.px,1),freq_i,nfractal,data.kellytables_{i});
            if ~isempty(trade)
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
            end
        end
    end
end