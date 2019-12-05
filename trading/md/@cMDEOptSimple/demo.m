mdeopt = cMDEOptSimple;
k_m = 2650:50:2950;
code_m = 'm2005';
mdeopt.registeroptions(code_m,k_m);
%
k_c = 1840:20:1980;
code_c = 'c2005';
mdeopt.registeroptions(code_c,k_c);
%%
pathtrading = getenv('TRADINGDIR');cd(pathtrading)
mdeopt.login('connection','ctp','countername','ccb_ly_fut');
%%
mdeopt.counterctp_ = CounterCTP.ccb_ly_fut;
if ~mdeopt.counterctp_.is_Counter_Login, mdeopt.counterctp_.login;end
%%
mdeopt.setthreshold(code_m,10);
mdeopt.setthreshold(code_c,4);
%%
mdeopt.start;
%%
mdeopt.stop;