function [] = unwindposition(strategy,instrument,spread)
    if nargin < 1, return; end

    %check whether the instrument has been registered with the
    %strategy
%     [flag,idx_instrument] = strategy.instruments_.hasinstrument(instrument);
    flag = strategy.instruments_.hasinstrument(instrument);
    if ~flag, return; end

    %check whether the instrument has been traded already
    [flag,idx_book] = strategy.bookrunning_.hasposition(instrument);
    if ~flag, return; end

    code = instrument.code_ctp;

%     if ~strcmpi(strategy.mode_,'debug'), strategy.withdrawentrusts(instrument);end
    strategy.withdrawentrusts(instrument);

    isshfe = strcmpi(strategy.bookrunning_.positions_{idx_book}.instrument_.exchange,'.SHF');
    volume = strategy.bookrunning_.positions_{idx_book}.direction_ * strategy.bookrunning_.positions_{idx_book}.position_total_;

%     if strcmpi(strategy.mode_,'replay')
%         %update portfolio and pnl_close_ as required in the
%         %following
%         %assuming the entrust is completely filled in debug mode
%         tick = strategy.mde_fut_.getlasttick(instrument);
%         bid = tick(2);
%         ask = tick(3);
%         tick_size = strategy.bookrunning_.positions_{idx_book}.instrument_.tick_size;
%         if volume > 0
%             %place entrust with sell flag using the bid price
%             if nargin < 3
%                 price = bid - strategy.bidspread_(idx_instrument)*tick_size;
%             else
%                 price = bid - spread*tick_size;
%             end
%         elseif volume < 0
%             %place entrust with buy flag using the ask price
%             if nargin < 3
%                 price = ask + strategy.askspread_(idx_instrument)*tick_size;
%             else
%                 price = bid + spread*tick_size;
%             end
%         end
%         offset = -1;
%         t = cTransaction;
%         t.instrument_ = strategy.portfolio_.pos_list{idx_book}.instrument_;
%         t.price_ = price;
%         t.volume_= abs(volume);
%         t.direction_ = -sign(volume);
%         t.offset_ = offset;
%         pnl = strategy.portfolio_.updateportfolio(t);
%         strategy.pnl_close_(idx_instrument) = strategy.pnl_close_(idx_instrument) + pnl;
%         return
%     end

    %for 'realtime' mode
%     spread = 0;
    if ~isshfe
        if volume > 0
            strategy.shortclosesingleinstrument(code,volume,spread);
        elseif volume < 0
            strategy.longclosesingleinstrument(code,-volume,spread);
        end
    else
        volume_today = strategy.bookrunning_.positions_{idx_book}.direction_ * strategy.bookrunning_.positions_{idx_book}.position_today_;
        volume_before = volume - volume_today;
        if volume_today ~= 0
            if volume_today > 0
                strategy.shortclosesingleinstrument(code,volume_today,1,spread);
            elseif volume_today < 0
                strategy.longclosesingleinstrument(code,-volume_today,1,spread);
            end
        end
        if volume_before ~= 0
            if volume_before > 0
                strategy.shortclosesingleinstrument(code,volume_before,0,spread);
            elseif volume_before < 0
                strategy.longclosesingleinstrument(code,-volume_before,0,spread);
            end

        end
    end
end
%end of unwindpositions