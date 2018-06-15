% 数据说明：Bloomberg , tick data 转化成 candle_data, 左开右闭，
% 例如： 时间 09：00：00 的一分钟K线数据来源的区间： （09:00:00， 09:01:00】
% 但是有特殊情况是： 收盘时间 15：00：00， 这分钟没有K线数据的， 但是存在tick数据，导致：
% 14：59：00 K线图对应tick数据区间： （14：59：00 , 15：00：00】
% 21：00：00 K线图对应tick数据区间： 【21：00：00， 21：01：00】
% 解决方法： K线图buckets vector虚拟增加时间轴 15：00：00 ，最后算完再4删掉？？？我想下，现在脑子 in a mess

futs = code2instrument('rb1810');
fn_tick = 'rb1810_20180423_tick.mat';
fn_candles = 'rb1810_20180423_1m.txt';
d = load(fn_tick);
ticks = d.d;
ticks = ticks(:,1:2);
% candles load from database directly
candles_db = cDataFileIO.loadDataFromTxtFile(fn_candles);
buckets = getintradaybuckets2('date',floor(ticks(1,1)),...
    'frequency','1m',...
    'tradinghours',futs.trading_hours,...
    'tradingbreak',futs.trading_break);
candles_manual = zeros(size(buckets,1),5);
candles_manual(:,1) = buckets;
%%
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
    pxtrade = ticks(i,2);
    % equalorNot 用来解决str相同，但是double不同导致最终比较结果错误的问题
    equalorNot = (round(buckets(2:end) *10e+07) == round(t*10e+07));
    if sum(sum(equalorNot))==0
       idx = buckets(1:end-1)<t & buckets(2:end)>t;
    else
        idx = buckets(1:end-1)<t & equalorNot;
    end
    
%     idx = buckets(1:end-1)<t & ((buckets(2:end)>=t )) ; 
    this_bucket = buckets(idx);
    %
    if ~isempty(this_bucket)
        this_count = find(buckets == this_bucket);
    else
        if t >= buckets(end) && t < buckets(end)+buckets(end)-buckets(end-1)
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

%%
% sanity check whether candles_mannual and candles_db are exactly the same
check1 = sum(candles_db(:,1) - candles_manual(:,1));
if check1 ~= 0, fprintf('manually pop-up candle timevec is inconsistent with the one from database');end
check2 = candles_db(:,2) ~= candles_manual(:,2);
    

