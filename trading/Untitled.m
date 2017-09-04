vp1 = cVanillaPortfolio('Name','vp1',...
    'Underlier',struct('BloombergCode','jpy curncy','ContractSize',100),...
    'Strikes',1,...
    'SettleDates',today,...
    'ExpiryDates',dateadd(today,'1m'),...
    'OptionTypes','straddle',...
    'Notionals',1e6,...
    'ReferenceSpots',[]);
display(vp1);


vp2 = cVanillaPortfolio('Name','vp2',...
    'Underlier',struct('BloombergCode','jpy curncy','ContractSize',100),...
    'Strikes',[1,1.02],...
    'SettleDates',[today,today],...
    'ExpiryDates',[dateadd(today,'1m'),dateadd(today,'1m')],...
    'OptionTypes',{'call','call'},...
    'Notionals',[1e6,-1e6],...
    'ReferenceSpots',[]);
display(vp2);


vp1 = vp1.removevanilla('Strike',1,...
    'SettleDate',today,...
    'ExpiryDate',dateadd(today,'1m'),...
    'OptionType','straddle',...
    'Notional',1e6);
display(vp1);

vp2 = vp2.removevanilla('Strike',1,...
    'SettleDate',today,...
    'ExpiryDate',dateadd(today,'1m'),...
    'OptionType','call',...
    'Notional',1e6);
display(vp2);