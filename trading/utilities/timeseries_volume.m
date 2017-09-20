% timeseries_volume
assets = {'rubber','rubber'};
seasons = [1,5];
cy = [6,6];
% indicator_types = {'ValueChangeRel'};
% weights = [1,-1];
% %
fut_code = get_futcode(seasons);
c1 = cContract('BCode',[get_code(assets{1}),fut_code{1},num2str(cy(1))]);
% c2 = cContract('BCode',[get_code(assets{2}),fut_code{2},num2str(cy(2))]);
date_from = '15-Jul-2015';

% interval = '15m';
% 
ts1_obj_1m = c1.getTimeSeries{2,1};
data = ts1_obj_1m.getTimeSeries('Fields','Volume',...
                                'FromDate',date_from,...
                                'Interval','1m',...
                                'TradingHours',c1.TradingHours,...
                                'TradingBreak',c1.TradingBreak);

                           
n_buckest = 25;
days_str = unique(datestr(data(:,1),'dd-mmm-yyyy'),'rows');
days_num = sort(datenum(days_str,'dd-mmm-yyyy'));
temp = cell(length(days_num),1);
ttv = zeros(length(days_num),2);
%
for i = 1:length(days_num)
    t_start = datenum([datestr(days_num(i)),' 00:00:00'],...
                            'dd-mmm-yyyy HH:MM:SS');
    t_end = datenum([datestr(days_num(i)),' 23:59:59'],...
                            'dd-mmm-yyyy HH:MM:SS');
    idx = data(:,1)>=t_start&data(:,1)<t_end;
    data_i = data(idx,:);
    t_slot = NaN(n_buckest,1);
    if ~isempty(data_i)
        tv = sum(data_i(:,5));
        ctv = cumsum(data_i(:,5));
        buckets = linspace(0,tv,n_buckest+1);
        buckets = buckets';
        for j = 1:n_buckest
            ii = find(ctv <= buckets(j+1,1));
            if ~isempty(ii)
                t_slot(j,1) = data_i(ii(end,1),1);
            else
                t_slot(j,1) = data_i(1,1);
            end
        end
        t_slot = t_slot(~isnan(t_slot),:);
        temp{i} = t_slot;
        ttv(i,1) = days_num(i);
        ttv(i,2) = tv;
    end
end
bar(ttv(:,2));
res = cell2mat(temp);