names_basemetals = {'lmecopper';'lmealuminum';'lmezinic';'lmelead';'lmenickel';'lmetin'};

output_daily_basemetals = fractal_kelly_summary('codes',names_basemetals,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[reportbyasset_tc_basemetals,reportbyasset_tb_basemetals] = kellydistrubitionsummary(output_daily_basemetals);
%%


