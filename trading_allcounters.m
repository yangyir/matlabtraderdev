%%
login_counter_fut;
login_counter_opt1;
login_counter_opt2;
%%
init_mde;
%%
instrument_list = {'cu1807';'al1807';'zn1807';'pb1807';'ni1807';...
    'rb1810';'i1809';...
    'TF1809';'T1809'};
%%
strat_citic = init_stratmanual('counter',c_fut,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
strat_ccb = init_stratmanual('counter',c_opt1,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
strat_huaxin = init_stratmanual('counter',c_opt2,'mdefut',mdefut,'instrumentlist',instrument_list,'positionfrom','counter','futlist','all');
%%
mdefut.start;
%%
strat_citic.helper_.start;
strat_citic.start;
strat_ccb.helper_.start;
strat_ccb.start;
strat_huaxin.helper_.start;
strat_huaxin.start;
%%
strat_citic.helper_.printrunningpnl('mdefut',mdefut)
%%
strat_ccb.helper_.printrunningpnl('mdefut',mdefut)
%%
strat_huaxin.helper_.printrunningpnl('mdefut',mdefut)
%%
mdefut.stop
strat_citic.helper_.stop;
strat_citic.stop;
strat_ccb.helper_.stop;
strat_ccb.stop;
strat_huaxin.helper_.stop;
strat_huaxin.stop;
delete(timerfindall);
%%
logoff_counters;
