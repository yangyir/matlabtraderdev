function [] = loadportfoliofromfile(strategy,fn,dateinput)
    if nargin < 3
        strategy.portfoliobase_ = opt_loadpositions(fn);
        strategy.portfolio_ = opt_loadpositions(fn);
    else
        strategy.portfoliobase_ = opt_loadpositions(fn,dateinput);
        strategy.portfolio_ = opt_loadpositions(fn,dateinput);
    end

end
%end of loadportfoliofromfile