%% contract
ni1801 = cFutures('ni1801');ni1801.loadinfo('ni1801_info.txt');

%% datetime array
dtstart = '2017-10-16 09:00:00';
dtend = '2017-10-20 15:00:00';
ds = cLocal;
freq = 3;
databar = ds.intradaybar(ni1801,'2017-10-16','2017-10-20',freq,'trade');

%% technical indicators
wpctr = willpctr(databar(:,3), databar(:,4), databar(:,5), 144);

%%
mde_fut = cMDEFut;
mde_fut.qms_ = qms_fut;
mde_fut.registerinstrument(ni1801);
mde_fut.candle_freq_ = freq;

%%
mde_fut.start;

%%
mde_fut.stop;

%%
c = mde_fut.candles_;
datestr(c{1}(:,1))