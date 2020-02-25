%%
[T_ri,T_oidata] = bkfunc_genfutrollinfo('govtbond_10y');
%%
codes = {'T1709';'T1712';...
    'T1803';'T1806';'T1809';'T1812';...
    'T1903';'T1906';'T1909';'T1912';...
    'T2003';'T2006'};
dt1 = cell(length(codes),1);
dt2 = cell(length(codes),1);
db = cLocal;
instruments = cell(length(codes),1);
T_1m = cell(length(codes),1);
for i = 1:length(codes)
    instruments{i} = code2instrument(codes{i});
    for k = 1:size(T_ri,1)
        if strcmpi(T_ri{k,5},codes{i}),break;end
    end
    dt1_i = T_ri{k,1}-10;
    dt1_i = datestr(dt1_i,'yyyy-mm-dd');
    if i == length(codes)
        dt2_i = datestr(getlastbusinessdate,'yyyy-mm-dd');
    else
        dt2_i = datestr(T_ri{k+1,1}+5,'yyyy-mm-dd');
    end
    
    T_1m{i} = db.intradaybar(instruments{i},dt1_i,dt2_i,1,'trade');
end
%
for i = 1:length(codes)
    fprintf('%s\t%s\t%s\n',codes{i},datestr(T_1m{i}(1,1)),datestr(T_1m{i}(end,1)));
end
%
T_15m = cell(length(codes),1);
T_30m = cell(length(codes),1);
T_60m = cell(length(codes),1);
for i = 1:length(codes)
    T_15m{i} = timeseries_compress(T_1m{i},'tradinghours',instruments{i}.trading_hours,'tradingbreak',instruments{i}.trading_break,'frequency','15m');
    T_30m{i} = timeseries_compress(T_1m{i},'tradinghours',instruments{i}.trading_hours,'tradingbreak',instruments{i}.trading_break,'frequency','30m');
    T_60m{i} = timeseries_compress(T_1m{i},'tradinghours',instruments{i}.trading_hours,'tradingbreak',instruments{i}.trading_break,'frequency','60m');
end
%%
code = 'T1812';p = db.intradaybar(code2instrument(code),'2018-08-01','2018-11-07',60,'trade');
%%
p = T_60m{end-4};
nfracal = 5;
[pnl] = fractal_backtest(p,nfracal,'code','T1812','freq','daily','volatilityperiod',9);
%
[~,~,~,upperchannel,lowerchannel] = fractalenhanced(p,nfracal,'volatilityperiod',9);
HH = upperchannel;
LL = lowerchannel;
figure(2);
candle(p(:,3),p(:,4),p(:,5),p(:,2));
hold on;
stairs(upperchannel,'r--');stairs(lowerchannel,'g--');hold off;grid off;
figure(3);
plot(cumsum(pnl(:,6)))