function [] = start(strategy)
    strategy.settimer;
    if isempty(strategy.portfolio_)
        strategy.portfolio_ = cPortfolio;
    end
    start(strategy.timer_);
end


