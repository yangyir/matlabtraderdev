function [] = longclosesingleinstrument(strategy,ctp_code,lots)
    instrument = cOption(ctp_code);
    [f1, idx] = strategy.instruments_.hasinstrument(instrument);
    [f2,idxp] = strategy.portfolio_.hasinstrument(instrument);
    if f1&&f2
        volume = abs(strategy.portfolio_.instrument_list(idxp));
        if volume < lots
            error('cStratOpt:longclosesingleinstrument:input size exceeds existing size')
        end
        if volume >= 0
            error('cStratOpt:longclosesingleinstrument:existing short position not found')
        end
        isopt = isoptchar(ctp_code);
        e = Entrust;
        direction = 1;
        offset = -1;
        if isopt
            q = strategy.mde_opt_.qms_.getquote(ctp_code);
        else
            q = strategy.mde_fut_.qms_.getquote(ctp_code);
        end
        price = q.ask + strategy.askspread_(idx);
        e.fillEntrust(1,ctp_code,direction,price,lots,offset,ctp_code);
        strategy.entrusts_.push(e);
        ret = strategy.counter_.placeEntrust(e);
        if ret
            pnl = strategy.updateportfoliowithentrust(e); 
            strategy.pnl_close_(idx) = strategy.pnl_close_(idx) + pnl;
        end
    end
end
%end of longopensigleinstrument