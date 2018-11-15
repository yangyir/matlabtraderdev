%%
foldername = [getenv('HOME'),'demotrading\manual\'];
instruments = getactivefuts('AssetTypes',{'eqindex';'govtbond';'preciousmetal';'basemetal'},...
    'AssetNames',{'crude oil';'iron ore';'deformed bar'},...
    'ConditionType','or');
countername = 'ccb_ly_fut';
bookname = 'manual-ctp';
strategyname = 'manual';
riskconfigfilename = 'ctp_manualconfig_ccblyfut.txt';
genconfigfile(strategyname,[foldername,riskconfigfilename],'instruments',instruments);
%%
combos = rtt_setup('CounterName',countername,...
    'BookName',bookname,...
    'StrategyName',strategyname,...
    'RiskConfigFileName',riskconfigfilename);



    





%%
filename = 'c:\temp1.txt';
[ret] = modconfigfile(riskconfigfilename)

%%
