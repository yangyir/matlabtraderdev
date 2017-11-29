function [] = unwindposition(strategy,instrument)
if nargin < 1, return; end

%check whether the instrument has been registered with the
%strategy
[flag,idx_instrument] = strategy.instruments_.hasinstrument(instrument);
if ~flag, return; end

%check whether the instrument has been traded already
[flag,idx_portfolio] = strategy.portfolio_.hasinstrument(instrument);
if ~flag, return; end

code = instrument.code_ctp;

if ~strcmpi(strategy.mode_,'debug')
    strategy.withdrawentrusts(instrument);
end

isshfe = strcmpi(strategy.portfolio_.instrument_list{idx_portfolio}.exchange,'.SHF');
volume = strategy.portfolio_.instrument_volume(idx_portfolio);
tick = strategy.mde_fut_.getlasttick(instrument);
bid = tick(2);
ask = tick(3);
tick_size = strategy.portfolio_.instrument_list{idx_portfolio}.tick_size;
if volume > 0
    %place entrust with sell flag using the bid price
    price = bid - strategy.bidspread_(idx_instrument)*tick_size;
elseif volume < 0
    %place entrust with buy flag using the ask price
    price = ask + strategy.askspread_(idx_instrument)*tick_size;
end
%note:offset = -1 indicating unwind positions
offset = -1;

if strcmpi(strategy.mode_,'debug')
    %update portfolio and pnl_close_ as required in the
    %following
    %assuming the entrust is completely filled in debug mode
    t = cTransaction;
    t.instrument_ = strategy.portfolio_.instrument_list{idx_portfolio};
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
    e = Entrust;
    e.assetType = 'Future';
    e.fillEntrust(1,code,-sign(volume),price,abs(volume),offset,code);
    ret = strategy.counter_.placeEntrust(e);
    if ret
        strategy.entrusts_.push(e);
        %                     t = cTransaction;
        %                     t.instrument_ = instrument;
        %                     t.price_ = price;
        %                     t.volume_ = abs(volume);
        %                     t.direction_ = -sign(volume);
        %                     t.offset_ = offset;
        %                     t.datetime1_ = now;
        %                     pnl = obj.portfolio_.updateportfolio(t);
        pnl = updateportfoliowithentrust(strategy,e);
        strategy.pnl_close_(idx_instrument) = strategy.pnl_close_(idx_instrument) + pnl;
    end
else
    volume_today = strategy.portfolio_.instrument_volume_today(idx_portfolio);
    volume_before = volume - volume_today;
    if volume_today ~= 0
        e = Entrust;
        e.assetType = 'Future';
        e.fillEntrust(1,code,-sign(volume_today),price,abs(volume_today),offset,code);
        e.closetodayFlag = 1;
        ret = strategy.counter_.placeEntrust(e);
        if ret
            %                         obj.entrusts_.push(e);
            %                         t = cTransaction;
            %                         t.instrument_ = instrument;
            %                         t.price_ = price;
            %                         t.volume_ = abs(volume_today);
            %                         t.direction_ = -sign(volume_today);
            %                         t.offset_ = offset;
            %                         t.datetime1_ = now;
            %                         pnl = obj.portfolio_.updateportfolio(t);
            pnl = updateportfoliowithentrust(strategy,e);
            strategy.pnl_close_(idx_instrument) = strategy.pnl_close_(idx_instrument) + pnl;
        end
    end
    if volume_before ~= 0
        e = Entrust;
        e.assetType = 'Future';
        e.multiplier = multi;
        e.fillEntrust(1,code,-sign(volume_before),price,abs(volume_before),offset,code);
        ret = strategy.counter_.placeEntrust(e);
        if ret
            strategy.entrusts_.push(e);
            %                         t = cTransaction;
            %                         t.instrument_ = instrument;
            %                         t.price_ = price;
            %                         t.volume_ = abs(volume_before);
            %                         t.direction_ = -sign(volume_before);
            %                         t.offset_ = offset;
            %                         t.datetime1_ = now;
            %                         pnl = obj.portfolio_.updateportfolio(t);
            pnl = updateportfoliowithentrust(strategy,e);
            strategy.pnl_close_(idx_instrument) = strategy.pnl_close_(idx_instrument) + pnl;
        end
    end
end
end
%end of unwindpositions