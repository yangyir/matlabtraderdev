function [] = saveportfoliotofile(strategy,fn,clearportfolio)
    if nargin < 3
        clearportfolio = 0;
    end
    fid = fopen(fn,'w');
    for i = 1:strategy.portfolio_.count;
        pos_i = strategy.portfolio_.pos_list{i};
        code_i = pos_i.code_ctp_;
        direction_i = pos_i.direction_;
        v_i = direction_i*pos_i.position_total_;
        cost_carry_i = pos_i.cost_carry_;
        cost_open_i = pos_i.cost_open_;
        fprintf(fid,'%s\t%d\t%f\t%f\n',code_i,v_i,cost_carry_i,cost_open_i);
    end
    fclose(fid);
    if clearportfolio
        strategy.portfoliobase_ = cPortfolio;
        strategy.portfolio_ = cPortfolio;
    end
end
%end of saveportfoliotofile