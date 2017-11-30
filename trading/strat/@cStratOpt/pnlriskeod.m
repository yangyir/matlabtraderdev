function [pnltbl,risktbl] = pnlriskeod(stratopt)

    pnltbl = cHelper.pnlrisk1(stratopt.portfoliobase_,getlastbusinessdate);

    %the carry risk of the latest portfolio
    [~,risktbl] = cHelper.pnlrisk1(stratopt.portfolio_,getlastbusinessdate);

end
%end of pnlriskeod