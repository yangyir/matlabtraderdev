%%
%Bloomberg connection
conn = bbgconnect;
%%
%�������ʲ����ƣ�������ʲ�����ʷ�¸��ڻ���Լ�Ļ���ʱ��
asset = 'nickel';
rollinfo = rollfutures(asset);
%%
%�����Լ���кţ���һ����һ�����У�
fut_idx = [8];
%�����Լ����ʱ�䣬���ݻ���ʱ��ѡȡ��Ƶ��ԭʼ����
fut_list = rollinfo.RollInfo(fut_idx,5);
futs = cell(size(fut_list,1),1);
data_raw = cell(size(fut_list,1),1);
for i = 1:size(fut_list,1)
    code_str = fut_list{i};
    code_str = code_str(1:length(code_str)-4);
    code_ctp = str2ctp(code_str);
    futs{i} = cFutures(code_ctp);
    futs{i}.loadinfo([code_ctp,'_info.txt']);
    start_dt = [rollinfo.RollInfo{fut_idx(i),6},' 09:00:00'];
    if fut_idx(i) == size(rollinfo.RollInfo,1)
        end_dt = [datestr(getlastbusinessdate),' 15:00:00'];
    else
        end_dt = [rollinfo.RollInfo{fut_idx(i+1),6},' 15:00:00'];
    end
    data_raw{i} = timeseries(conn,futs{i}.code_bbg,{start_dt,end_dt},1,'trade');
end
%%
%���뽻��Ƶ�ʣ����ӣ�����������Ľ���Ƶ��ѹ������
trading_freq = 5;
data_comp = cell(size(data_raw,1),1);
for i = 1:size(fut_list,1)
    data_comp{i} = timeseries_compress(data_raw{i}(:,1:5),'tradinghours',futs{i}.trading_hours,...
        'tradingbreak',futs{i}.trading_break,'frequency',[num2str(trading_freq),'m']);
end


% time_freq = 5;
% start_dt = '2017-08-07';
% end_dt = '2017-11-08';
% 
% %%
% data = timeseries(conn,fut.code_bbg,{start_dt,end_dt},time_freq,'trade');
% %%
% data = timeseries_window(data(:,1:5),'tradinghours',fut.trading_hours,'tradingbreak',fut.trading_break);
% %%
% nperiods = 144;
% wr_buy = -100;
% wr_sell = -0;
% high_p = data(:,3);
% low_p = data(:,4);
% close_p = data(:,5);
% 
% wr_matlab = willpctr(high_p,low_p,close_p,nperiods);
% 
% %%
% %note:rough than using the close price directly for the backtest, we apply
% %the high,low and close price alltogether. The logic is to check whether
% %high,low or close price in nperiod+1 time slot has satisfied the following
% %conditions:
% %1. either the high price is higher than the highest price of the
% %previous nperiods time slots
% %2. or the low price is lower than the lowest price of the previous
% %nperiods time slots
% indicators = NaN*close_p;
% execution_price = NaN*close_p;
% for i = nperiods+1:size(close_p,1)
%     highest_pre = max(high_p(i-nperiods:i-1));
%     lowest_pre = min(low_p(i-nperiods:i-1));
%     high_i = high_p(i);
%     low_i = low_p(i);
%     close_i = close_p(i);
%     if high_i >= highest_pre
%         indicators(i) = -1;
%         execution_price(i) = highest_pre;
%     elseif low_i <= lowest_pre
%         indicators(i) = 1;
%         execution_price(i) = lowest_pre;
%     end
% end

%%
%statiscal analysis on the solution
%note:
n = size(find(indicators==1),1)+size(find(indicators==-1),1);
max_pnl_dist = zeros(n,1);
min_pnl_dist = zeros(n,1);

contract_size = fut.contract_size;
base_units = 10;
margin_ratio = 0.1;
count = 0;
for i = nperiods+1:size(close_p,1)
    if indicators(i) == 1
        count = count + 1;
        cost = execution_price(i);
        for j = i+1:size(close_p,1)
            if (high_p(j)-cost)*base_units*contract_size>max_pnl_dist(count)
                max_pnl_dist(count) = (high_p(j)-cost)*base_units*contract_size;
            end
            %
            if (low_p(j)-cost)*base_units*contract_size<min_pnl_dist(count)
                min_pnl_dist(count) = (low_p(j)-cost)*base_units*contract_size;
            end
            %
            if indicators(j) == -1
                break
            end
        end
    elseif indicators(i) == -1
        count = count + 1;
        cost = execution_price(i);
        for j = i+1:size(close_p,1)
            if (cost-high_p(j))*base_units*contract_size<min_pnl_dist(count)
                min_pnl_dist(count) = (cost-high_p(j))*base_units*contract_size;
            end
            %
            if (cost-low_p(j))*base_units*contract_size>max_pnl_dist(count)
                max_pnl_dist(count) = (cost-low_p(j))*base_units*contract_size;
            end
            %
            if indicators(j) == 1
                break
            end
        end
    end
    
end







