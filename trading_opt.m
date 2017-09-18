stratoptsinglestraddle = cStratOptSingleStraddle;
for i = 1:size(strikes_soymeal)
    stratoptsinglestraddle.registerinstrument(opt_c_m1801{i});
    stratoptsinglestraddle.registerinstrument(opt_p_m1801{i});
    %
    qms_ctp.registerinstrument(opt_c_m1801{i});
    qms_ctp.registerinstrument(opt_p_m1801{i});
end

%%
qms_ctp.refresh;
quotes = qms_ctp.getquote;
for i = 1:size(quotes,1)
    quotes{i}.print;
end

%%
stratoptsinglestraddle.querypositions(c_ly,qms_ctp);

%%
opt_savepositions(stratoptsinglestraddle.instruments_,stratoptsinglestraddle.underliers_,c_ly,qms_bbg)

%%
fn = 'opt_pos_20170918';
portfolio = opt_loadpositions(fn);