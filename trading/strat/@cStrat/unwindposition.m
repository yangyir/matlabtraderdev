function [] = unwindposition(strategy,instrument)
    if nargin < 1, return; end

    %check whether the instrument has been registered with the
    %strategy
    [flag,idx_instrument] = strategy.instruments_.hasinstrument(instrument);
    if ~flag, return; end

    %check whether the instrument has been traded already
    [flag,idx_portfolio] = strategy.portfolio_.hasposition(instrument);
    if ~flag, return; end

    code = instrument.code_ctp;

    if ~strcmpi(strategy.mode_,'debug'), strategy.withdrawentrusts(instrument);end

    isshfe = strcmpi(strategy.portfolio_.pos_list{idx_portfolio}.instrument_.exchange,'.SHF');
    volume = strategy.portfolio_.pos_list{idx_portfolio}.direction_ * strategy.portfolio_.pos_list{idx_portfolio}.position_total_;

    if strcmpi(strategy.mode_,'debug')
        %update portfolio and pnl_close_ as required in the
        %following
        %assuming the entrust is completely filled in debug mode
        tick = strategy.mde_fut_.getlasttick(instrument);
        bid = tick(2);
        ask = tick(3);
        tick_size = strategy.portfolio_.pos_list{idx_portfolio}.instrument_.tick_size;
        if volume > 0
            %place entrust with sell flag using the bid price
            price = bid - strategy.bidspread_(idx_instrument)*tick_size;
        elseif volume < 0
            %place entrust with buy flag using the ask price
            price = ask + strategy.askspread_(idx_instrument)*tick_size;
        end
        offset = -1;
        t = cTransaction;
        t.instrument_ = strategy.portfolio_.pos_list{idx_portfolio}.instrument_;
        t.price_ = price;
        t.volume_= abs(volume);
        t.direction_ = -sign(volume);
        t.offset_ = offset;
        pnl = strategy.portfolio_.updateportfolio(t);
        strategy.pnl_close_(idx_instrument) = strategy.pnl_close_(idx_instrument) + pnl;
        return
    end

    %for 'realtime' mode
    if ~isshfe
        if volume > 0
            strategy.shortclosesingleinstrument(code,volume);
        elseif volume < 0
            strategy.longclosesingleinstrument(code,-volume);
        end
    else
        volume_today = strategy.portfolio_.pos_list{idx_portfolio}.direction_ * strategy.portfolio_.pos_list{idx_portfolio}.position_today_;
%         volume_today = strategy.portfolio_.instrument_volume_today(idx_portfolio);
        volume_before = volume - volume_today;
        if volume_today ~= 0
            if volume_today > 0
                strategy.shortclosesingleinstrument(code,volume_today,1);
            elseif volume_today < 0
                strategy.longclosesingleinstrument(code,-volume_today,1);
            end
        end
        if volume_before ~= 0
            if volume_before > 0
                strategy.shortclosesingleinstrument(code,volume_before);
            elseif volume_before < 0
                strategy.longtclosesingleinstrument(code,-volume_before);
            end

        end
    end
end
%end of unwindpositions