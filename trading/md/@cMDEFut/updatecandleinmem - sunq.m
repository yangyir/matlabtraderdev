% break_interval 是两列的cell， cell{1,1}:早上开盘时间； cell{end,end}:夜盘收盘时间（若有夜盘）
% 例如合约RB.SHF对应的break_interval 如下：
% '09:00:00'    '10:15:00'
% '10:30:00'    '11:30:00'
% '13:30:00'    '15:00:00'
% '21:00:00'    '23:00:00'
%  Bloomberg的 ticks data 生成 candle 的方式是：左开右闭
% 不同的合约生成 1m candle的方式是不同的，需要对特殊时间的tick进行处理
% 这里，对于tick数据的处理方式选择是根据： cell{end,end};
% 即cell{end,end}可能取值为： 23:00:00， 15:15:00 或者 01:00:00
%%%%% 对于螺纹钢的特殊点处理方法为：
% 螺纹钢 09：00:00 K线图对应tick数据区间： ticks（09:00:00， 09:01:00】
% 螺纹钢 14：59：00 K线图对应tick数据区间： ticks（14：59：00 , 15：00：00】
% 螺纹钢 21：00：00 K线图对应tick数据区间： ticks 【21：00：00， 21：01：00】
% 螺纹钢  K线图没有数据的时间：break_interval{:,2} 
% 螺纹钢 ticks数据没有用到，处理时被skip的为： 08:59:00， 10:30:00， 13:30：00
%%%%% 镍处理如下：
% 镍其他时间处理与螺纹钢相同，除了 00:00:00
% 镍的 candle_23:59:59 = ticks (23:59:00 , 00:00:00] 左开右闭
% 镍的 candle_00:00:00 = ticks [00:00:00 , 00:01:00] 左闭右闭
% 国债数据处理如下：
%%%%%% 国债处理如下：
% 国债 candle_11:29:00 = ticks (11:29:00 , 11:30:00) 左开右开
% 国债 candle_13:00:00 = ticks (13:00:00, 13:00:01 ] 左开右闭
% equalorNot 用来解决str相同，但是double不同导致最终比较结果错误的问题
function [] = updatecandleinmem(mdefut, instrument)

    if datenum(instrument.break_interval{end,end}) == datenum('23:00:00')
        kind =1
    elseif datenum(instrument.break_interval{end,end}) == datenum('15:15:00')
        kind =2;
    elseif datenum(instrument.break_interval{end,end}) == datenum('01:00:00')
        kind =3;
    end
    if isempty(mdefut.ticks_), return; end
    ns = size(mdefut.ticks_,1);
    count = mdefut.ticks_count_;
    for i =1:ns
        buckets = mutfut.candles_{i}(:,1);
        buckets4save = mdefut.candles4save_{i}(:,i);
        t = mdefut.ticks_{i}(cout(i),4);
        px_trade = mdefut.ticks_{i}(count(i),4);
        datestring1 = datestr(buckets(1));
        datestring2 = datestring1(1:end-8);
        datestring3 = datestr(buckets(end));
        datestring4 = datestring3(1:end-8);
        num15_00_00 = datenum([datestring2,'15:00:00']);
        num20_59_00 = datenum([datestring2,'20:59:00']);
        num21_00_00 = datenum([datestring2, '21:00:00']);
        num21_00_0_5 = datenum([datestring2, '21:00:0.5']);
        num11_30_00 = datenum([datestring2, '11:30:00']);
        num13_30_00 = datenum([datestring2, '13:30:00']);
        num13_00_00 = datenum([datestring2, '13:00:00']);
        num10_15_00 = datenum([datestring2, '10:15:00']);
        num10_30_00 = datenum([datestring2, '10:30:00']);
        num23_00_00 = datenum([datestring2, '23:00:00']);
        num09_00_00 = datenum([datestring2, '09:00:00']);
        num22_59_59_5= datenum([datestring2, '22:59:59.5']); 
        num01_00_00 = datenum([datestring4,'01:00:00']);
        num00_00_00 = datenum([datestring4,'00:00:00']);
        num00_00_0_5 = datenum([datestring4,'00:00:0.5']);
        if kind == 1
              if t == num20_59_00
                  continue
              elseif t == num21_00_00
                  t = num21_00_0_5;
              elseif t == num23_00_00
                  t = num22_59_59_5;
              elseif t == num10_30_00
                  continue
              elseif t == num13_30_00
                  continue
              elseif t == num10_15_00
                  t = num10_30_00;
              elseif t== num11_30_00
                  t = num13_30_00;
              elseif t == num15_00_00
                  t = num21_00_00;
              elseif t == num23_00_00
                  t = num09_00_00;
              end
            elseif kind == 2
                if t == num11_30_00
                    continue
                elseif t == num13_00_00
                    continue
                end  
            elseif kind == 3
              if t == num20_59_00
                  continue
              elseif t == num21_00_00
                  t = num21_00_0_5;
              elseif t == num23_00_00
                  t = num22_59_59_5;
              elseif t == num10_30_00
                  continue
              elseif t == num13_30_00
                  continue
              elseif t == num10_15_00
                  t = num10_30_00;
              elseif t== num11_30_00
                  t = num13_30_00;
              elseif t == num15_00_00
                  t = num21_00_00;
              elseif t == num23_00_00
                  t = num09_00_00;
              end
        end
        % equalorNot 用来解决str相同，但是double不同导致最终比较结果错误的问题
        equalorNot = (round(buckets(2:end) *10e+07) == round(t*10e+07));
        equalorNot4save = (round(buckets4save(2:end) *10e+07) == round(t*10e+07));
        if sum(sum(equalorNot))==0
           idx = buckets(1:end-1)<t & buckets(2:end)>t;
        else
            idx = buckets(1:end-1)<t & equalorNot;
        end
        this_bucket = buckets(idx);
        if sum(sum(equalorNot4save))==0
           idx4save = buckets4save(1:end-1)<t & buckets4save(2:end)>t;
        else
           idx4save = buckets4save(1:end-1)<t & equalorNot4save;
        end
        this_bucket_save = buckets4save(idx4save);
        %
        if ~isempty(this_bucket)
            this_count = find(buckets == this_bucket);
        else
            if t >= buckets(end) 
                this_count = size(buckets,1);
            else
                this_count = [];
            end
        end

        if ~isempty(this_count)
            if this_count ~= mdefut.candles_count_(i)
                mdefut.candles_count_(i) = this_count;
                newset = true;
            else
                newset = false;
            end
            mdefut.candles_{i}(this_count,5) = px_trade;
            if newset
                mdefut.candles_{i}(this_count,2) = px_trade;   %px_open
                mdefut.candles_{i}(this_count,3) = px_trade;   %px_high
                mdefut.candles_{i}(this_count,4) = px_trade;   %px_low
            else
                high = mdefut.candles_{i}(this_count,3);
                low = mdefut.candles_{i}(this_count,4);
                if px_trade > high, mdefut.candles_{i}(this_count,3) = px_trade; end
                if px_trade < low, mdefut.candles_{i}(this_count,4) = px_trade;end
            end
        end
        %
        if ~isempty(this_bucket_save)
            this_count_save = find(buckets4save == this_bucket_save);
        else
            if t >= buckets4save(end)
                this_count_save = size(buckets4save,1);
            else
                this_count_save = [];
            end
        end

        if ~isempty(this_count_save)
            if this_count_save ~= mdefut.candles4save_count_(i)
                mdefut.candles4save_count_(i) = this_count_save;
                newset = true;
            else
                newset = false;
            end
            mdefut.candles4save_{i}(this_count_save,5) = px_trade;
            if newset
                mdefut.candles4save_{i}(this_count_save,2) = px_trade;   %px_open
                mdefut.candles4save_{i}(this_count_save,3) = px_trade;   %px_high
                mdefut.candles4save_{i}(this_count_save,4) = px_trade;   %px_low
            else
                high = mdefut.candles4save_{i}(this_count_save,3);
                low = mdefut.candles4save_{i}(this_count_save,4);
                if px_trade > high, mdefut.candles4save_{i}(this_count_save,3) = px_trade; end
                if px_trade < low, mdefut.candles4save_{i}(this_count_save,4) = px_trade;end
            end
        end
        %
    end
end
%end of updatecandleinmem