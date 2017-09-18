ldb = cLocal;

instrument = cFutures('T1712');
instrument.loadinfo('T1712_info.txt');

timestr = '2017-09-11 15:55:00';

data = ldb.realtime(instrument,timestr);

%%
w = cWatcher;
w.conn = 'local';
w.addsingle(instrument.code_ctp);

%%
w.refresh(timestr);
w.qs{1}.print;




