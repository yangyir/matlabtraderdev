% written by sunq, updated on 2018/05/31, version 1
% bw_max = 1/2; bw_min =1/3;
% direction =1, long ;  direction = -1, short
% wr_batman_test_sunq，用于已经确认了开仓信号， 之后的止盈止损策略
% close是行情数据,开盘价open之后的行情
% open：开盘价;  target 和 stoploss是设置好的，可以是固定值，也可以是一个函数据算出的
% holdperiod :时间止损止盈点，之后强行平仓
%doublecheck : 1 是第一层循环， 2 是第二层循环， 3 是第三层循环
%如果在震荡区间没有即时开仓，但是后来出现趋势了，想跟趋势，开仓；则会浪的起始点和开仓点不相等的情况---
%这种情况下，open 是震荡区间的价格，假设为我们的开仓价； 实际的开仓价格是open_real，PnL是按照open_real计算的
%如果没有输入的open为空，表示开仓价和震荡的价格一致，默认 open = open_real
% written by sunq, updated on 2018/05/31, version 1
%增加了参数：stoplossMethod， stoplossMethod == 1: 收盘价止损；  stoplossMethod == 2...
%按照K线图止损，即最高价和最低价穿过止损线，就立刻按照止损价止损，而不用等收盘价的到来再止损

