
%% contracts
ni1801 = cFutures('ni1801');ni1801.loadinfo('ni1801_info.txt');
zn1801 = cFutures('zn1801');zn1801.loadinfo('zn1801_info.txt');
al1712 = cFutures('al1712');al1712.loadinfo('al1712_info.txt');
cu1712 = cFutures('cu1712');cu1712.loadinfo('cu1712_info.txt');

%% init market data engine
mde_fut = cMDEFut;
mde_fut.qms_ = qms_fut;
mde_fut.registerinstrument(ni1801);
mde_fut.registerinstrument(zn1801);
mde_fut.registerinstrument(al1712);
mde_fut.registerinstrument(cu1712);
trading_freq = 3;
mde_fut.setcandlefreq(trading_freq);

%% init with candles
mde_fut.initcandles;

%%
mde_fut.startat('2017-10-30 09:00:00');

%%
mde_fut.start;

%%
mde_fut.stop;

%%
% mde_fut.setreplaydate('2017-10-23');

%%
studyindicator = struct('name','WilliamR','values',{{'numofperiods',144}});
instr = al1712;
mde_fut.settechnicalindicator(instr,studyindicator);
wr = mde_fut.calc_technical_indicators(instr);
fprintf('%4.2f\n',wr);

lastcandle = mde_fut.getlastcandle(instr);
fprintf('time:%s open:%4.0f high:%4.0f low:%4.0f close:%4.0f\n',...
    datestr(lastcandle{1}(1)),lastcandle{1}(2),lastcandle{1}(3),lastcandle{1}(4),lastcandle{1}(5));



