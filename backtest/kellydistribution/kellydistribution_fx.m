names_fx = {'usdx';'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';...
    'eurjpy';'eurchf';'gbpeur';'gbpjpy';'audjpy';...
    'usdcnh'};

output_daily_fx = fractal_kelly_summary('codes',names_fx,...
    'frequency','daily','usefractalupdate',0,'usefibonacci',1,'direction','both');
%%
[reportbyasset_tc_fx,reportbyasset_tb_fx] = kellydistrubitionsummary(output_daily_fx);
%%
[dmat,dstruct] = tools_technicalplot1(output_daily_fx.data{1}.px,2,false);
tools_technicalplot2(dmat(end-42:end,:),3,names_fx{1},true);