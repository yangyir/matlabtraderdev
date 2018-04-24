%%
yiran = cTrader;
yiran.init('yiran');
yiran.addbook(b4);
%%
yiran.books_{1}.printpositions;

%%
ops = cOps;
ops.init('ops1',b4);
ops.timer_interval_ = 10;

%%
ops.start;
%%
ops.stop;
%%
[ret,e] =  yiran.placeorder('T1806','s','o',95.420,2,ops);

%%
[ret2,entrusts] = yiran.cancelorders('T1806',ops);

