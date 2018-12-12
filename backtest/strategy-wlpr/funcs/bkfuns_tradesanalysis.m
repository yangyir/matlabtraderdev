function [output] = bkfuns_tradesanalysis(trades,candles,varargin)
    %1.analysis trades pnl distribution after a series of time bucket
    ntrades = trades.latest_;
    pnl1 = zeros(ntrades,20);
    for i = 1:ntrades
        trade_i = trades.node_(i);
        if strcmpi(trade_i.opensignal_.wrmode_,'classic')
            opentime = trade_i.opendatetime1_;
            idx = find(candles(:,1) < opentime,1,'last');
            
            
            for j = 1:size(pnl1,2)
                pnl1(i,j) = trade_i.opendirection_*(candles(idx+j-1,5)-trade_i.openprice_);
            end
        else
            continue;
            %to be implemented
        end
    end
    
    output.pnl1 = pnl1;
end
%%
