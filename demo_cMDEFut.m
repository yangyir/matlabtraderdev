%% ctp login
% if ~exist('md_ctp','var') || ~isa(md_ctp,'cCTP')
%     md_ctp = cCTP.citic_kim_fut;
% end
% if ~md_ctp.isconnect, md_ctp.login; end

% if ~exist('qms_fut','var') || ~isa(qms_fut,'cQMS')
%     qms_fut = cQMS;
%     qms_fut.setdatasource('ctp');
% end

%% contracts
ni1801 = cFutures('ni1801');ni1801.loadinfo('ni1801_info.txt');
zn1801 = cFutures('zn1801');zn1801.loadinfo('zn1801_info.txt');
al1712 = cFutures('al1712');al1712.loadinfo('al1712_info.txt');

%% init market data engine
trading_freq = 3;
mde_fut = cMDEFut;
mde_fut.qms_ = qms_fut;
mde_fut.registerinstrument(ni1801);
mde_fut.registerinstrument(zn1801);
mde_fut.registerinstrument(al1712);
mde_fut.setcandlefreq(trading_freq);
mde_fut.initcandles;

%%
mde_fut.startat('2017-10-24 09:00:00');

%%
mde_fut.start;

%%
candles = mde_fut.candles_{1};

%%
indicators = mde_fut.calc_technical_indicator('William %R',ni1801,'NumOfPeriods',144);

%%
mde_fut.stop;

%%
codes = {'ni1801';'al1712';'zn1801';'T1712'};
ncodes = size(codes,1);
% William %R
WilliamR = ones(ncodes,1);
techtbl = table(WilliamR,'RowNames',codes);

