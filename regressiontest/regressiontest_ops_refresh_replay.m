%% Create a Book
clear;clc;
myCounter = CounterCTP.citic_kim_fut;
myTraderName = 'computer';
myBookName = 'book1';
myBook = cBook;
myBook.init(myBookName,myTraderName,myCounter);
%% Create a Ops
myOpsName = 'helper';
myOps = cOps;
myOps.init(myOpsName,myBook);
myOps.mode_ = 'replay';
myOps.timer_interval_ = 0.005;
myOps.replay_time1_ = datenum('2018-06-19 08:30:00');

%%
myOps.start;
%%
myOps.stop;
delete(timerfindall);

