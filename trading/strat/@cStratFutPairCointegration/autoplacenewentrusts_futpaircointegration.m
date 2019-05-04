function [] = autoplacenewentrusts_futpaircointegration(strategy,signals)
%cStratFutPairCointegration
%     return
    if isempty(strategy.helper_), error('%s::autoplacenewentrusts::missing helper!!!',class(strategy));end
    
    if isempty(signals), return;end
    
    n = strategy.count;
    volume_exist = zeros(n,1);
    instruments = strategy.getinstruments;
    %step 1:check whether there are any existing positions
    for i = 1:n
        try
            [flag,idx] = strategy.helper_.book_.hasposition(instruments{i});
        catch
            flag = false;
            idx = 0;
        end
        if ~flag
            volume_exist(i) = 0;
        else
            pos = strategy.helper_.book_.positions_{idx};
            volume_exist(i) = pos.position_total_ * pos.direction_;
        end
    end
    
    emptybook = true;
    for i = 1:n
        if volume_exist(i) ~= 0
            emptybook = false;
            break
        end
    end
    
    directions = zeros(2,1);
    directions(1) = signals{1}.direction;
    directions(2) = signals{2}.direction;
    
    nullsignal = directions(1) == 0 && directions(2) == 0;
            
    if emptybook && nullsignal, return; end
    
    if ~emptybook && nullsignal
        %unwind existing trades
        ntrades = strategy.helper_.trades_.latest_;
        trade1 = {};
        trade2 = {};
        for itrade = 1:ntrades
            trade_i = strategy.helper_.trades_.node_(itrade);
            if strcmpi(trade_i.status_,'closed'), continue; end
            if strcmpi(trade_i.code_,instruments{1}.code_ctp),trade1 = trade_i; continue;end
            if strcmpi(trade_i.code_,instruments{2}.code_ctp),trade2 = trade_i; continue;end
        end
        
        if ~isempty(trade1) && ~isempty(trade2)
            strategy.unwindtrade(trade1);
            strategy.unwindtrade(trade2);
        end
        
        return
    end
    
    if emptybook && ~nullsignal
        %as market may opens with big volatility, we shall pass this time
        %for trading? sometimes we will miss the tick as it moves too fast
        calcsignalbucket = strategy.getcalcsignalbucket(signals{strategy.referencelegindex_}.instrument);
        if calcsignalbucket == 1
            return
        end
                
        volume2trade = zeros(2,1);
        coeffs = zeros(2,1);
        bid = zeros(2,1);
        ask = zeros(2,1);
        ticktime = zeros(2,1);
%         rmse = signals{1}.rmse;
        for i = 1:2
            signal = signals{i};
            instrument = signal.instrument;
            autotrade = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','autotrade');
            if ~autotrade, return; end
    
            tick = strategy.mde_fut_.getlasttick(instrument);
            if isempty(tick), return; end
            if abs(tick(2)) > 1e10 || abs(tick(3)) > 1e10, return; end
            bid(i) = tick(2);
            ask(i) = tick(3);
            ticktime(i) = tick(1);
        
            if i == 1
                coeffs(i) = signal.coeff(2);
            else
                coeffs(i) = 1;
            end
        
            volume2trade(i) = strategy.volumescalefactor_ * coeffs(i);
            volume2trade(i) = ceil(volume2trade(i)); 
        end
                 
        if directions(1) < 0 && directions(2) > 0            
            strategy.shortopen(signals{1}.instrument.code_ctp,volume2trade(1),...
                'overrideprice',bid(1),'time',ticktime(1),'signalinfo',signals{1});
            strategy.longopen(signals{2}.instrument.code_ctp,volume2trade(2),...
                        'overrideprice',ask(2),'time',ticktime(2),'signalinfo',signals{2});        
            return
        end
        %
        if directions(1) > 0 && directions(2) < 0
            strategy.longopen(signals{1}.instrument.code_ctp,volume2trade(1),...
                        'overrideprice',ask(1),'time',ticktime(1),'signalinfo',signals{1});
            strategy.shortopen(signals{2}.instrument.code_ctp,volume2trade(2),...
                        'overrideprice',bid(2),'time',ticktime(2),'signalinfo',signals{2});        
            return
        end
        
        return
        
    end
    
    if ~emptybook && ~nullsignal
        %in case the existing positions have the same direction as the
        %signal, we simply do nothing
        if (volume_exist(1) > 0 && directions(1) > 0) && (volume_exist(2) < 0 && directions(2) < 0), return;end
        if (volume_exist(1) < 0 && directions(1) < 0) && (volume_exist(2) > 0 && directions(2) > 0), return;end
        
        if (volume_exist(1) > 0 && directions(1) < 0) && (volume_exist(2) < 0 && directions(2) > 0)
            fprintf('not implemented yet!!!\n')
        end
        
        if (volume_exist(1) < 0 && directions(1) > 0) && (volume_exist(2) > 0 && directions(2) < 0)
            fprintf('not implemented yet!!!\n')
        end
        
        return
        
    end
        
    return
    
end