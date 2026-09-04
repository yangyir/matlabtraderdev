function [] = OnNewBar_H1(obj,~,eventData)
% a charlotteTraderFX method
    data = eventData.MarketData;
    n = size(data,1);
    ncodes = size(obj.codes_,1);
    
    % update ei_signal_ if needed
    mode_ = '';
    for i = 1:ncodes
        freq_i = obj.freqs_{i};
        
        if ~strcmpi(freq_i,'h1'), continue;end
        
        code_i = obj.codes_{i};
        for j = 1:n
            data_j = data{j};
            if strcmpi(data_j.freq,freq_i) && strcmpi(data_j.code,code_i)
                obj.ei_signal_{i} = data_j.extrainfo;
                mode_ = data_j.mode;
                break
            end
        end
    end
    %
    % riskmanagement
    % step1:add the set and still live special trade into book for further risk
    % management
    for i = 1:obj.specialbook_.latest_
        specialtrade_i = obj.specialbook_.node_(i);
        if ~strcmpi(specialtrade_i.opensignal_.frequency_,'h1'), continue;end
        if strcmpi(specialtrade_i.status_,'closed')
            % position closed during the special period of time
            % i.e. stop loss or target breach
            continue;
        elseif strcmpi(specialtrade_i.status_,'unset')
            % limit order has been filled, mark the status as closed
            specialtrade_i.status_ = 'closed';
            specialtrade_i.riskmanager_.status_ = 'closed';
            specialtrade_i.riskmanager_.closestr_ = 'limit order expired';
            closedtstr2display = datestr(specialtrade_i.opendatetime1_ + 2/24,'yyyy-mm-dd HH:MM');
            if specialtrade_i.opendirection_ > 0
                if strcmpi(specialtrade_i.code_,'XAUUSD')
                    fprintf('%10s:-->%s:trade:cxl B limit order at %7.2f...\n',[specialtrade_i.code_,'-H1'],closedtstr2display,specialtrade_i.openprice_);
                elseif strcmpi(specialtrade_i.code_,'USDJPY')
                    fprintf('%10s:-->%s:trade:cxl B limit order at %7.3f...\n',[specialtrade_i.code_,'-H1'],closedtstr2display,specialtrade_i.openprice_);
                else
                    fprintf('%10s:-->%s:trade:cxl B limit order at %7.5f...\n',[specialtrade_i.code_,'-H1'],closedtstr2display,specialtrade_i.openprice_);
                end
            else
                if strcmpi(specialtrade_i.code_,'XAUUSD')
                    fprintf('%10s:-->%s:trade:cxl S limit order at %7.2f...\n',[specialtrade_i.code_,'-H1'],closedtstr2display,specialtrade_i.openprice_);
                elseif strcmpi(specialtrade_i.code_,'USDJPY')
                    fprintf('%10s:-->%s:trade:cxl S limit order at %7.3f...\n',[specialtrade_i.code_,'-H1'],closedtstr2display,specialtrade_i.openprice_);
                else
                    fprintf('%10s:-->%s:trade:cxl S limit order at %7.5f...\n',[specialtrade_i.code_,'-H1'],closedtstr2display,specialtrade_i.openprice_);
                end
            end
        elseif strcmpi(specialtrade_i.status_,'set')
            %here a small trick is to modify the trade open time as the
            %latest bar date/time
            for j = 1:size(obj.codes_)
                if strcmpi(specialtrade_i.code_,obj.codes_{j}) && ...
                        strcmpi(obj.freqs_{j},'h1')
                    lastbartime = obj.ei_signal_{j}.px(end,1);
                    tradecopied = specialtrade_i.copy;
                    tradecopied.opendatetime1_ = lastbartime;
                    tradecopied.id_ = specialtrade_i.id_ + 1;
                    obj.book_.push(tradecopied);
                    if abs(lastbartime - specialtrade_i.opendatetime1_ - 1/24) > 1e-6
                        % this is around market close/open
                        % we shall first unwind this position if we opened
                        % it up by chance
                        tradecopied.status_ = 'closed';
                        tradecopied.riskmanager_.status_ = 'closed';
                        tradecopied.riskmanager_.closestr_ = 'big uncertainty around market open';
                        tradecopied.runningpnl_ = 0;
                        tradecopied.closeprice_ = obj.ei_signal_{j}.px(end,5);
                        tradecopied.closedatetime1_ = obj.ei_signal_{j}.px(end,1);
                        fut = code2instrument(tradecopied.code_);
                        tradecopied.closepnl_ = tradecopied.opendirection_*(tradecopied.closeprice_-tradecopied.openprice_) /fut.tick_size * fut.tick_value;
                        closedtstr2display = datestr(obj.ei_signal_{j}.px(end,1) + 1/24,'yyyy-mm-dd HH:MM');
                        if strcmpi(tradecopied.code_,'XAUUSD')
                            fprintf('%10s:-->%s:trade:unwind at %4.2f with pnl:%4.2f\n',[tradecopied.code_,'-H1'],closedtstr2display,tradecopied.closeprice_,tradecopied.closepnl_);
                        elseif strcmpi(tradecopied.code_,'USDJPY')
                            fprintf('%10s:-->%s:trade:unwind at %4.3f with pnl:%4.3f\n',[tradecopied.code_,'-H1'],closedtstr2display,tradecopied.closeprice_,tradecopied.closepnl_);
                        else
                            fprintf('%10s:-->%s:trade:unwind at %4.5f with pnl:%4.5f\n',[tradecopied.code_,'-H1'],closedtstr2display,tradecopied.closeprice_,tradecopied.closepnl_);
                        end
                    end
                    break
                end
            end
            % let'say goodbye to special trades, they are now completely
            % moved to the ORIGNAL book for riskmanagement on signal
            % frequency level
            specialtrade_i.status_ = 'closed';
            specialtrade_i.riskmanager_.status_ = 'closed';
            specialtrade_i.riskmanager_.closestr_ = 'passed for general riskmanagement';
            % as all the specialtrades within this signal time bucket are
            % set to closed, no further riskmanagement process will affect
            % them anymore
        end
    end
    
    % step2: ordinary risk management 
    for i = 1:obj.book_.latest_
        trade_i = obj.book_.node_(i);
        
        if strcmpi(trade_i.status_,'closed'), continue;end
        
        if ~strcmpi(trade_i.opensignal_.frequency_,'h1'), continue;end
        
        indexfound = -1;
        for j = 1:size(obj.codes_)
            if strcmpi(trade_i.code_,obj.codes_{j}) && ...
                    strcmpi(obj.freqs_{j},'h1')
                ei_i = obj.ei_signal_{j};
                indexfound = j;
                break
            end
        end
        
        if indexfound <= 0
            error('charlotteTraderFX:OnNewBar_H1:internal error')
        end
        
        unwindtrade = trade_i.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',ei_i,...
            'RunRiskManagementBeforeMktClose',false,...
            'KellyTables',obj.kellytables_h1_,...
            'CompulsoryCheckForConditional',true);
        
        if ~isempty(unwindtrade)
            unwindtrade.status_ = 'closed';
            unwindtrade.riskmanager_.status_ = 'closed';
            %note here:this shall be checked later in MT4 to make sure it
            %happens
            closedtstr2display = datestr(unwindtrade.closedatetime1_ + 1/24,'yyyy-mm-dd HH:MM');
            if strcmpi(trade_i.code_,'XAUUSD')
                fprintf('%10s:-->%s:trade:unwind at %4.2f with pnl:%4.2f\n',[trade_i.code_,'-H1'],closedtstr2display,trade_i.closeprice_,trade_i.closepnl_);
            elseif strcmpi(trade_i.code_,'USDJPY')
                fprintf('%10s:-->%s:trade:unwind at %4.3f with pnl:%4.3f\n',[trade_i.code_,'-H1'],closedtstr2display,trade_i.closeprice_,trade_i.closepnl_);
            else
                fprintf('%10s:-->%s:trade:unwind at %4.5f with pnl:%4.5f\n',[trade_i.code_,'-H1'],closedtstr2display,trade_i.closeprice_,trade_i.closepnl_);
            end    
        end
        
        if strcmpi(mode_,'realtime')
            exporttrade2mt4(trade,ei_i);
        else
            opendtstr = datestr(ei_i.px(end,1),'yyyymmdd');
            fn = [getenv('OneDrive'),'\mt4\replay\trade\',trade_i.code_,'.lmx_H1_trades_',opendtstr,'.txt'];
            exporttrade2mt4(trade_i,ei_i,fn);
        end
             
    end
    
    
end