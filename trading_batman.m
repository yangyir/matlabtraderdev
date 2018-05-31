login_counter_fut;
%%
init_mde;
%%
strat_batman = cStratFutBatman;
strat_batman.registercounter(c_fut);
strat_batman.mde_fut_ = mdefut;
%%
codes = {'T1809'; 'ni1807'};
secs = cell(size(codes));
for i = 1:size(codes,1)
    secs{i} = code2instrument(codes{i});
    mdefut.registerinstrument(secs{i});
    strat_batman.registerinstrument(secs{i});
end

%% start mdefut
mdefut.timer_interval_ = 0.5;
mdefut.start
%%
candles = mdefut.getlastcandle;
fprintf('candle:\n');
for i = 1:size(candles,1)
    if isempty(candles{i}), continue;end
    fprintf('\tinstrument:%12s open:%6s high:%6s low:%6s close:%6s time:%12s\n',...
        strat_batman.instruments_.getinstrument{i}.code_ctp,...
        num2str(candles{i}(2)),num2str(candles{i}(3)),num2str(candles{i}(4)),num2str(candles{i}(5)),...
        datestr(candles{i}(1),'yy-mm-dd HH:MM'));
end
%%
strat_batman.loadbookfromcounter('FutList','all');
%print positions
strat_batman.bookrunning_.printpositions;
%%
strat_batman.start
%% print positions and real-time running pnl
strat_batman.helper_.printrunningpnl('MDEFut',mdefut);
%% long open positions
% sec_long_open = 'rb1810';
% lots_long_open = 1;
% spreads_long_open = 0;
% px = 3573;
% pxstoploss = 3550;
% pxtarget = 3590;
% %sanity check
% if px <= pxstoploss, error('stoploss shall be below open price when to long the asset!');end
% if px >= pxtarget, error('target shall be above open price when to long the asset!');end
% %
% strat_batman.longopensingleinstrument(sec_long_open,lots_long_open,spreads_long_open,'overrideprice',px);

%% short open positions
sec_short_open = 'T1809';
lots_short_open = 5;
spreads_short_open = 0;
px = 95.305;
pxstoploss = 95.35;
pxtarget = 95.2;
%sanity check
if px >= pxstoploss, error('stoploss shall be above open price when to short the asset!');end
if px <= pxtarget, error('target shall be below open price when to short the asset!');end
%
strat_batman.shortopensingleinstrument(sec_short_open,lots_short_open,spreads_short_open,'overrideprice',px);
strat_batman.setpxstoploss(sec_short_open,pxstoploss);
strat_batman.setpxtarget(sec_short_open,pxtarget);

%% withdraw pending entrusts
strat_batman.withdrawentrusts('T1809');

%% display pending entrusts
strat_batman.helper_.printpendingentrusts;

%% display all entrusts with their detailed info
strat_batman.helper_.printallentrusts;

%% stop strategy
strat_batman.helper_.stop;
strat_batman.stop
%% stop mde
mdefut.stop
%% logoff counters
c_fut.logout;









