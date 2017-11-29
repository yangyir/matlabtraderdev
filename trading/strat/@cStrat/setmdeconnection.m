function [] = setmdeconnection(strategy,connstr)
    if ~(strcmpi(connstr,'bloomberg') || strcmpi(connstr,'ctp'))
        error('cStrat:setmdeconnection:invalid connstr input')
    end

    if isempty(strategy.mde_fut_)
        strategy.mde_fut_ = cMDEFut;
        qms_fut_ = cQMS;
        qms_fut_.setdatasource(connstr);
        strategy.mde_fut_.qms_ = qms_fut_;
    else
        strategy.mde_fut_.qms_.setdatasource(connstr);
    end

    %mde_opt_
    if isempty(strategy.mde_opt_)
        strategy.mde_opt_ = cMDEOpt;
        qms_opt_ = cQMS;
        qms_opt_.setdatasource(connstr);
        strategy.mde_opt_.qms_ = qms_opt_;
    else
        strategy.mde_opt_.qms_.setdatasource(connstr);
    end
end
%end setmdeconnection