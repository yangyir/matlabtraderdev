%private function to get quotes from CTP datasource
function quotes = getquotes_ctp(watcher)
    watcher.init_quotes;
    ns = watcher.countsingles;
    nu = watcher.countunderliers;

    list_ctp = cell(ns+nu,1);
    for i = 1:ns
        list_ctp{i} = watcher.singles_ctp{i};
    end
    for i = ns+1:ns+nu
        list_ctp{i} = watcher.underliers_ctp{i-ns};
    end

    quotes = zeros(ns+nu,7);

    data = watcher.ds.realtime(list_ctp,'');
    for i = 1:ns+nu
        mkt = data{i}.mkt;
        level = data{i}.level;
        updatetime = data{i}.updatetime;
        quotes(i,1) = today;     %date
        %time field may not pop-up as HH:MM:SS but as mm/dd/yyyy
        try
            quotes(i,2) = datenum([datestr(quotes(i,1)),' ',updatetime]);
        catch
            if isempty(strfind(data.time{i},':'))
                quotes(i,2) = datenum([datestr(quotes(i,1)),' 15:15:00']);
            else
                quotes(i,2) = NaN;
            end
        end

        quotes(i,3) = mkt(1);
        quotes(i,4) = level(1,1);
        quotes(i,5) = level(1,3);
        quotes(i,6) = level(1,2);
        quotes(i,7) = level(1,4);
    end

    watcher.quotessingle2pair;

end