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
code = 'cu1808';
[category,extrainfo,instrument] = getfutcategory(code);
replay_startdt = '2018-06-04';
replay_enddt = '2018-06-22';
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
replay_filenames = cell(size(replay_dates));
fn_tick_ = cell(size(replay_dates));
fn_candles_ = cell(size(replay_dates));
for i = 1:size(replay_dates,1)
    fn_tick_{i} = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_tick.txt'];
    fn_candles_{i} = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_1m.txt'];
end

%%
n = size(replay_dates,1);
n = 1;
result = zeros(1,n);
interval = 5;
for k =1:n
    fn_tick = fn_tick_{k};
    fn_candles = fn_candles_{k};
    ticks = cDataFileIO.loadDataFromTxtFile(fn_tick);
    candles = timeseries_tick2candle('code',code,'ticks',ticks,'interval',interval);
    candles_manual = candles{1};
    fprintf('finish ticks to candles on %s...\n',datestr(replay_dates(k)));
    % candles load from database directly
    if category ~= 5
        candles_db = cDataFileIO.loadDataFromTxtFile(fn_candles);
    else
        candles_db = cDataFileIO.loadDataFromTxtFile(fn_candles);
        cob_date = replay_dates(k);
        fn_ = [code,'_',datestr(cob_date+1,'yyyymmdd'),'_1m.txt'];
        try
            candles_db_overnight = cDataFileIO.loadDataFromTxtFile(fn_);
            candles_db = [candles_db;candles_db_overnight];
        catch
            fprintf('%s candle not found in database\n', datestr(cob_date+1,'yyyymmdd'));
        end
    end
    
    if interval ~= 1
        candles_db = timeseries_compress(candles_db,'frequency',[num2str(interval),'m']);
    end
        
    [~,idxA,idxB] = intersect(candles_db(:,1),candles_manual(:,1));
    result_k = sum(sum (candles_db(idxA,:) - candles_manual(idxB,:)));
    result(1,k) = result_k;
    if result_k ~= 0
        checkLh = candles_db(idxA,:);
        checkRh = candles_manual(idxB,:);
        nrecords = size(checkLh,1);
        for j = 1:nrecords
            if sum(checkLh(j,:) - checkRh(j,:)) ~= 0
                fprintf('difference found:%s,open:%s(%s);high:%s(%s);low:%s(%s);close:%s(%s)\n',...
                    datestr(checkLh(j,1),'yyyymmdd HH:MM:SS'),num2str(checkLh(j,2)),num2str(checkRh(j,2)),...
                    num2str(checkLh(j,3)),num2str(checkRh(j,3)),...
                    num2str(checkLh(j,4)),num2str(checkRh(j,4)),...
                    num2str(checkLh(j,5)),num2str(checkRh(j,5)));
            end
        end
    end
    
end
display(result);
