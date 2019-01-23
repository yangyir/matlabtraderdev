function [tradeout] = bkfunc_checksingletrade(trade,candles,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('DoPlot',1,@isnumeric);
    p.addParameter('RiskManagement','OptionPlusWR',@ischar);
    p.addParameter('OptionPremiumRatio',1,@isnumeric);%ratio of the option premium as the stoploss
    p.addParameter('WRWidth',10,@isnumeric);%Williams Ratio Step
    p.addParameter('UseDefaultFlashStopLoss',1,@isnumeric);%use the maximum or minimum as the stop price
    p.addParameter('RiskTolerance',1000,@isnumeric);
    p.addParameter('Print',0,@isnumeric);%print intermediate results
    p.addParameter('StopRatio',0,@isnumeric);
    p.addParameter('Buffer',0,@isnumeric);
    p.parse(varargin{:});
    doplot = p.Results.DoPlot;
    riskmanagement = p.Results.RiskManagement;
    pratio = p.Results.OptionPremiumRatio;
    ww = p.Results.WRWidth;
    if ~(ww == 5 || ww == 10 || ww == 20 || ww == 25 || ww == 50)
        error('bkfunc_checksingletrade:invalid wrwidth input')
    end
    wrsteps = -100:ww:0;
    usedefaultflashsl = p.Results.UseDefaultFlashStopLoss;
    doprint = p.Results.Print;
    stopratio = p.Results.StopRatio;
    buffer = p.Results.Buffer;
%     risktolerance = p.Results.RiskTolerance;
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
    %
    tradeout = trade.copy;
    instrument = trade.instrument_;
    highesthigh = trade.opensignal_.highesthigh_;
    lowestlow = trade.opensignal_.lowestlow_;
%     psteps = wrsteps*(highesthigh-lowestlow)/100+highesthigh;
    wropen = -100*(highesthigh-tradeout.openprice_)/(highesthigh-lowestlow);
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
        hold on;
        if trade.opendirection_ == 1
            plot(idx_shift+1,wropen,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
        else
            plot(idx_shift+1,wropen,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
        end
        title('williams');
        grid on;hold off;
    end
    
    %% risk management
    
    if strcmpi(riskmanagement,'OptionPlusWR')
        if strcmpi(tradeout.opensignal_.wrmode_,'flash') && usedefaultflashsl
            if tradeout.opendirection_ == 1
                pstoploss = tradeout.opensignal_.lowestlow_;
            else
                pstoploss = tradeout.opensignal_.highesthigh_;
            end
        else
            px = candles(idx_open-idx_shift:idx_open-1,5);
            ret = log(px(2:end)./px(1:end-1));
            vol = sqrt(nperiod-1)*std(ret);
            %stoploss calculated with option price
            stoploss = blkprice(1,1,0,1,vol)*pratio;
            pstoploss = trade.openprice_ - trade.opendirection_*stoploss*trade.openprice_;
            if tradeout.opendirection_ == 1
                pstoploss = ceil(pstoploss/instrument.tick_size)*instrument.tick_size;
            else
                pstoploss = floor(pstoploss/instrument.tick_size)*instrument.tick_size;
            end
        end
        %
        if tradeout.opendirection_ == 1   
            if strcmpi(tradeout.opensignal_.wrmode_,'flash')  || strcmpi(tradeout.opensignal_.wrmode_,'classic')
                %in case of flash, the open time is within any time of the
                %candle, we take the previous max/min's associated wr
                criticalvalue1 = -100;
%                 criticalvalue2 = criticalvalue1 + ww;
                criticalvalue2 = wrsteps(2);
                wr1 = -100;
                wr2 = wropen;
%                 pvalue1 = psteps(1);
%                 pvalue2 = psteps(2);
            else
                error('bkfunc_checksingletrade:not supported wrmode')
            end
        else
            if strcmpi(tradeout.opensignal_.wrmode_,'flash')  || strcmpi(tradeout.opensignal_.wrmode_,'classic')
                criticalvalue1 = -0;
                criticalvalue2 = wrsteps(end-1);
%                 criticalvalue2 = criticalvalue1 - ww;
%                 pvalue1 = psteps(end);
%                 pvalue2 = psteps(end-1);
                wr1 = 0;
                wr2 = wropen;
            else
                error('bkfunc_checksingletrade:not supported wrmode')
            end
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
            popen = candles(i,2);
            pclose = candles(i,5);
            wr = wlpr(i);
%             if doprint, fprintf('%s:close:%s\twr:%s\n',datestr(candles(i,1)),num2str(pclose),num2str(wr));end
            %1.close out the trade once the stoploss is breached
            if (plow < pstoploss && tradeout.opendirection_ == 1) || ...
               (phigh > pstoploss && tradeout.opendirection_ == -1 )     
                closeflag = 1;
            else
                closeflag = 0;
            end
            if closeflag
                if tradeout.opendirection_ == 1 && popen < pstoploss
                    tradeout.closeprice_ = popen;
                    closetime = candles(i,1)+1/86400;%make close on the candle open
                elseif tradeout.opendirection_ == -1  && popen > pstoploss
                    tradeout.closeprice_ = popen;
                    closetime = candles(i,1)+1/86400;%make close on the candle open
                else
                    tradeout.closeprice_ = pstoploss;
                    freq = str2double(tradeout.opensignal_.frequency_(1:end-1));
                    closetime = candles(i,1)+freq/1440;%make close on the candle close
                end
                tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
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
            % note:wr is calculated with the close price which shall be
            % known after the trade open
            pmax = max(candles(i-nperiod+1:i,3));
            pmin = min(candles(i-nperiod+1:i,4));
            
            if breachcriticalline == 0
                if tradeout.opendirection_ == 1
                    if wr > criticalvalue2 -buffer                       
                        if doprint, fprintf('breach critical line:%2.0f\n',criticalvalue2);end
                        if wr > -50 && ~breachcriticalline
                            breachcriticalline = 1;
                        end
                        wr_idx = find(wrsteps > criticalvalue2,1,'first');
                        criticalvalue1 = criticalvalue2;
                        criticalvalue2 = wrsteps(wr_idx);
                        if ~breachcriticalline
                            criticalvalue1 = -100 + 0.5*(criticalvalue2+100);
                        end
                    end
                elseif tradeout.opendirection_ == -1
                    if wr < criticalvalue2 +buffer
                        if doprint, fprintf('breach critical line:%2.0f\n',criticalvalue2);end
                        if wr < -50 && ~breachcriticalline
                            breachcriticalline = 1;
                        end
                        wr_idx = find(wrsteps < criticalvalue2,1,'last');
                        criticalvalue1 = criticalvalue2;
                        criticalvalue2 = wrsteps(wr_idx);
                        if ~breachcriticalline
                            criticalvalue1 = 0.5*criticalvalue2;
                        end
                    end
                end
            else
                %we have breach the critical 50 line already
                if tradeout.opendirection_ == 1
                    if wr > criticalvalue2 -buffer
                        if doprint, fprintf('breach critical line:%2.0f\n',criticalvalue2);end
                        breachcriticalline = 1;
                        wr_idx = find(wrsteps > criticalvalue2,1,'first');
                        criticalvalue1 = criticalvalue2;
                        criticalvalue2 = wrsteps(wr_idx);
                    end
                elseif tradeout.opendirection_ == -1
                    if wr < criticalvalue2 +buffer
                        if doprint, fprintf('breach critical line:%2.0f\n',criticalvalue2);end
                        breachcriticalline = 1;
                        wr_idx = find(wrsteps < criticalvalue2,1,'last');
                        criticalvalue1 = criticalvalue2;
                        criticalvalue2 = wrsteps(wr_idx);
                    end
                end

            end
            %
            if tradeout.opendirection_ == 1 && wr < criticalvalue1 - stopratio*(criticalvalue2-criticalvalue1)
                closeflag = 1;
                if doprint, fprintf('close wr:%2.1f\n',wr);end
            elseif tradeout.opendirection_ == -1 && wr > criticalvalue1 + stopratio*(criticalvalue2-criticalvalue1)
                closeflag = 1;
                if doprint, fprintf('close wr:%2.1f\n',wr);end
            end
            %
            if closeflag
                freq = str2double(tradeout.opensignal_.frequency_(1:end-1));
                %close with the next candle's open price
                try
                    tradeout.closeprice_ = candles(i+1,2);
                    closetime = candles(i+1,1)+freq/1440;
                catch
                    tradeout.closeprice_ = candles(i,5);
                    closetime = candles(i,1)+freq/1440;
                end
                tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
                
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
                freq = str2double(tradeout.opensignal_.frequency_(1:end-1));
                closetime = candles(i+1,1)+freq/1440;
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