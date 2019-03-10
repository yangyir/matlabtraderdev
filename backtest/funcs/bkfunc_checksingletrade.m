function [tradeout,pstoploss] = bkfunc_checksingletrade(trade,candles,varargin)
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
    p.addParameter('Lead',[],@isnumeric);
    p.addParameter('Lag',[],@isnumeric);
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
    lead = p.Results.Lead;
    lag = p.Results.Lag;
    wlpr = willpctr(candles(:,3),candles(:,4),candles(:,5),nperiod);
    if ~isempty(lead) && ~isempty(lag)
        [shortwr,longwr] = movavg(wlpr,lead,lag,'e');
    else
        shortwr = [];
        longwr = [];
    end
    
    idx = trade.opendatetime1_ > candles(1:end-1,1) & trade.opendatetime1_ < candles(2:end,1);
    if isempty(candles(idx,1))
        idx_open = size(candles,1);
    else
        idx_open = find(candles(:,1) == candles(idx,1));
    end
    %
    tradeout = trade.copy;
    instrument = trade.instrument_;
    wropenref = wlpr(idx_open-1);
   
    % risk management
    
    if strcmpi(riskmanagement,'OptionPlusWR')
        if strcmpi(tradeout.opensignal_.wrmode_,'flash') && usedefaultflashsl
            if tradeout.opendirection_ == 1
                pstoploss = tradeout.opensignal_.lowestlow_;
            else
                pstoploss = tradeout.opensignal_.highesthigh_;
            end
        else
            px = candles(idx_open-nperiod:idx_open-1,5);
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
            if strcmpi(tradeout.opensignal_.wrmode_,'flash')  ||...
                    strcmpi(tradeout.opensignal_.wrmode_,'classic') ||...
                    strcmpi(tradeout.opensignal_.wrmode_,'flashma')
                %in case of flash, the open time is within any time of the
                %candle, we take the previous max/min's associated wr
                criticalvalue1 = -100;
                criticalvalue2 = wrsteps(2);
                if doprint, fprintf('reset critical line at:%2.0f\n',criticalvalue2);end
            else
                error('bkfunc_checksingletrade:not supported wrmode')
            end
        else
            if strcmpi(tradeout.opensignal_.wrmode_,'flash')  ||...
                    strcmpi(tradeout.opensignal_.wrmode_,'classic') ||...
                    strcmpi(tradeout.opensignal_.wrmode_,'flashma')
                criticalvalue1 = -0;
                criticalvalue2 = wrsteps(end-1);
                if doprint, fprintf('reset critical line at:%2.0f\n',criticalvalue2);end
            else
                error('bkfunc_checksingletrade:not supported wrmode')
            end
        end
        
        breachmidline = 0;
        breachlimitline = 0;
        for i = idx_open:size(candles,1)
            plow = candles(i,4);
            phigh = candles(i,3);
            popen = candles(i,2);
