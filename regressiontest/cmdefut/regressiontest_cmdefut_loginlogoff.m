mdefut = cMDEFut;
ret = mdefut.login('Connection','CTP','CounterName','ccb_ly_fut');
%%
mdefut.registerinstrument('cu1908');
mdefut.setcandlefreq(15,'cu1908');
%%
mdefut.initcandles;
%%
mdefut.refresh;
%%
mdefut.start;
%%
ret = mdefut.logoff;
