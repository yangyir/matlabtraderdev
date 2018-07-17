login_counter_fut;
%%
init_mde;
%%
strat_WRPlusBatman = cStratFutMultiWRPlusBatman;
strat_WRPlusBatman.registercounter(c_fut);
strat_WRPlusBatman.mde_fut_ = mdefut;
samplefreq = 3;
strat_WRPlusBatman.setsamplefreq(instr, samplefreq);
autotrade = 1;
strat_WRPlusBatman.setautotradeflag(instr, autotrade);
maxunits = 100;
strat_WRPlusBatman.setmaunits(instr,maxunits);
maxexecutionperbucket = 1;
replay_strat.maxexecutionperbucket(instr,maxexecutionperbucket);
  
%%
codes = { 'ni1809'};
secs = cell(size(codes));
for i = 1:size(codes,1)
    secs{i} = code2instrument(codes{i});
    mdefut.registerinstrument(secs{i});
    strat_WRPlusBatman.registerinstrument(secs{i});
end

%% start mdefut
mdefut.start
%%
candles = mdefut.getlastcandle;
fprintf('candle:\n');
for i = 1:size(candles,1)
    if isempty(candles{i}), continue;end
    fprintf('\tinstrument:%12s open:%6s high:%6s low:%6s close:%6s time:%12s\n',...
        strat_WRPlusBatman.instruments_.getinstrument{i}.code_ctp,...
        num2str(candles{i}(2)),num2str(candles{i}(3)),num2str(candles{i}(4)),num2str(candles{i}(5)),...
        datestr(candles{i}(1),'yy-mm-dd HH:MM'));
end

%%
strat_WRPlusBatman.loadbookfromcounter('FutList',{'rb1810'});
%print positions
strat_WRPlusBatman.bookrunning_.printpositions;
%%
strat_WRPlusBatman.start
strat_WRPlusBatman.helper_.start;
%% print positions and real-time running pnl
strat_WRPlusBatman.helper_.printrunningpnl('MDEFut',mdefut);

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
strat_WRPlusBatman.shortopensingleinstrument(sec_short_open,lots_short_open,spreads_short_open,'overrideprice',px);
strat_WRPlusBatman.setpxstoploss(sec_short_open,pxstoploss);
strat_WRPlusBatman.setpxtarget(sec_short_open,pxtarget);

%% withdraw pending entrusts
strat_WRPlusBatman.withdrawentrusts('T1809');

%% display pending entrusts
strat_WRPlusBatman.helper_.printpendingentrusts;

%% display all entrusts with their detailed info
strat_WRPlusBatman.helper_.printallentrusts;

%% stop strategy
strat_WRPlusBatman.helper_.stop;
strat_WRPlusBatman.stop
%% stop mde
mdefut.stop
%% logoff counters
c_fut.logout;









