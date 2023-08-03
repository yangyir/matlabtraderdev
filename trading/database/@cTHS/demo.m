ths = cTHS;
%%
d = ths.history('510300','open;high;low;close','2023-07-01','2023-08-03');
%%
d2 = ths.intradaybar('510300','2023-07-31','2023-08-03',30,'trade');
%%
d3 = ths.realtime('USDJPY.FX,EURUSD.FX','latest');
disp(d3);