function [tradeout] = bkfunc_checksingletrade(trade,candles,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('DoPlot',1,@isnumeric);
    p.addParameter('RiskManagement','OptionPlusWR',@ischar);
    p.addParameter('OptionPremiumRatio',1,@isnumeric);
    p.parse(varargin{:});
    doplot = p.Results.DoPlot;
    riskmanagement = p.Results.RiskManagement;
    pratio = p.Results.OptionPremiumRatio;
    nperiod = trade.opensignal_.lengthofperiod_;
    wlpr = willpctr(candles(:,3),candles(:,4),candles(:,5),nperiod);
    
    %% plot figure
    idx = trade.opendatetime1_ > candles(1:end-1,1) & trade.opendatetime1_ < candles(2:end,1);
    if isempty(candles(idx,1))
        idx_open = size(candles,1);
    else
        idx_open = find(candles(:,1) == candles(idx,1));
    end
    obs_period = nperiod;
    stop_period = nperiod;
    idx_stop = idx_open + stop_period;
    idx_stop = min(idx_stop,size(candles,1));
    stop_period = idx_stop-idx_open;
    idx_shift = obs_period;
%     close all;
    if doplot
        figure(1)
        subplot(211)
        candle(candles(idx_open-idx_shift:idx_stop,3),candles(idx_open-idx_shift:idx_stop,4),candles(idx_open-idx_shift:idx_stop,5),candles(idx_open-idx_shift:idx_stop,2),'b');
        hold on;
        if trade.opendirection_ == 1
            plot(idx_shift+1,trade.openprice_,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
        else
            plot(idx_shift+1,trade.openprice_,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
        end
        plot(idx_shift+1:idx_shift+stop_period+1,trade.openprice_*ones(stop_period+1,1),'g:')

        if trade.opendirection_ == 1
            dirstr = 'long';
        else
            dirstr = 'short';
        end
        titlestr = sprintf('%s:%s trade open at %s on %s...\n',trade.code_,dirstr,num2str(trade.openprice_),...
            trade.opendatetime2_);
        title(titlestr);
        hold off;
        subplot(212)
        plot(wlpr(idx_open-idx_shift:idx_stop),'b');
        title('williams');
        grid on;hold off;
    end
    
    %% risk management
    
    tradeout = trade.copy;
    instrument = code2instrument(trade.code_);
    if strcmpi(riskmanagement,'OptionPlusWR')
        px = candles(idx_open-idx_shift:idx_open-1,5);
        ret = log(px(2:end)./px(1:end-1));
        vol = sqrt(nperiod-1)*std(ret);
        %stoploss calculated with option price
        stoploss = blkprice(1,1,0,1,vol)*pratio;
        pstoploss = trade.openprice_ - trade.opendirection_*stoploss*trade.openprice_;
        if tradeout.opendirection_ == 1
            pstoploss = ceil(pstoploss/instrument.tick_size)*instrument.tick_size;
            criticalvalue1 = -100;
            criticalvalue2 = -90;
        else
            pstoploss = floor(pstoploss/instrument.tick_size)*instrument.tick_size;
            criticalvalue1 = -0;
            criticalvalue2 = -10;
        end
        if doplot
            subplot(211);
            hold on;
            plot(idx_shift+1:idx_shift+stop_period+1,pstoploss*ones(stop_period+1,1),'r:')
            hold off;
        end
        
        
        breachcriticalline = 0;
        for i = idx_open:size(candles,1)
            plow = candles(i,4);
            phigh = candles(i,3);
            %1.close out the trade once the stoploss is breached
            if (plow < pstoploss && tradeout.opendirection_ == 1) || ...
               (phigh > pstoploss && tradeout.opendirection_ == -1 )     
                closeflag = 1;
            else
                closeflag = 0;
            end
            if closeflag
                tradeout.closeprice_ = pstoploss;
                tradeout.closepnl_ = (pstoploss-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
                closetime = candles(i,1)+1/86400;
                tradeout.closedatetime1_ = closetime;
                if doplot
                    subplot(211);
                    hold on;
                    if trade.opendirection_ == 1
                        plot(i+1-idx_open+idx_shift,tradeout.closeprice_,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
                    else
                        plot(i+1-idx_open+idx_shift,tradeout.closeprice_,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
                    end
                    hold off;
                end
                break
            end
            %
            % if wr has breached the critical line and rebounce back, the trade
            % is closed. if it breached the critical line, we make the next
            % critical line
            wr = wlpr(i);
            pmax = max(candles(i-nperiod+1:i,3));
            pmin = min(candles(i-nperiod+1:i,4));
            if breachcriticalline == 0
                if tradeout.opendirection_ == 1
                    if wr > criticalvalue2
%                         fprintf('breach critical line:%2.0f\n',criticalvalue2);
                        breachcriticalline = 1;
                        criticalvalue1 = criticalvalue2;
                        criticalvalue2 = min(criticalvalue2 + 10,0);
                    end
                elseif tradeout.opendirection_ == -1
                    if wr < criticalvalue2
%                         fprintf('breach critical line:%2.0f\n',criticalvalue2);
                        breachcriticalline = 1;
                        criticalvalue1 = criticalvalue2;
                        criticalvalue2 = max(criticalvalue2 - 10,-100);
                        
                    end
                end
            else
                %we have breach the critical line already
                if tradeout.opendirection_ == 1
                    if wr > criticalvalue2
%                         fprintf('breach critical line:%2.0f\n',criticalvalue2);
                        breachcriticalline = 1;
                        criticalvalue1 = criticalvalue2;
                        criticalvalue2 = min(criticalvalue2 + 10,0);
                    end
                elseif tradeout.opendirection_ == -1
                    if wr < criticalvalue2
%                         fprintf('breach critical line:%2.0f\n',criticalvalue2);
                        breachcriticalline = 1;
                        criticalvalue1 = criticalvalue2;
                        criticalvalue2 = max(criticalvalue2 - 10,-100);
                    end
                end
                if tradeout.opendirection_ == 1 && wr < criticalvalue1 + (criticalvalue1 - criticalvalue2)*0.5
                    closeflag = 1;
%                     fprintf('close wr:%2.1f\n',wr);
                elseif tradeout.opendirection_ == -1 && wr > criticalvalue1 - (criticalvalue2 -criticalvalue1)*0.5
                    closeflag = 1;
%                     fprintf('close wr:%2.1f\n',wr);
                end
            end
            if closeflag
                %close with the next candle's open price
                tradeout.closeprice_ = candles(i+1,2);
                tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
                closetime = candles(i+1,1)+1/86400;
                tradeout.closedatetime1_ = closetime;
                if doplot
                    subplot(211);
                    hold on;
                    if trade.opendirection_ == 1
                        plot(i+1-idx_open+idx_shift,tradeout.closeprice_,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
                    else
                        plot(i+1-idx_open+idx_shift,tradeout.closeprice_,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
                    end
                    hold off;
                end
                break
            end
            %
            % if wr reaches up/down limit, the trade is closed
            if tradeout.opendirection_ == 1 && abs(wr) <= instrument.tick_size/(pmax-pmin)
                closeflag = 1;
            elseif tradeout.opendirection_ == -1 && abs(wr+100) <= instrument.tick_size/(pmax-pmin)
                closeflag = 1;
            end
            if closeflag
                tradeout.closeprice_ = candles(i+1,2);
                tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
                closetime = candles(i+1,1)+1/86400;
                tradeout.closedatetime1_ = closetime;
                if doplot
                    subplot(211);
                    hold on;
                    if trade.opendirection_ == 1
                        plot(i+1-idx_open+idx_shift,tradeout.closeprice_,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
                    else
                        plot(i+1-idx_open+idx_shift,tradeout.closeprice_,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
                    end
                    hold off;
                end
                break
            end
            %
            % if the trade is not closed out yet, we close on the last
            % candle
            if i == size(candles,1) && ~closeflag
                tradeout.closeprice_ = candles(i,5);
                tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
                tradeout.closedatetime1_ = candles(i,1);
                if doplot
                    subplot(211);
                    hold on;
                    if trade.opendirection_ == 1
                        plot(i+1-idx_open+idx_shift,tradeout.closeprice_,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
                    else
                        plot(i+1-idx_open+idx_shift,tradeout.closeprice_,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
                    end
                    hold off;
                end
                break
            end
        end
        
        return
    end
    
    
end