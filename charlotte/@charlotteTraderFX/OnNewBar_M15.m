function [] = OnNewBar_M15(obj,~,eventData)
% a charlotteTraderFX method
    data = eventData.MarketData;
    n = size(data,1);
    ncodes = size(obj.codes_,1);
    
     % update ei_signal_ if needed
    for i = 1:ncodes
        freq_i = obj.freqs_{i};
        
        if ~strcmpi(freq_i,'m15'), continue;end
        
        code_i = obj.codes_{i};
        for j = 1:n
            data_j = data{j};
            if strcmpi(data_j.freq,freq_i) && strcmpi(data_j.code,code_i)
                obj.ei_signal_{i} = data_j.extrainfo;
                break
            end
        end
    end
    
    % if a valid signal exists
    % frequency M15 is associated with signal frequency of H1 only
    for i = 1:ncodes
        if isempty(obj.signals_{i}), continue; end
        if ~strcmpi(obj.signals_{i}.frequency,'H1'),continue;end
        if obj.signals_{i}.type == 0, continue;end     % no need to run for unconditional 
        if obj.signals_{i}.directionkellied == 0, continue;end
        
        signal_i = obj.signals_{i};
        code_i = signal_i.code;
        
        eispecial_i = [];
        mode_i = '';
        for j = 1:n
            if strcmpi(data{j}.code,code_i)
                eispecial_i = data{j}.extrainfo;
                mode_i = data{j}.mode;
                break;
            end
        end
        if isempty(eispecial_i), continue;end
        
        eisignal_i = obj.ei_signal_{i};
        
        lastspecialtime = datestr(eispecial_i.px(end,1)+1/96,'yyyy-mm-dd HH:MM');
        lastspecialclose = eispecial_i.px(end,5);
        
        % WE WILL INVESTIGATE THIS LATER ESPECIALLY ON THE LAST CANDLE
        mindiff = (eispecial_i.px(end,1)-eisignal_i.px(end,1))*1440; 
        if  mindiff <= 61
            nkpassed = 1;
        elseif mindiff <= 76
            nkpassed = 2;
        elseif mindiff <= 91
            nkpassed = 3;
        elseif mindiff <= 106
            nkpassed = 4;
        else
            fprintf('Trader:OnNewBar_M15:the code should never come here!!!!');
            continue;
        end
        
        specialBeforeLast = false;
        openOnLast = true;
        
        if signal_i.directionkellied == 1 && ~obj.hasLongPosition(code_i,signal_i.frequency)
            if lastspecialclose > signal_i.signalkellied(2) && ~obj.hasSpecialTrade(signal_i,eisignal_i)
                if nkpassed == 4 && openOnLast
                    trade = obj.genSpecialTrade(signal_i,eisignal_i,lastspecialclose,'market');
                else
                    trade = obj.genSpecialTrade(signal_i,eisignal_i,lastspecialclose,'limit');
                end
                % do nothing at this time point apart from placing an order
                if ~isempty(trade)
                    if strcmpi(code_i,'xauusd')
                        fprintf('%10s:-->%s:trade:plc B limit order at %7.2f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                    elseif strcmpi(code_i,'usdjpy')
                        fprintf('%10s:-->%s:trade:plc B limit order at %7.3f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                    else
                        fprintf('%10s:-->%s:trade:plc B limit order at %7.5f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                    end
                    
                    if nkpassed == 4  && openOnLast 
                        trade.status_ = 'set';
                        trade.riskmanager_.status_ = 'set';
                        trade.opendirection_ = 1;
                        if strcmpi(code_i,'xauusd')
                            fprintf('%10s:-->%s:trade:set B limit order at %7.2f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        elseif strcmpi(code_i,'usdjpy')
                            fprintf('%10s:-->%s:trade:set B limit order at %7.3f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        else
                            fprintf('%10s:-->%s:trade:set B limit order at %7.5f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        end
                    end
                    
                    if strcmpi(mode_i,'realtime')
                        exporttrade2mt4(trade,eisignal_i);
                    else
                        opendtstr = datestr(eisignal_i.px(end,1),'yyyymmdd');
                        fn = [getenv('OneDrive'),'\mt4\replay\trade\',trade.code_,'.lmx_H1_trades_',opendtstr,'.txt'];
                        exporttrade2mt4(trade,eisignal_i,fn);
                    end
                    continue;
                else
                    if specialBeforeLast && nkpassed == 3 && eispecial_i.px(end,5) > eispecial_i.px(end,2)
                    end
                end
            end
            
        elseif signal_i.directionkellied == -1 && ~obj.hasShortPosition(code_i,signal_i.frequency)
            if lastspecialclose < signal_i.signalkellied(3) && ~obj.hasSpecialTrade(signal_i,eisignal_i)
                if nkpassed == 4 && openOnLast
                    trade = obj.genSpecialTrade(signal_i,eisignal_i,lastspecialclose,'market');
                else
                    trade = obj.genSpecialTrade(signal_i,eisignal_i,lastspecialclose,'limit');
                end
                % do nothing at this time point apart from placing an order
                if ~isempty(trade)
                    if strcmpi(code_i,'xauusd')
                        fprintf('%10s:-->%s:trade:plc S limit order at %7.2f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                    elseif strcmpi(code_i,'usdjpy')
                        fprintf('%10s:-->%s:trade:plc S limit order at %7.3f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                    else
                        fprintf('%10s:-->%s:trade:plc S limit order at %7.5f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                    end
                    
                    if nkpassed == 4 && openOnLast
                        trade.status_ = 'set';
                        trade.riskmanager_.status_ = 'set';
                        trade.opendirection_ = -1;
                        if strcmpi(code_i,'xauusd')
                            fprintf('%10s:-->%s:trade:set S limit order at %7.2f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        elseif strcmpi(code_i,'usdjpy')
                            fprintf('%10s:-->%s:trade:set S limit order at %7.3f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        else
                            fprintf('%10s:-->%s:trade:set S limit order at %7.5f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        end
                    end
                    
                    if strcmpi(mode_i,'realtime')
                        exporttrade2mt4(trade,eisignal_i);
                    else
                        opendtstr = datestr(eisignal_i.px(end,1),'yyyymmdd');
                        fn = [getenv('OneDrive'),'\mt4\replay\trade\',trade.code_,'.lmx_H1_trades_',opendtstr,'.txt'];
                        exporttrade2mt4(trade,eisignal_i,fn);
                    end
                    continue;
                end
            else
                if specialBeforeLast && nkpassed == 3 && eispecial_i.px(end,5) < eispecial_i.px(end,2)
                    trade = obj.genSpecialTrade(signal_i,eisignal_i,lastspecialclose,'limit');%HERE IT IS A STOP ORDER OR WE WILL SEPERATE INTO 3 FIVE CANDLES?
                    
                end
            end
        end
        
        [~,trade] = obj.hasSpecialTrade(signal_i,eisignal_i);
        
        if ~isempty(trade)
            % we may conduct some naive risk management here as well
            %
            % 1.first check whether the trade has been set-up or not
            if strcmpi(trade.status_,'unset')
                if trade.opendirection_ > 0
                    if eispecial_i.px(end,4) < trade.openprice_
                        trade.status_ = 'set';
                        trade.riskmanager_.status_ = 'set';
                        trade.opendirection_ = 1;
                        if strcmpi(code_i,'xauusd')
                            fprintf('%10s:-->%s:trade:set B limit order at %7.2f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        elseif strcmpi(code_i,'usdjpy')
                            fprintf('%10s:-->%s:trade:set B limit order at %7.3f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        else
                            fprintf('%10s:-->%s:trade:set B limit order at %7.5f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        end
                    end
                else
                    if eispecial_i.px(end,3) > trade.openprice_
                        trade.status_ = 'set';
                        trade.riskmanager_.status_ = 'set';
                        trade.opendirection_ = -1;
                        if strcmpi(code_i,'xauusd')
                            fprintf('%10s:-->%s:trade:set S limit order at %7.2f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        elseif strcmpi(code_i,'usdjpy')
                            fprintf('%10s:-->%s:trade:set S limit order at %7.3f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        else
                            fprintf('%10s:-->%s:trade:set S limit order at %7.5f...\n',[code_i,'-H1'],lastspecialtime,trade.openprice_);
                        end
                    end
                end
            end
            % 2.second check whether stop loss has been hit
            if trade.opendirection_ > 0 && ~strcmpi(trade.status_,'closed')
                if eispecial_i.px(end,4) < trade.riskmanager_.pxstoploss_
                    trade.status_ = 'closed';
                    trade.riskmanager_.status_ = 'closed';
                end
            elseif trade.opendirection_ < 0 && ~strcmpi(trade.status_,'closed')
                if eispecial_i.px(end,3) > trade.riskmanager_.pxstoploss_
                    trade.status_ = 'closed';
                    trade.riskmanager_.status_ = 'closed';
                end
            end
        end
        
    end
end