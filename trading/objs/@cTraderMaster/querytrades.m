function ret = querytrades(obj,querystr)
    isfut = strcmpi(querystr,'fut');
    isopt1 = strcmpi(querystr,'opt1');
    isopt2 = strcmpi(querystr,'opt2');
    
    if ~isfut && ~isopt1 && ~isopt2
        error('cTraderMaster:querycounter:input querystr shall be either fut,opt1 or opt2');
    end
    
    if isfut
        c = obj.counterfut_;
    end
    
    if isopt1
        c = obj.counteropt1_;
    end
    
    if isopt2
        c = obj.counteropt2_;
    end
    
    trades = c.queryTrades;
    n = size(trades,2);
    codes = cell(n,1);
    for i = 1:n, codes{i} = trades(i).asset_code;end
    codes = unique(codes);
    count = size(codes,1);
    px_long = zeros(count,1);
    px_short = zeros(count,1);
    vol_long = zeros(count,1);
    vol_short = zeros(count,1);
    for i = 1:n
        for j = 1:count
            if strcmpi(codes{j},trades(i).asset_code)
                idx = j;
                break
            end
        end
        if trades(i).direction == 1
            vol_old = vol_long(idx);
            vol_new = trades(i).volume;
            vol_long(idx) = vol_old + vol_new;
            px_long(idx) = px_long(idx)*vol_old+trades(i).trade_price*vol_new;
            px_long(idx) = px_long(idx)/vol_long(idx);
        else
            vol_old = vol_short(idx);
            vol_new = trades(i).volume;
            vol_short(idx) = vol_old + vol_new;
            px_short(idx) = px_short(idx)*vol_old+trades(i).trade_price*vol_new;
            px_short(idx) = px_short(idx)/vol_short(idx);
        end
    end
    
    fprintf('\n');
    fprintf('%s trades:\n',c.char);
    for i = 1:count
        fprintf('code: %12s;',codes{i});
        fprintf(' long: %3d;',vol_long(i));
        fprintf(' price: %9.2f;',px_long(i));
        fprintf(' short: %3d;',vol_short(i));
        fprintf(' price: %9.2f;',px_short(i));
        fprintf('\n');
    end
    
    ret = 1;
        
end

    
    