function [ profitLoss ] = w_r_batman_test_sunq(direction,close,high,low, open, open_real, target, stoploss, bw_max, bw_min, stoplossMethod)
    if stoplossMethod == 1
    % initalize paras
        nclose = size(close,1);  
        pxwithdrawmin(1) = -1;
        pxwithdrawmax(1) = -1;
        doublecheck = 0; 
        for i= 1:nclose
            lasttrade = close(i);
            %时间原因，强平
            if i==nclose
               profitLoss = (lasttrade - open_real) * direction;
               return 
            end
            % step 1
            if doublecheck == 1
                if direction == 1 
                    if lasttrade >= target
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh -(pxhigh - open) * bw_min;
                        pxwithdrawmax = pxhigh -(pxhigh - open) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade < target && lasttrade > stoploss
                        %do nothing and wait for the next  trade price
                    elseif lasttrade <= stoploss
                        profitLoss = lasttrade - open_real;
                        return
                    end
                elseif direction == -1
                    if lasttrade <= target
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh + (open - pxhigh) * bw_min;
                        pxwithdrawmax = pxhigh + (open - pxhigh) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade > target && lasttrade < stoploss
                        % do nothing and wait for the next trade price
                    elseif lasttrade >= stoploss
                        profitLoss = -lasttrade + open_real;
                        return
                    end
                else
                    error('w_r_batman_test_sunq：invalid direction of position')
                end 
                % step 2
            elseif doublecheck == 2
                % long up-slope trend
                if direction == 1
                    if lasttrade <= pxwithdrawmax
                        profitLoss = lasttrade - open_real;
                        return
                    elseif lasttrade >= pxhigh
                        pxhigh =  lasttrade;
                        pxwithdrawmin = pxhigh - (pxhigh - open) * bw_min;
                        pxwithdrawmax = pxhigh - (pxhigh - open) * bw_max;
                        doublecheck =2;
                    elseif lasttrade < pxhigh && lasttrade > pxwithdrawmin
                        doublecheck = 2;
                    elseif lasttrade <= pxwithdrawmin && lasttrade > pxwithdrawmax
                        %indicating the first round of trend is over but we
                        %may have a second trend in case withdrawmax is not
                        %breahed from the top.now we need to update the
                        %open price
                        open = lasttrade;
                        doublecheck = 3;
                    end
                elseif direction == -1
                    if lasttrade >= pxwithdrawmax;
                        profitLoss = open_real - lasttrade; 
                        return
                    elseif lasttrade <= pxhigh
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh + (open - pxhigh) * bw_min;
                        pxwithdrawmax = pxhigh + (open - pxhigh) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade > pxhigh && lasttrade < pxwithdrawmin
                        doublecheck = 2;
                    elseif lasttrade >= pxwithdrawmin && lasttrade < pxwithdrawmax
                        %indicating the first round of trend is over but we
                        %may have a second trend in case withdrawmax is not
                        %breahed from the top.now we need to update the
                        %open price
                        open = lasttrade;
                        doublecheck = 3;
                    end
                end

                    % step 3
            elseif doublecheck == 3
                if direction == 1
                    if lasttrade <= pxwithdrawmax
                        profitLoss = lasttrade - open_real;
                        return
                    elseif lasttrade >= pxhigh
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh - (pxhigh - open) * bw_min;
                        pxwithdrawmax = pxhigh - (pxhigh - open) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade <= pxwithdrawmin && lasttrade > pxwithdrawmax
                        open = min(open ,lasttrade);
                        doublecheck = 3;
                    elseif lasttrade < pxhigh && lasttrade > pxwithdrawmin
                        doublecheck = 3;
                    end
                elseif direction == -1
                    if lasttrade >= pxwithdrawmax
                        profitLoss = -lasttrade + open_real;
                        return
                    elseif lasttrade <= pxhigh
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh + (open - pxhigh) * bw_min;
                        pxwithdrawmax = pxhigh + (open - pxhigh) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade > pxhigh && lasttrade < pxwithdrawmin
                        doublecheck = 3;
                    elseif lasttrade >= pxwithdrawmin && lasttrade < pxwithdrawmax
                        %indicating the first round of trend is over but we
                        %may have a second trend in case withdrawmax is not
                        %breahed from the top.now we need to update the
                        %open price
                        open  = max(open, lasttrade);
                        doublecheck = 3;
                    end
                end
            end
        end    
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
    elseif stoplossMethod == 2
    % initalize paras
        nclose = size(close,1);  
        pxwithdrawmin(1) = -1;
        pxwithdrawmax(1) = -1;
        doublecheck = 1; 
        for i= 1:nclose
            lasttrade = close(i);
            lasthigh = high(i);
            lastlow = low(i);
            %时间原因，强平
            if i==nclose
               profitLoss = (lasttrade - open_real) * direction;
               return 
            end
            % step 1
            if doublecheck == 1
                if direction == 1 
                    if lastlow <= stoploss 
                        profitLoss = stoploss - open_real;
                        return
                    elseif lasttrade >= target
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh -(pxhigh - open) * bw_min;
                        pxwithdrawmax = pxhigh -(pxhigh - open) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade < target && lasttrade > stoploss
                        %do nothing and wait for the next  trade price
                    end
                elseif direction == -1
                    if lasthigh >= stoploss
                        profitLoss = -stoploss + open_real;
                        return
                    elseif lasttrade <= target
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh + (open - pxhigh) * bw_min;
                        pxwithdrawmax = pxhigh + (open - pxhigh) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade > target && lasttrade < stoploss
                        % do nothing and wait for the next trade price
                    end                                   
                else
                    error('w_r_batman_test_sunq：invalid direction of position')
                end 
                
            % step 2
            elseif doublecheck == 2
                % long up-slope trend
                if direction == 1
                    if lastlow <= stoploss 
                        profitLoss = stoploss - open_real;
                        return
                    elseif lasttrade <= pxwithdrawmax
                        profitLoss = lasttrade - open_real;
                        return
                    elseif lasttrade >= pxhigh
                        pxhigh =  lasttrade;
                        pxwithdrawmin = pxhigh - (pxhigh - open) * bw_min;
                        pxwithdrawmax = pxhigh - (pxhigh - open) * bw_max;
                        doublecheck =2;
                    elseif lasttrade < pxhigh && lasttrade > pxwithdrawmin
                        doublecheck = 2;
                    elseif lasttrade <= pxwithdrawmin && lasttrade > pxwithdrawmax
                        %indicating the first round of trend is over but we
                        %may have a second trend in case withdrawmax is not
                        %breahed from the top.now we need to update the
                        %open price
                        open = lasttrade;
                        doublecheck = 3;
                    end
                elseif direction == -1
                     if lasthigh >= stoploss
                        profitLoss = -stoploss + open_real;
                        return
                     elseif lasttrade >= pxwithdrawmax;
                        profitLoss = open_real - lasttrade; 
                        return
                    elseif lasttrade <= pxhigh
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh + (open - pxhigh) * bw_min;
                        pxwithdrawmax = pxhigh + (open - pxhigh) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade > pxhigh && lasttrade < pxwithdrawmin
                        doublecheck = 2;
                    elseif lasttrade >= pxwithdrawmin && lasttrade < pxwithdrawmax
                        %indicating the first round of trend is over but we
                        %may have a second trend in case withdrawmax is not
                        %breahed from the top.now we need to update the
                        %open price
                        open = lasttrade;
                        doublecheck = 3;
                    end
                end

                    % step 3
            elseif doublecheck == 3
                if direction == 1
                    if lastlow <= stoploss 
                        profitLoss = stoploss - open_real;
                        return
                    elseif lasttrade <= pxwithdrawmax
                        profitLoss = lasttrade - open_real;
                        return
                    elseif lasttrade >= pxhigh
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh - (pxhigh - open) * bw_min;
                        pxwithdrawmax = pxhigh - (pxhigh - open) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade <= pxwithdrawmin && lasttrade > pxwithdrawmax
                        open = min(open ,lasttrade);
                        doublecheck = 3;
                    elseif lasttrade < pxhigh && lasttrade > pxwithdrawmin
                        doublecheck = 3;
                    end
                elseif direction == -1
                     if lasthigh >= stoploss
                        profitLoss = -stoploss + open_real;
                        return
                     elseif lasttrade >= pxwithdrawmax
                        profitLoss = -lasttrade + open_real;
                        return
                    elseif lasttrade <= pxhigh
                        pxhigh = lasttrade;
                        pxwithdrawmin = pxhigh + (open - pxhigh) * bw_min;
                        pxwithdrawmax = pxhigh + (open - pxhigh) * bw_max;
                        doublecheck = 2;
                    elseif lasttrade > pxhigh && lasttrade < pxwithdrawmin
                        doublecheck = 3;
                    elseif lasttrade >= pxwithdrawmin && lasttrade < pxwithdrawmax
                        %indicating the first round of trend is over but we
                        %may have a second trend in case withdrawmax is not
                        %breahed from the top.now we need to update the
                        %open price
                        open  = max(open, lasttrade);
                        doublecheck = 3;
                    end
                end
            end
        end   
    end
 
end
               