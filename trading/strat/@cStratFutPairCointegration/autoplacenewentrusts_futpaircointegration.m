function [] = autoplacenewentrusts_futpaircointegration(strategy,signals)
%cStratFutPairCointegration
    if isempty(strategy.helper_), error('%s::autoplacenewentrusts::missing helper!!!',class(strategy));end
    
    if isempty(signals), return; end
    
    volume_exist = zeros(2,1);
    for i = 1:2
        signal = signals{1};
        instrument = signal.instrument;
        autotrade = strategy.riskcontrols_.getconfigvalue('code',instrument.code_ctp,'propname','autotrade');
        if ~autotrade, return; end
        try
            [flag,idx] = strategy.helper_.book_.hasposition(instrument);
        catch
            flag = false;
            idx = 0;
        end
        if ~flag
            volume_exist(i) = 0;
        else
            pos = strategy.helper_.book_.positions_{idx};
            volume_exist(i) = pos.position_total_;
        end
    end
    
    
    if volume_exist(1) == 0 && volume_exist(2) == 0
        for i = 1:2
            
        end
        
        
    elseif volume_exist(1) ~= 0 && volume_exist(2) ~= 0
    else
        error('%s::autoplacenewentrusts::internal error!!!',class(strategy));
    end
    
    

    return
end