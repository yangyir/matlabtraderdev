function [] = longopensingleinstrument(strategy,ctp_code,lots)
    instrument = cOption(ctp_code);
    [bool, idx] = strategy.instruments_.hasinstrument(instrument);
    %only place entrusts in case the instrument has been registered
    %with the strategy
    if bool
        isopt = isoptchar(ctp_code);
        e = Entrust;
        direction = 1;
        offset = 1;
        if isopt
            q = strategy.mde_opt_.qms_.getquote(ctp_code);
        else
            q = strategy.mde_fut_.qms_.getquote(ctp_code);
        end
        price = q.ask + strategy.askspread_(idx);
        e.fillEntrust(1,ctp_code,direction,price,lots,offset,ctp_code);
        strategy.entrusts_.push(e);
        ret = strategy.counter_.placeEntrust(e);
        if ret, strategy.updateportfoliowithentrust(e); end
    end
end
%end of longopensigleinstrument