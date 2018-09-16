clear
clc
fprintf('running regress test:tick2candles_ironore\n')
%%
code = 'i1809';
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

n = size(replay_dates,1);
result = zeros(1,n);
for k =1:n
    fn_tick = fn_tick_{k};
    fn_candles = fn_candles_{k};
    ticks = cDataFileIO.loadDataFromTxtFile(fn_tick);
    candles = timeseries_tick2candle('code',code,'ticks',ticks);
    candles_manual = candles{1};
    
    % candles load from database directly
    candles_db = cDataFileIO.loadDataFromTxtFile(fn_candles);
    
        
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
    fprintf('%s:finish ticks to candles on %s...\n',code,datestr(replay_dates(k)));
    
end
display(result);
%note:
% result =
% 
%      0     0     0     0     0     0     0     0     0     0     0     0     0     0
% no error shall be reported when new codes are checked-in