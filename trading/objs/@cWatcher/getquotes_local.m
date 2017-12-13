%private function to get quotes from local datasource
 function quotes = getquotes_local(watcher,timestr)
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

    data = watcher.ds.realtime(list_ctp,timestr);
    for i = 1:ns+nu
        quotes(i,1) = data.last_update_dt(i);
        quotes(i,2) = data.time(i);
        quotes(i,3) = data.last_trade(i);
        quotes(i,4) = data.bid(i);
        quotes(i,5) = data.ask(i);
        quotes(i,6) = NaN;
        quotes(i,7) = NaN;
    end

    watcher.quotessingle2pair;

end

