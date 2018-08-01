%private function to get pair quotes from single quotes
function quotes_pair = quotessingle2pair(watcher)
    if isempty(watcher), return; end

    if isempty(watcher.qs)
        watcher.qp = {};
        quotes_pair = {};
        return
    end
    np = size(watcher.pairs,1);

    if np > 0
        quotes_pair = cell(np,1);
        for i = 1:np
            q = cQuoteFut;
            code = watcher.pairs{i};
            legs = regexp(code,',','split');
            [~,idx1] = watcher.hassingle(legs{1});
            [~,idx2] = watcher.hassingle(legs{2});

            update_date = watcher.qs{idx1}.update_date1;
            %we choose the latest update time as of the update of
            %the pair
            update_time = max(watcher.qs{idx1}.update_time1,watcher.qs{idx2}.update_time1);
            %we always take the difference of the first leg and the
            %seond leg as of the last trade of the pair
            last_trade = watcher.qs{idx1}.last_trade-watcher.qs{idx2}.last_trade;
            %bid price is the price which to sell the pair, i.e.
            %sell the first leg and buy the second leg.
            bid = watcher.qs{idx1}.bid1 - watcher.qs{idx2}.ask1;
            %ask price is the price which to buy the pair, i.e.buy
            %the first leg and sell the seond leg
            ask = watcher.qs{idx1}.ask1 - watcher.qs{idx2}.bid1;
            q.update(code,update_date,update_time,last_trade,...
                bid,ask,NaN,NaN);
            quotes_pair{i} = q;
        end
        watcher.qp = quotes_pair;    
    end
end