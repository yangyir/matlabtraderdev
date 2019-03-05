extrainfo = struct('pxstoploss_',49000,'stepvalue_',10,'buffer_',1);
trade1 = cTradeOpen('code','cu1904');
trade1.setriskmanager('name','wrstep','extrainfo',extrainfo);
trade1.riskmanager_