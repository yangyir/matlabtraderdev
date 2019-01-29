% written by sunq, updated on 2018/05/31, version 1
% bw_max = 1/2; bw_min =1/3;
% direction =1, long ;  direction = -1, short
% wr_batman_test_sunq�������Ѿ�ȷ���˿����źţ� ֮���ֹӯֹ�����
% close����������,���̼�open֮�������
% open�����̼�;  target �� stoploss�����úõģ������ǹ̶�ֵ��Ҳ������һ�������������
% holdperiod :ʱ��ֹ��ֹӯ�㣬֮��ǿ��ƽ��
%doublecheck : 1 �ǵ�һ��ѭ���� 2 �ǵڶ���ѭ���� 3 �ǵ�����ѭ��
%�����������û�м�ʱ���֣����Ǻ������������ˣ�������ƣ����֣�����˵���ʼ��Ϳ��ֵ㲻��ȵ����---
%��������£�open ��������ļ۸񣬼���Ϊ���ǵĿ��ּۣ� ʵ�ʵĿ��ּ۸���open_real��PnL�ǰ���open_real�����
%���û�������openΪ�գ���ʾ���ּۺ��𵴵ļ۸�һ�£�Ĭ�� open = open_real
% written by sunq, updated on 2018/05/31, version 1
%�����˲�����stoplossMethod�� stoplossMethod == 1: ���̼�ֹ��  stoplossMethod == 2...
%����K��ͼֹ�𣬼���߼ۺ���ͼ۴���ֹ���ߣ������̰���ֹ���ֹ�𣬶����õ����̼۵ĵ�����ֹ��

function [ profitLoss ] = w_r_batman_test_sunq(direction,close,high,low, open, open_real, target, stoploss, bw_max, bw_min, stoplossMethod)
    if stoplossMethod == 1
    % initalize paras
        nclose = size(close,1);  
        pxwithdrawmin(1) = -1;
        pxwithdrawmax(1) = -1;
        doublecheck = 0; 
        for i= 1:nclose
            lasttrade = close(i);
            %ʱ��ԭ��ǿƽ
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
                    error('w_r_batman_test_sunq��invalid direction of position')
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
            %ʱ��ԭ��ǿƽ
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
                    error('w_r_batman_test_sunq��invalid direction of position')
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
               