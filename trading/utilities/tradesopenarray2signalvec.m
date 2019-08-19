function signalvec = tradesopenarray2signalvec(tradesin,p)
    n = size(p,1);
    signalvec = zeros(n,1);
    %
    ntrade = tradesin.latest_;
    for i = 1:ntrade
        trade_i = tradesin.node_(i);
        vec_i = zeros(n,1);
        opentime_i = trade_i.opendatetime1_;
        closetime_i = trade_i.closedatetime1_;
        
        openidx_i = find(p(:,1) == opentime_i);
        if isempty(closetime_i)
            closeidx_i = n;
            vec_i(closeidx_i,1) = direction_i;
        else
            closeidx_i = find(p(:,1) == closetime_i);
            vec_i(closeidx_i,1) = 0;
        end
        
        direction_i = trade_i.opendirection_;
        vec_i(openidx_i:closeidx_i-1,1) = direction_i;
        signalvec = signalvec + vec_i;
    end
end