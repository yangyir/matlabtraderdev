function [] = registerinstrument(strategy,instrument)
    if ischar(instrument)
        codestr = instrument;
    elseif isa(instrument,'cInstrument')
        codestr = instrument.code_ctp;
    else
        error('cStrat:registerinstrument:invalid instrument input')
    end

    if isempty(strategy.instruments_), strategy.instruments_ = cInstrumentArray;end
    %check whether the instrument is an option or not
    [optflag,~,~,underlierstr,~] = isoptchar(codestr);
    if optflag
        if isempty(strategy.underliers_), strategy.underliers_ = cInstrumentArray;end
        u = cFutures(underlierstr);
        u.loadinfo([underlierstr,'_info.txt']);
        strategy.underliers_.addinstrument(u);
    end
    if isa(instrument,'cInstrument')
        strategy.instruments_.addinstrument(instrument);
    elseif ischar(instrument)
        if optflag
            instrument = cOption(codestr);
            instrument.loadinfo([codestr,'_info.txt']);
            strategy.instruments_.addinstrument(instrument);
        else
            instrument = cFutures(codestr);
            instrument.loadinfo([codestr,'_info.txt']);
            strategy.instruments_.addinstrument(instrument);
        end
    end

    %pnl_stop_type_
    if isempty(strategy.pnl_stop_type_)
        strategy.pnl_stop_type_ = cell(strategy.count,1);
        for i = 1:strategy.count, strategy.pnl_stop_type_{i} = 'rel';end
    else
        if size(strategy.pnl_stop_type_,1) < strategy.count;
            type_ = cell(strategy.count,1);
            type_(1:size(strategy.pnl_stop_type_,1)) = strategy.pnl_stop_type_;
            type_{end} = 'rel';
            strategy.pnl_stop_type_ = type_;
        end
    end

    %pnl_stop_
    if isempty(strategy.pnl_stop_)
        strategy.pnl_stop_ = -inf*ones(strategy.count,1);
    else
        if size(strategy.pnl_stop_,1) < strategy.count
            strategy.pnl_stop_ = [strategy.pnl_stop_;-inf];
        end
    end

    %pnl_limit_type_
    if isempty(strategy.pnl_limit_type_)
        strategy.pnl_limit_type_ = cell(strategy.count,1);
        for i = 1:strategy.count, strategy.pnl_limit_type_{i} = 'rel';end
    else
        if size(strategy.pnl_limit_type_,1) < strategy.count;
            type_ = cell(strategy.count,1);
            type_(1:size(strategy.pnl_limit_type_,1)) = strategy.pnl_limit_type_;
            type_{end} = 'rel';
            strategy.pnl_limit_type_ = type_;
        end
    end

    %pnl_limit_
    if isempty(strategy.pnl_limit_)
        strategy.pnl_limit_ = inf*ones(strategy.count,1);
    else
        if size(strategy.pnl_limit_,1) < strategy.count
            strategy.pnl_limit_ = [strategy.pnl_limit_;inf];
        end
    end

    %pnl_running_
    if isempty(strategy.pnl_running_)
        strategy.pnl_running_ = zeros(strategy.count,1);
    else
        if size(strategy.pnl_running_,1) < strategy.count
            strategy.pnl_running_ = [strategy.pnl_running_;0];
        end
    end

    %pnl_close_
    if isempty(strategy.pnl_close_)
        strategy.pnl_close_ = zeros(strategy.count,1);
    else
        if size(strategy.pnl_close_,1) < strategy.count
            strategy.pnl_close_ = [strategy.pnl_close_;0];
        end
    end

    %bidspread_
    if isempty(strategy.bidspread_)
        strategy.bidspread_ = zeros(strategy.count,1);
    else
        if size(strategy.bidspread_,1) < strategy.count
            strategy.bidspread_ = [strategy.bidspread_;0];
        end
    end

    %askspread_
    if isempty(strategy.askspread_)
        strategy.askspread_ = zeros(strategy.count,1);
    else
        if size(strategy.askspread_,1) < strategy.count
            strategy.askspread_ = [strategy.askspread_;0];
        end
    end

    %autotrade_
    if isempty(strategy.autotrade_)
        strategy.autotrade_ = zeros(strategy.count,1);
    else
        if size(strategy.autotrade_,1) < strategy.count
            strategy.autotrade_ = [strategy.autotrade_;0];
        end
    end

    %mde_fut_
    if isempty(strategy.mde_fut_)
        strategy.mde_fut_ = cMDEFut;
        qms_fut_ = cQMS;
        if ~strcmpi(strategy.mode_,'debug')
            qms_fut_.setdatasource('ctp');
        else
            qms_fut_.setdatasource('local');
        end
        strategy.mde_fut_.qms_ = qms_fut_;
    end

    %mde_opt_
    if isempty(strategy.mde_opt_)
        strategy.mde_opt_ = cMDEOpt;
        qms_opt_ = cQMS;
        if ~strcmpi(strategy.mode_,'debug')
            qms_opt_.setdatasource('ctp');
        else
            qms_opt_.setdatasource('local');
        end
        strategy.mde_opt_.qms_ = qms_opt_;
    end

    if ~optflag
        strategy.mde_fut_.registerinstrument(instrument);
    else
        strategy.mde_fut_.registerinstrument(u);
        strategy.mde_opt_.registerinstrument(instrument);
    end
    
    if isempty(strategy.portfolio_)
        p = cPortfolio;
        strategy.portfolio_ = p;
    end
    
    if isempty(strategy.portfoliobase_)
        p = cPortfolio;
        strategy.portfoliobase_ = p;
    end
    
    try
        a =strategy.entrusts_.latest;
    catch
        strategy.entrusts_ = EntrustArray;
    end
    
    try
        a = strategy.entrustspending_.latest;
    catch
        strategy.entrustspending_ = EntrustArray;
    end
    
    try
        a = strategy.entrustsfinished_.latest;
    catch
        strategy.entrustsfinished_ = EntrustArray;
    end
    
end
%end of 'registerinstrument'