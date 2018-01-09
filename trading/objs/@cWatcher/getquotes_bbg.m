%private function to get quotes from BLOOMBERG datasource
function quotes = getquotes_bbg(watcher)
    watcher.init_quotes;
    ns = watcher.countsingles;
    nu = watcher.countunderliers;

    list_ctp = cell(ns+nu,1);
    list_bbg = cell(ns+nu,1);
    for i = 1:ns
        list_ctp{i} = watcher.singles_ctp{i};
        list_bbg{i} = watcher.singles_b{i};
    end
    for i = ns+1:ns+nu
        list_ctp{i} = watcher.underliers_ctp{i-ns};
        list_bbg{i} = watcher.underliers_b{i-ns};
    end

    quotes = zeros(ns+nu,7);

    data = watcher.ds.realtime(list_bbg,{'last_update_dt','time','last_trade','bid','ask','bid_size','ask_size'});
    for i = 1:ns+nu
        quotes(i,1) = data.last_update_dt(i);     %date
        %time field may not pop-up as HH:MM:SS but as mm/dd/yyyy
        try
            quotes(i,2) = datenum([datestr(quotes(i,1)),' ',data.time{i}]);
        catch
            if isempty(strfind(data.time{i},':'))
                quotes(i,2) = datenum([datestr(quotes(i,1)),' 15:15:00']);
            else
                quotes(i,2) = NaN;
            end
        end

        quotes(i,3) = data.last_trade(i);
        quotes(i,4) = data.bid(i);
        quotes(i,5) = data.ask(i);
        quotes(i,6) = data.bid_size(i);
        quotes(i,7) = data.ask_size(i);
    end
end