% 数据说明：Bloomberg , tick data 转化成 candle_data, 左开右闭，
% 例如： 时间 09：00：00 的一分钟K线数据来源的区间： （09:00:00， 09:01:00】
% 但是有特殊情况是： 收盘时间 15：00：00， 这分钟没有K线数据的， 但是存在tick数据，导致：
% 14：59：00 K线图对应tick数据区间： （14：59：00 , 15：00：00】
% 21：00：00 K线图对应tick数据区间： 【21：00：00， 21：01：00】
% bloomberg的K线图没有数据的四个时间：10:15:00 ， 11:30:00 ， 15:00:00， 23:00:00 
clear
clc
code = 'rb1810';
replay_startdt = '2018-05-05';
replay_enddt = '2018-05-23';
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
replay_filenames = cell(size(replay_dates));
fn_tick_ = cell(size(replay_dates));
fn_candles_ = cell(size(replay_dates));
for i = 1:size(replay_dates,1)
    fn_tick_{i} = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.mat'];
    fn_candles_{i} = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_1m.txt'];
end
futs = code2instrument(code);
for k =1:size(replay_dates)
    fn_tick = fn_tick_{k};
    fn_candles = fn_candles_{k};
    d = load(fn_tick);
    ticks = d.d;
    ticks = ticks(:,1:2);
    buckets = getintradaybuckets2('date',floor(ticks(1,1)),...
        'frequency','1m',...
        'tradinghours',futs.trading_hours,...
        'tradingbreak',futs.trading_break);
    candles_manual = zeros(size(buckets,1),5);
    candles_manual(:,1) = buckets;
    datestring1 = datestr(buckets(1));
    datestring2 = datestring1(1:end-8);
    num15_00_00 = datenum([datestring2,'15:00:00']);
    num20_59_00 = datenum([datestring2,'20:59:00']);
    num21_00_00 = datenum([datestring2, '21:00:00']);
    num21_00_0_5 = datenum([datestring2, '21:00:0.5']);
    num11_30_00 = datenum([datestring2, '11:30:00']);
    num13_30_00 = datenum([datestring2, '13:30:00']);
    num10_15_00 = datenum([datestring2, '10:15:00']);
    num10_30_00 = datenum([datestring2, '10:30:00']);
  
    t = ticks(2,1);
    pxtrade = ticks(2,2);
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
    for i = 2:nticks
        t = ticks(i,1);
        if t == num21_00_00
            t = num21_00_0_5;
        elseif t == num20_59_00
            continue;
        elseif t == num13_30_00
            continue;
        elseif t == num10_30_00
            continue;
        elseif t == num15_00_00
            t = num21_00_00;
        elseif t == num11_30_00
            t = num13_30_00;
        elseif t == num10_15_00
            t = num10_30_00;
        end
        pxtrade = ticks(i,2);
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

% sanity check whether candles_mannual and candles_db are exactly the same
check1 = sum(candles_db(:,1) - candles_manual(:,1));
if check1 ~= 0, fprintf('manually pop-up candle timevec is inconsistent with the one from database');end
check2 = candles_db(:,2) ~= candles_manual(:,2);

result(1,k) =sum(sum (candles_db - candles_manual));
end

