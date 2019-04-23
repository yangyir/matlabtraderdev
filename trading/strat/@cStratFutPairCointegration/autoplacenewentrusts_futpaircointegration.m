function [] = autoplacenewentrusts_futpaircointegration(strategy,signals)
%cStratFutPairCointegration
    if isempty(strategy.helper_), error('%s::autoplacenewentrusts::missing helper!!!',class(strategy));end
    
    if isempty(signals), return; end
    
    %step 1:check whether there are any existing positions
    volume_exist = zeros(2,1);
    volume2trade = zeros(2,1);
    coeffs = zeros(2,1);
    directions = zeros(2,1);
    rmse = signals{1}.rmse;
    for itrade = 1:2
        signal = signals{itrade};
        instrument = signal.instrument;
        autotrade = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','autotrade');
        if ~autotrade, return; end
    
        tick = strategy.mde_fut_.getlasttick(instrument);
        if isempty(tick), return; end
        if abs(tick(2)) > 1e10 || abs(tick(3)) > 1e10, return; end
        
        if itrade == 1
            coeffs(itrade) = signal.coeff(2);
        else
            coeffs(itrade) = 1;
        end
        directions(itrade) = signal.direction;
        
        volume2trade(itrade) = strategy.volumescalefactor_ * coeffs(itrade);
        volume2trade(itrade) = ceil(volume2trade(itrade));
        
        try
            [flag,idx] = strategy.helper_.book_.hasposition(instrument);
        catch
            flag = false;
            idx = 0;
        end
        if ~flag
            volume_exist(itrade) = 0;
        else
            pos = strategy.helper_.book_.positions_{idx};
            volume_exist(itrade) = pos.position_total_ * pos.direction_;
        end
    end
    
    if volume_exist(1) == 0 && volume_exist(2) == 0
        %as market may opens with big volatility, we shall pass this time
        %for trading?
        calcsignalbucket = strategy.getcalcsignalbucket(signals{strategy.referencelegindex_}.instrument);
        if calcsignalbucket == 1
            return
        end
        
        tick1 = strategy.mde_fut_.getlasttick(signals{1}.instrument);
        tick2 = strategy.mde_fut_.getlasttick(signals{2}.instrument);
        %make sure the signal is still valid as some prices jump on open
        %from last close
        indicator = tick1(4) - (signals{1}.coeff(1) + signals{1}.coeff(2)*tick2(4));
        indicator = indicator / rmse;
        if directions(1) < 0 && directions(2) > 0 && indicator > strategy.upperbound_
            %double check the signal is still valid, i.e. indicator above
            %lowerbound
            strategy.shortopen(signals{1}.instrument.code_ctp,volume2trade(1),...
                'overrideprice',tick1(2),'time',tick1(1),'signalinfo',signals{1});
            strategy.longopen(signals{2}.instrument.code_ctp,volume2trade(2),...
                        'overrideprice',tick2(3),'time',tick2(1),'signalinfo',signals{2});        
            return
        end
        %
        if directions(1) > 0 && directions(2) < 0 && indicator < strategy.lowerbound_
            %double check the signal is still valid, i.e. indicator below
            %lowerbound
            strategy.longopen(signals{1}.instrument.code_ctp,volume2trade(1),...
                        'overrideprice',tick1(3),'time',tick1(1),'signalinfo',signals{1});
            strategy.shortopen(signals{2}.instrument.code_ctp,volume2trade(2),...
                        'overrideprice',tick2(2),'time',tick2(1),'signalinfo',signals{2});        
            
            return
        end
        return
    end
    
    if volume_exist(1) ~= 0 && volume_exist(2) ~= 0
        %add a risk-management here which shall be replaced under
        %riskmanagement method of the strategy itself
        tick1 = strategy.mde_fut_.getlasttick(signals{1}.instrument);
        tick2 = strategy.mde_fut_.getlasttick(signals{2}.instrument);
        %make sure the signal is still valid as some prices jump on open
        %from last close
        indicator = tick1(4) - (signals{1}.coeff(1) + signals{1}.coeff(2)*tick2(4));
        indicator = indicator / rmse;
        
        if (volume_exist(1) > 0 && volume_exist(2) < 0 && indicator > strategy.lowerbound_)  ||...
                (volume_exist(1) < 0 && volume_exist(2) > 0 && indicator < strategy.upperbound_)
            ntrades = strategy.helper_.trades_.latest_;
            trade1 = {};
            trade2 = {};
            for itrade = 1:ntrades
                trade_i = strategy.helper_.trades_.node_(itrade);
                if strcmpi(trade_i.status_,'closed'), continue; end
                if strcmpi(trade_i.code_,signals{1}.instrument.code_ctp),trade1 = trade_i; continue;end
                if strcmpi(trade_i.code_,signals{2}.instrument.code_ctp),trade2 = trade_i; continue;end
            end
            if ~isempty(trade1) && ~isempty(trade2)
                strategy.unwindtrade(trade1);
                strategy.unwindtrade(trade2);
            end
        end
        
        
        return
    end
    
    return
%     error('%s::autoplacenewentrusts::internal error!!!',class(strategy));
    
end