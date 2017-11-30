function [] = loadportfoliofromfile(strategy,fn,dateinput)
    if nargin < 3
        strategy.portfoliobase_ = opt_loadpositions(fn);
    else
        strategy.portfoliobase_ = opt_loadpositions(fn,dateinput);
    end

    n = strategy.portfoliobase_.count;
    list_ = strategy.portfoliobase_.instrument_list;
    volume_ = strategy.portfoliobase_.instrument_volume;
    cost_ = strategy.portfoliobase_.instrument_avgcost;

    %copy the portfoliobase_ to portfolio_
    strategy.portfolio_ = cPortfolio;
    for i = 1:n
        strategy.portfolio_.addinstrument(list_{i},cost_(i),volume_(i),getlastbusinessdate);
    end

end
%end of loadportfoliofromfile