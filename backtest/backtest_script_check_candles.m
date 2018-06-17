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
clear
clc
%%
code = 'rb1810';
replay_startdt = '2018-06-04';
replay_enddt = '2018-06-15';
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
replay_filenames = cell(size(replay_dates));
fn_tick_ = cell(size(replay_dates));
fn_candles_ = cell(size(replay_dates));
for i = 1:size(replay_dates,1)
    fn_tick_{i} = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
    fn_candles_{i} = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_1m.txt'];
end
tic
ticks =cDataFileIO.loadDataFromTxtFile(fn_tick_{1});
toc
%%
futs = code2instrument(code);
if datenum(futs.break_interval{end,end}) == datenum('23:00:00')
    kind =1;
elseif datenum(futs.break_interval{end,end}) == datenum('15:15:00')
    kind =2;
elseif datenum(futs.break_interval{end,end}) == datenum('01:00:00')
    kind =3;
end
%%
for k =1:size(replay_dates)
    fn_tick = fn_tick_{k};
    fn_candles = fn_candles_{k};
    ticks = cDataFileIO.loadDataFromTxtFile(fn_tick);
    buckets = getintradaybuckets2('date',floor(ticks(1,1)),...
        'frequency','1m',...
        'tradinghours',futs.trading_hours,...
        'tradingbreak',futs.trading_break);
    candles_manual = zeros(size(buckets,1),5);
    candles_manual(:,1) = buckets; 
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
    if kind ==1 || kind ==3
        para =2;
        t =ticks(para,1);
        pxtrade = ticks(para,2);
    elseif kind ==2
        para =4;
        t =ticks(para,1);
        pxtrade = ticks(para,2);
    end
    if kind == 3
        [m,n] = find(ticks(:,1) == datenum(num00_00_00));
          paraticks(1:sum(n),1) = datenum(num00_00_0_5);
          paraticks(1:sum(n),2) = ticks (m(:),2);
          paraticks(1:sum(n),3) = ticks (m(:),3);
          ticks =[ticks(1:m(end),:);paraticks;ticks(m(end)+1:end,:)];
    end
    idx = buckets(1:end-1)<t & buckets(2:end)>=t;
    this_bucket = buckets(idx);

    if ~isempty(this_bucket)
        count = find(buckets == this_bucket);
    else
        if t >= buckets(end) && t < buckets(end)+buckets(end)-buckets(end-1)
            count = size(buckets,1);
        else
            count = [];
        end
    end
    if isempty(count), error('invalid t and candle buckets'); end
    candles_manual(count,2) = pxtrade;
    candles_manual(count,3) = pxtrade;
    candles_manual(count,4) = pxtrade;
    candles_manual(count,5) = pxtrade;
    %
    nticks = size(ticks,1);
     for i =1:nticks 
         pxtrade = ticks(i,2);
            t = ticks(i,1);
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
        if sum(sum(equalorNot))==0
           idx = buckets(1:end-1)<t & buckets(2:end)>t;
        else
            idx = buckets(1:end-1)<t & equalorNot;
        end
        this_bucket = buckets(idx);
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
            if this_count ~= count
                count = this_count;
                newset = true;
            else
                newset = false;
            end
            candles_manual(this_count,5) = pxtrade;
            if newset
                candles_manual(this_count,2) = pxtrade;   %px_open
                candles_manual(this_count,3) = pxtrade;   %px_high
                candles_manual(this_count,4) = pxtrade;   %px_low
            else
                high = candles_manual(this_count,3);
                low = candles_manual(this_count,4);
                if pxtrade > high, candles_manual(this_count,3) = pxtrade; end
                if pxtrade < low, candles_manual(this_count,4) = pxtrade;end
            end
        end 
    end

% candles load from database directly
candles_db = cDataFileIO.loadDataFromTxtFile(fn_candles);
result(1,k) =sum(sum (candles_db - candles_manual))
end

