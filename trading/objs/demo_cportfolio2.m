%demo_cportfolio2
fut = cFutures('ni1805');fut.loadinfo('ni1805_info.txt');
%%
fprintf('\n');
p = cPortfolio;
p.print;
t1 = cTransaction;
t1.instrument_ = fut;
t1.price_ = 100000;
t1.volume_ = 1;
t1.direction_ = -1;
t1.offset_ = 1;
t1.datetime1_ = datenum('2017-11-13 14:59:55');
t1.datetime2_ = datestr(t1.datetime1_);
p.updateportfolio(t1);
p.print;
%
t2 = cTransaction;
t2.instrument_ = fut;
t2.price_ = 100100;
t2.volume_ = 2;
t2.direction_ = -1;
t2.offset_ = 1;
t2.datetime1_ = datenum('2017-11-13 14:59:59');
t2.datetime2_ = datestr(t2.datetime1_);
p.updateportfolio(t2);
p.print;