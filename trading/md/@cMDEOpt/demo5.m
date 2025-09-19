mdeopt = cMDEOpt;

mdeopt.registerinstrument('MO2509-C-7400')

fn1 = 'C:\Users\yiran\OneDrive\matlabdatabase\ticks\IM2509\IM2509_20250916_tick.txt';

fn2 = 'C:\Users\yiran\OneDrive\matlabdatabase\ticks\MO2509-C-7400\MO2509-C-7400_20250916_tick.txt';

mdeopt.initreplayer('code','MO2509-C-7400','fn',fn2);
mdeopt.initreplayer('code','IM2509','fn',fn1);
%%
mdeopt.setcandlefreq(5,'IM2509');
mdeopt.setcandlefreq(5,'MO2509-C-7400');
%%
mdeopt.initcandles;