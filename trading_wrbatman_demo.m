c_demo = CounterCTP.demo_sunq_fut;
c_demo.login;
init_mde;
%%
code = 'ni1809';
samplefreq = 3;
autotrade = 1;
maxunits = 10;
pxtargetratio = 0.02;
pxstoplossratio = 0.01;

%%
stratwrbatman_demo = cStratFutMultiWRPlusBatman;
stratwrbatman_demo.registercounter(c_demo);
stratwrbatman_demo.registermdefut(mdefut);
stratwrbatman_demo.registerinstrument(code);
stratwrbatman_demo.setsamplefreq(code, samplefreq);
stratwrbatman_demo.setautotradeflag(code, autotrade);
stratwrbatman_demo.setmaxunits(code,maxunits);
stratwrbatman_demo.setbandtarget(code,pxtargetratio);
stratwrbatman_demo.setbandstoploss(code,pxstoplossratio);
stratwrbatman_demo.timer_interval_ = 0.5;
%%
stratwrbatman_demo.initdata;

%% start mdefut
mdefut.start
%%
mdefut.printmarket
%% print positions
stratwrbatman_demo.bookrunning_.printpositions;
%%
stratwrbatman_demo.start
%% print positions and real-time running pnl
stratwrbatman_demo.helper_.printrunningpnl('MDEFut',mdefut);
%% withdraw pending entrusts
stratwrbatman_demo.withdrawentrusts(code);
%% display pending entrusts
stratwrbatman_demo.helper_.printpendingentrusts;
%% display all entrusts with their detailed info
stratwrbatman_demo.helper_.printallentrusts;
%% stop strategy
stratwrbatman_demo.helper_.stop;
stratwrbatman_demo.stop
%% stop mde
mdefut.stop
delete(timerfindall)
%% logoff counters
c_demo.logout;