%             pclose = candles(i,5);
            wr = wlpr(i);
            %1.close out the trade once the stoploss is breached
            if (plow < pstoploss && tradeout.opendirection_ == 1) || ...
               (phigh > pstoploss && tradeout.opendirection_ == -1 )     
                closeflag = 1;
            else
                closeflag = 0;
            end
            if closeflag
                if doprint, fprintf('stoploss breaches...\n');end
                if tradeout.opendirection_ == 1 && popen < pstoploss
                    tradeout.closeprice_ = popen;
                    closetime = candles(i,1);%make close on the candle open
                elseif tradeout.opendirection_ == -1  && popen > pstoploss
                    tradeout.closeprice_ = popen;
                    closetime = candles(i,1);
                else
                    tradeout.closeprice_ = pstoploss;
                    closetime = candles(i,1);%make close on the candle close
                end
                tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
                tradeout.closedatetime1_ = closetime;
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
            
            if breachmidline == 0
                if tradeout.opendirection_ == 1
                    if wr > criticalvalue2 + buffer                       
                        
                        if wr > -50 && ~breachmidline
                            breachmidline = 1;
                        end
                        wr_idx = find(wrsteps < wr,1,'last');
                        wrcheck = wrsteps(wr_idx);
                        if wrcheck > criticalvalue2
                            criticalvalue1 = criticalvalue2;
                            criticalvalue2 = wrsteps(wr_idx);
                            if doprint, fprintf('reset critical line at:%2.0f\n',criticalvalue2);end
                        end
                        if ~breachmidline
                            criticalvalue1 = -100 + 0.5*(criticalvalue2+100);
                        end
                    end
                elseif tradeout.opendirection_ == -1
                    if wr < criticalvalue2 - buffer
                        
                        if wr < -50 && ~breachmidline
                            breachmidline = 1;
                        end
                        wr_idx = find(wrsteps > wr,1,'first');
                        wrcheck = wrsteps(wr_idx);
                        if wrcheck < criticalvalue2
                            criticalvalue1 = criticalvalue2;
                            criticalvalue2 = wrcheck;
                            if doprint, fprintf('reset critical line at:%2.0f\n',criticalvalue2);end
                        end
                        if ~breachmidline
                            criticalvalue1 = 0.5*criticalvalue2;
                        end
                    end
                end
            else
                %we have breach the critical 50 line already
                if tradeout.opendirection_ == 1
                    if wr > criticalvalue2 + buffer
                        wr_idx = find(wrsteps < wr,1,'last');
                        wrcheck = wrsteps(wr_idx);
                        if wrcheck > criticalvalue2
                            criticalvalue2 = wrcheck;
                            if doprint, fprintf('reset critical line at:%2.0f\n',criticalvalue2);end
%                             if wr < -25
                                criticalvalue1 = -75 + (criticalvalue2+75)/2;
%                             else
%                                 criticalvalue1 = -50 + (criticalvalue2+50)/2;
%                             end
                        end
                    end
                elseif tradeout.opendirection_ == -1
                    if wr < criticalvalue2 - buffer
                        wr_idx = find(wrsteps > wr,1,'first');
                        wrcheck = wrsteps(wr_idx);
                        if wrcheck < criticalvalue2
                            criticalvalue2 = wrcheck;
                            if doprint, fprintf('reset critical line at:%2.0f\n',criticalvalue2);end
%                             if wr > -75
                                criticalvalue1 = -25 + (criticalvalue2+25)/2;
%                             else
%                                 criticalvalue1 = -50 + (criticalvalue2+50)/2;
%                             end
                        end
                    end
                end

            end
            %
            if tradeout.opendirection_ == 1 && wr < max(criticalvalue1 - stopratio*(criticalvalue2-criticalvalue1)-buffer,-100)
                closeflag = 1;
                if doprint, fprintf('close wr:%2.1f\n',wr);end
            elseif tradeout.opendirection_ == -1 && wr > min(criticalvalue1 + stopratio*(criticalvalue2-criticalvalue1)+buffer,0)
                closeflag = 1;
                if doprint, fprintf('close wr:%2.1f\n',wr);end
            end
            %
            if closeflag
                freq = str2double(tradeout.opensignal_.frequency_(1:end-1));
                %close with the next candle's open price
                try
                    tradeout.closeprice_ = candles(i+1,2);
                    closetime = candles(i+1,1);
                catch
                    tradeout.closeprice_ = candles(i,5);
                    closetime = candles(i,1)+freq/1440;
                end
                tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
                
                tradeout.closedatetime1_ = closetime;

                break
            end
            %
            % if wr reaches up/down limit, the trade is closed
            if tradeout.opendirection_ == 1 && abs(wr) <= instrument.tick_size/(pmax-pmin)
                breachlimitline = 1;
                if doprint, fprintf('hit wr:%2.1f\n',wr);end
