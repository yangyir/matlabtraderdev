function [] = riskmanagement_futmultiwr(strategy,dtnum)
    if isempty(strategy.counter_) && ~strcmpi(strategy.mode_,'debug'), return; end

    instruments = strategy.instruments_.getinstrument;
    for i = 1:strategy.count
        %firstly to check whether this is in trading hours
        ismarketopen = istrading(dtnum,instruments{i}.trading_hours,...
            'tradingbreak',instruments{i}.trading_break);
        if ~ismarketopen, continue; end

        %secondly to check whether the instrument has been traded
        %and recorded in the embedded portfolio
        [isinstrumenttraded,idx] = strategy.portfolio_.hasposition(instruments{i});

        if ~isinstrumenttraded, continue; end

        %calculate running pnl in case the embedded porfolio has
        %got the instrument already

        position = strategy.portfolio_.pos_list{idx};
        volume = position.direction_*position.position_total_;
        cost = position.cost_carry_;
        strategy.calcrunningpnl(instruments{i});

        %                     pnl_ = obj.pnl_running_(i) + obj.pnl_close_(i);
        pnl_ = strategy.pnl_running_(i);

        multi = instruments{i}.contract_size;
        if ~isempty(strfind(instruments{i}.code_bbg,'TFC')) ||...
                ~isempty(strfind(instruments{i}.code_bbg,'TFT'))
            multi = multi/100;
        end

        margin = instruments{i}.init_margin_rate;
        if isempty(margin), margin = 0.1;end

        if strcmpi(strategy.pnl_limit_type_{i},'rel')
            limit_ = strategy.pnl_limit_(i)*cost*abs(volume)*multi*margin;
        else
            limit_ = strategy.pnl_limit_(i);
        end

        if strcmpi(strategy.pnl_stop_type_{i},'rel')
            stop_ = -strategy.pnl_stop_(i)*cost*abs(volume)*multi*margin;
        else
            stop_ = -strategy.pnl_stop_(i);
        end

        % in case the pnl has either breach the limit or
        % the stop level, we will unwind the existing
        % positions
        if pnl_ >= limit_ || pnl_ <= stop_
            strategy.unwindposition(instruments{i});
        end
    end

end
%end of riskmangement