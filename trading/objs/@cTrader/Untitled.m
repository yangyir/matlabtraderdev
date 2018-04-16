%%
yiran = cTrader;
yiran.init('yiran');
yiran.addbook(b1);
yiran.addbook(b2);
%%
yiran.books_{1}.printpositions;
yiran.books_{2}.printpositions;
%%
op1 = cOps;
op1.init('ops1',b1);
op1.timer_interval_ = 10;
%
op2 = cOps;
op2.init('ops2',b2);
op2.timer_interval_ = 10;
%%
op1.start;
%%
op1.stop;
%%
[ret,e] =  yiran.placeorder('au1812','b','o',270,1,op1);

%%
[ret2,entrusts] = yiran.cancelorders('au1812',op1);

