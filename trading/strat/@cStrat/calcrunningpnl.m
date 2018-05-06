function pnl = calcrunningpnl(strategy, instrument)
    if ~isa(instrument,'cInstrument')
        error('cStrat:calcrunningpnl:invalid instrument input')
    end

    %to check whether the instrument has been already traded or not
    [flag,idx] = strategy.bookrunning_.hasposition(instrument);

    pnl = 0;
    if flag
        pos = strategy.bookrunning_.positions_{idx};
        volume = pos.direction_ * pos.position_total_;
        [~,ii] = strategy.instruments_.hasinstrument(instrument);

        if volume == 0
            strategy.pnl_running_(ii) = pnl;
            return
        end

        cost = pos.cost_carry_;
        if isa(instrument,'cFutures')
            tick = strategy.mde_fut_.getlasttick(instrument);
        else
            q = strategy.mde_opt_.qms_.getquote(instrument);
            tick(1) = q.last_trade;
            tick(2) = q.bid1;
            tick(3) = q.ask1;
        end
        if isempty(tick)
            strategy.pnl_running_(ii) = pnl;
            return
        end

        bid = tick(2);
        ask = tick(3);
        if bid == 0 || ask == 0
            strategy.pnl_running_(ii) = pnl;
            return
        end

        multi = instrument.contract_size;
        if ~isempty(strfind(instrument.code_bbg,'TFC')) || ~isempty(strfind(instrument.code_bbg,'TFT'))
            multi = multi/100;
        end

        %the running pnl is the pnl in case the positions are
        %completely unwind
        if volume > 0
            pnl = (bid-cost)*volume*multi;
        elseif volume < 0
            pnl = (ask-cost)*volume*multi;
        end
        strategy.pnl_running_(ii) = pnl;

    end

end
%end of calcrunningpnl