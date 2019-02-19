clear;clc;delete(timerfindall);
countername = 'rh_demo_tf2';
bookname = 'rh-test';
strategyname = 'manual';
riskconfigfilename = [getenv('home'),'regressiontest\cstrat\manual\rh\regressiontest_manual_rh_config2.txt'];
genconfigfile('manual',riskconfigfilename,'instruments',{'m1905'});
%%
combos = rtt_setup('countername',countername,'bookname',bookname,...
    'strategyname',strategyname,'riskconfigfilename',riskconfigfilename,...
    'usehistoricaldata',false);
combos.mdefut.printflag_ = false;
%假设给于一百万人民币的保证金
availablefund = 1e6;
combos.strategy.setavailablefund(availablefund,'firstset',true);
%链接行情
combos.mdefut.login('Connection','CTP','CounterName','ccb_ly_fut');
%链接柜台
c = combos.ops.getcounter;
if ~c.is_Counter_Login,c.login;end
%% 执行手动交易策略
combos.mdefut.start;
combos.ops.start;
combos.strategy.start;
%% 打印市场行情
combos.mdefut.printmarket
%% 买开一手
code = 'm1905';
combos.strategy.longopen(code,1);
%% 卖平一手
combos.strategy.shortclose(code,1);
%% 空开一手
combos.strategy.shortopen(code,1);
%% 买平一手
combos.strategy.longclose(code,1);
%%
code = 'm1905';
limitperentrust = combos.strategy.riskcontrols_.getconfigvalue('code',code,'propname','baseunits');
%开多2手国债期货，系统应该报错
combos.strategy.longopen(code,2);
%%
code = 'm1905';
limittotal = combos.strategy.riskcontrols_.getconfigvalue('code',code,'propname','maxunits');
%连续市价开仓10手,然后第十一手应该报错
combos.strategy.longopen(code,1,'overrideprice',-1);
%% 登出系统
combos.mdefut.stop;
delete(timerfindall);
try
    combos.mdefut.logoff;
catch
end
%
try
    c.logout;
catch
end





