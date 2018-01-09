% private function to get quotes from WIND datasource
function quotes = getquotes_wind(watcher)
    ns = size(watcher.singles,1);

    list_ctp = cell(ns,1);
    for i = 1:ns
        list_ctp{i} = watcher.singles_ctp{i};
    end

    if ns > 0
        list_wind = watcher.singles_w{1};
    end

    for i = 2:ns
        temp = [list_wind,',',watcher.singles_w{i}];
        list_wind = temp;
    end

    quotes = zeros(ns,7);

    data = watcher.ds.realtime(list_wind,'rt_date,rt_time,rt_latest,rt_bid1,rt_ask1,rt_bsize1,rt_asize1');
    %rt_date is in the format of yyyymmdd
    %rt_time is in the format of hhmmss
    for i = 1:ns
        tstr = num2str(data(i,2));
        if length(tstr) == 5
            hhstr = ['0',tstr(1)];
        else
            hhstr = tstr(1:2);
        end
        mmstr = tstr(end-3:end-2);
        ddstr = tstr(end-1:end);
        tstr = [hhstr,':',mmstr,':',ddstr];
        quotes(i,1) = datenum(num2str(data(i,1)),'yyyymmdd');
        quotes(i,2) = datenum([datestr(quotes(i,1)),' ',tstr]);
        quotes(i,3:end) = data(i,3:end);
    end

end