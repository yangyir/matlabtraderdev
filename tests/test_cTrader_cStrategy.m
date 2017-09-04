trader = cTrader;
display(trader);

strat = cStrategy;
display(strat);

au1712 = cContract('assetname','gold','tenor','1712');
rb1710 = cContract('assetname','deformed bar','tenor','1710');
i1709 = cContract('assetname','iron ore','tenor','1709');

strat = strat.registerinstruments({au1712,rb1710});
strat = strat.registerinstruments(i1709);
display(strat);

trader = trader.registerstrategies(strat);

%%
stratvanilla = cStrategyGenericVanilla;
display(stratvanilla);

v1 = CreateObj('vanilla1','security','securityname','vanilla',...
    'strike',1,'issuedate',today,'expirydate',dateadd(today,'3m'),...
    'underlier',au1712,'optiontype','straddle');

v2 = CreateObj('vanilla1','security','securityname','vanilla',...
    'strike',1,'issuedate',today,'expirydate',dateadd(today,'3m'),...
    'underlier',rb1710,'optiontype','straddle');

v3 = CreateObj('vanilla3','security','securityname','vanilla',...
    'strike',1,'issuedate',today,'expirydate',dateadd(today,'3m'),...
    'underlier',i1709,'optiontype','straddle');

stratvanilla = stratvanilla.add({v1,v2,v3});
display(stratvanilla);
display(stratvanilla.Instruments);
trader = trader.registerstrategies(stratvanilla);
display(trader);