function [] = saveportfoliotofile(strategy,fn,clearportfolio)
    if nargin < 3
        clearportfolio = 0;
    end
    fid = fopen(fn,'w');
    for i = 1:strategy.portfolio_.count;
        code_i = strategy.portfolio_.instrument_list{i}.code_ctp;
        p_i = strategy.portfolio_.instrument_volume(i);
        cost_i = strategy.portfolio_.instrument_avgcost(i);
        fprintf(fid,'%s\t%d\t%f\n',code_i,p_i,cost_i);
    end
    fclose(fid);
    if clearportfolio
        strategy.portfoliobase_ = cPortfolio;
        strategy.portfolio_ = cPortfolio;
    end
end
%end of saveportfoliotofile