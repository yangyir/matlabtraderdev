mdefut = cMDEFut;
[futs] = getactivefuts('CobDate',getlastbusinessdate,...
    'AssetNames',{'deformed bar'},'ConditionType','and');    
tradingdir = [getenv('HOME'),'realtrading\'];
cd(tradingdir);
stratname = 'manual';
configfilename = [stratname,'_config1.txt'];
genconfigfile(stratname,[tradingdir,configfilename],'instruments',futs);    

stratmanual = cStratManual;
stratmanual.usehistoricaldata_ = true;
stratmanual.registermdefut(mdefut);
stratmanual.loadriskcontrolconfigfromfile('filename',configfilename);

%%
stratmanual.initdata;
%%
mdefut.login('connection','ctp','countername','ccb_ly_fut');
%%
mdefut.start;
%%
wrinfo = stratmanual.wlpr('rb1901')
%%
stratmanual.stratplot('rb1901')

