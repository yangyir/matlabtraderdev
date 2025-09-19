%%
% replay demo
mdeopt = cMDEOpt;
mdeopt.registerinstrument('MO2509-C-7400');
mdeopt.registerinstrument('MO2509-P-7400');
fn1 = [getenv('datapath'),'ticks\IM2509\IM2509_20250916_tick.txt'];
fn2 = [getenv('datapath'),'ticks\MO2509-C-7400\MO2509-C-7400_20250916_tick.txt'];
fn3 = [getenv('datapath'),'ticks\MO2509-P-7400\MO2509-P-7400_20250916_tick.txt'];
mdeopt.initreplayer('code','MO2509-C-7400','fn',fn2);
mdeopt.initreplayer('code','MO2509-P-7400','fn',fn3);
mdeopt.initreplayer('code','IM2509','fn',fn1);
mdeopt.setcandlefreq(5,'IM2509');
mdeopt.setcandlefreq(5,'MO2509-C-7400');
mdeopt.setcandlefreq(5,'MO2509-P-7400');
mdeopt.initcandles;

%%
% real-time demo
mdeopt = cMDEOpt;
mdeopt.registerinstrument('MO2510-C-7400');
mdeopt.registerinstrument('MO2510-P-7400');
mdeopt.setcandlefreq(5,'IM2510');
mdeopt.setcandlefreq(5,'MO2510-C-7400');
mdeopt.setcandlefreq(5,'MO2510-P-7400');
mdeopt.initcandles;