% written by sunq, updated on 2018/05/31, version 1
% bw_max = 1/2; bw_min =1/3;
% direction =1, long ;  direction = -1, short
% wr_batman_test_sunq，用于已经确认了开仓信号， 之后的止盈止损策略
% close是行情数据,包括开盘价open
% open：开盘价;  target 和 stoploss是设置好的，可以是固定值，也可以是一个函数据算出的
% holdperiod :时间止损止盈点，之后强行平仓

function [ profitLoss ] = w_r_batman_test_sunq(direction,close, open, target, stoploss, bw_max, bw_min, holdperiod)
% initalize paras
    nclose = size(close,1);
    pxopen(1) = open;
    pxstoploss(1) =  stoploss;
    pxtarget(1) = target;
    pxwithdrawmin(1) = -1;
    pxwithdrawmax(1) = -1;
    
                
    for i = 2:nclose
        % 时间原因，强平
        if  i==holdperiod
                profitLoss = (close(i) - open(i)) * direction;
                return
        end
        if (pxwithdrawmin(i) == -1 && pxwithdrawnmax(i) == -1)
         if direction ==1
            if close(i) >= pxtarget(i)
                pxhigh(i) = close(i);
                pxwithdrawmin(i) = pxhigh(i) - (pxhigh(i)- pxopen(i)) * bw_min;
                pxwithdrawmax(i) = pxhigh(i) - (pxhigh(i)-pxopen(i)) * bw_max ;
            elseif close(i) < pxtarget(i) && close(i) > pxstoploss(i)
                %do nothing and wait for the next trade price
            elseif close(i) <= pxstoploss(i)
                profitLoss = close(i) - open;
                return
            end
        elseif direction == -1
            if close(i) <= pxtarget(i)
                   pxhigh(i) = close(i);
                   pxwithdrawmin(i) = pxhigh(i) + (pxopen(i)-pxhigh(i)) * bw_min;
                   pxwithdrawmax(i) = pxhigh(i) + (pxopen(i)-pxhigh(i)) * bw_max;
               elseif close(i) > pxtarget(i) && close(i) < pxstoploss(i)
                   %do nothing and wait for the next trade price
               elseif close(i) >= pxstoploss(i)
                   profitLoss = -close(i) + open;
                   return
               end
           else
               error('cStratFutBatman:riskmanagement:invalid direction of position')
           end
           doublecheck = 0;     
           return
        
 
     %    
        %long up-slope trend
        if direction == 1
            if doublecheck == 0 
                if close(i) <= pxwithdrawmax(i)
                    profitLoss = close(i) - open;
                    doublecheck = 0;
                    return
                elseif close(i) >= pxhigh(i)
                    pxhigh(i) = close(i);
                    pxwithdrawmin(i) = pxhigh(i) - (pxhigh(i)-pxopen(i)) * bw_min;
                    pxwithdrawmax(i) = pxhigh(i) - (pxhigh(i)-pxopen(i)) * bw_max;
                    doublecheck = 0;
                elseif close(i) < pxhigh(i) && lasttrade > pxwithdrawmin(i)
                    doublecheck = 0;
                elseif close(i) <= pxwithdrawmin(i) && close(i) > pxwithdrawmax(i)
                    %indicating the first round of trend is over but we
                    %may have a second trend in case withdrawmax is not
                    %breahed from the top.now we need to update the
                    %open price
                    pxopen(i) = close(i);
                    doublecheck = 1;
                end
            elseif doublecheck(i) == 1
                if close(i) <= pxwithdrawmax(i)
                    profitLoss = close(i) - open;
                    doublecheck = 0;
                    return
                elseif close(i) >= pxhigh(i)
                    pxhigh(i) = close(i);
                    pxwithdrawmin(i) = pxhigh(i) - (pxhigh(i)-pxopen(i)) * bw_min;
                    pxwithdrawmax(i) = pxhigh(i) - (pxhigh(i)-pxopen(i)) * bw_max;
                    doublecheck = 0;
                elseif close(i) <= pxwithdrawmin(i) && close(i) > pxwithdrawmax(i)
                    pxopen(i) = min(pxopen(i),close(i));
                    doublecheck = 1;
                elseif close(i) < pxhigh(i) && close(i) > pxwithdrawmin(i)
                    doublecheck = 1;
                end
            end
            return
        end
        
        %short down-slope trend
        if direction == -1
            if doublecheck == 0 
                if close(i) >= pxwithdrawmax(i)
                    profitLoss = open - close(i); 
                    doublecheck = 0;
                    return
                elseif close(i) <= pxhigh(i)
                    pxhigh(i) = close(i);
                    pxwithdrawmin(i) = pxhigh(i) + (pxopen(i)-pxhigh(i)) * bw_min;
                    pxwithdrawmax(i) = pxhigh(i) + (pxopen(i)-pxhigh(i)) * bw_max;
                    doublecheck = 0;
                elseif close(i) > pxhigh(i) && close(i) < pxwithdrawmin(i)
                    doublecheck = 0;
                elseif close(i) >= pxwithdrawmin(i) && close(i) < pxwithdrawmax(i)
                    %indicating the first round of trend is over but we
                    %may have a second trend in case withdrawmax is not
                    %breahed from the top.now we need to update the
                    %open price
                    pxopen(i) = close(i);
                    doublecheck = 1;
                end
            elseif doublecheck == 1
                if close(i) >= pxwithdrawmax(i)
                    profitLoss = close(i) - open;
                    doublecheck = 0;
                    return
                elseif close(i) <= pxhigh(i)
                    pxhigh(i) = close(i);
                    pxwithdrawmin(i) = pxhigh(i) + (pxopen(i)-pxhigh(i)) * bw_min
                    pxwithdrawmax(i) = pxhigh(i) + (pxopen(i)-pxhigh(i)) * bw_max;
                    doublecheck = 0;
                elseif close(i) >= pxwithdrawmin(i) && close(i) < pxwithdrawmax(i)
                    pxopen(i) = max(pxopen(i),close(i));
                    doublecheck = 1;
                elseif close(i) > pxhigh(i) && close(i) < pxwithdrawmin(i)
                    doublecheck = 1;
                end
            end
            return
        end
        %
        %
    end
end