%                 closeflag = 1;
            elseif tradeout.opendirection_ == -1 && abs(wr+100) <= instrument.tick_size/(pmax-pmin)
                breachlimitline = 1;
                if doprint, fprintf('hit wr:%2.1f\n',wr);end
%                 closeflag = 1;
            end
            if breachlimitline
                if tradeout.opendirection_ == 1 && wr < criticalvalue2 - buffer
                    closeflag = 1;
                    if doprint, fprintf('close wr:%2.1f\n',wr);end
                elseif tradeout.opendirection_ == -1 && wr > criticalvalue2 + buffer
                    closeflag = 1;
                    if doprint, fprintf('close wr:%2.1f\n',wr);end
                end
            end
            
            
            if closeflag
                tradeout.closeprice_ = candles(i+1,2);
                tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
%                 freq = str2double(tradeout.opensignal_.frequency_(1:end-1));
%                 closetime = candles(i+1,1)+freq/1440;
                closetime = candles(i+1,1);
                tradeout.closedatetime1_ = closetime;
                break
            end
            %
            % if the trade is not closed out yet, we close on the last
            % candle
            if i == size(candles,1) && ~closeflag
                tradeout.closeprice_ = candles(i,5);
                tradeout.closepnl_ = (tradeout.closeprice_-tradeout.openprice_)*tradeout.opendirection_/instrument.tick_size*instrument.tick_value;
                tradeout.closedatetime1_ = candles(i,1);
                break
            end
        end
        
        if doplot
            obs_period = nperiod;
            stop_period = nperiod;
            idx_shift = obs_period;
            idx_close = find(candles(:,1) == tradeout.closedatetime1_);
            idx_stop = idx_close + stop_period;
            idx_stop = min(idx_stop,size(candles,1));
            stop_period = idx_stop-idx_open;
        
            figure(1)
            subplot(211)
            candle(candles(idx_open-idx_shift:idx_stop,3),candles(idx_open-idx_shift:idx_stop,4),candles(idx_open-idx_shift:idx_stop,5),candles(idx_open-idx_shift:idx_stop,2),'b');
            hold on;
            if trade.opendirection_ == 1
                plot(idx_shift+1,trade.openprice_,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
                plot(idx_close-idx_open+idx_shift+1,tradeout.closeprice_,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
            else
                plot(idx_shift+1,trade.openprice_,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
                plot(idx_close-idx_open+idx_shift+1,tradeout.closeprice_,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
            end
            plot(idx_shift+1:idx_shift+stop_period+1,trade.openprice_*ones(stop_period+1,1),'g:')
            plot(idx_shift+1:idx_shift+stop_period+1,pstoploss*ones(stop_period+1,1),'r:')
        
            if trade.opendirection_ == 1
                dirstr = 'long';
            else
                dirstr = 'short';
            end
            titlestr = sprintf('%s:%s trade open at %s on %s...\n',trade.code_,dirstr,num2str(trade.openprice_),...
                trade.opendatetime2_);
            title(titlestr);
            hold off;
            %
            subplot(212)
            plot(wlpr(idx_open-idx_shift:idx_stop),'b');
            hold on;
            if ~isempty(shortwr) && ~isempty(longwr)
                plot(shortwr(idx_open-idx_shift:idx_stop),'r');
                plot(longwr(idx_open-idx_shift:idx_stop),'g');
            end
            
            if trade.opendirection_ == 1
                %use the previous close wr as the reference
                plot(idx_shift,wropenref,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
                plot(idx_close-idx_open+idx_shift+1,wr,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
            else
                plot(idx_shift,wropenref,'marker','o','color','g','markersize',3,'linewidth',3,'markerfacecolor','g');
                plot(idx_close-idx_open+idx_shift+1,wr,'marker','o','color','r','markersize',3,'linewidth',3,'markerfacecolor','r');
            end
            title('williams');
            grid on;hold off;
        end
                
        return
    end
    
    
    
    
end