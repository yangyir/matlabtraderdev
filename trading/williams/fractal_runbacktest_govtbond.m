%%
[T_ri,T_oidata] = bkfunc_genfutrollinfo('govtbond_10y');
[T_cf,~,T_ci] = bkfunc_buildcontinuousfutures(T_ri,T_oidata);
%% daily optimization
nfractal_daily = 2:10;
nvolperiod_daily = [0,4:22];
res_daily = zeros(length(nfractal_daily),length(nvolperiod_daily));
pnls_daily = cell(length(nfractal_daily),length(nvolperiod_daily));
for i = 1:length(nfractal_daily)
    for j = 1:length(nvolperiod_daily)
        pnls_daily{i,j} = fractal_backtest(T_ci,nfractal_daily(i),'freq','daily','volatilityperiod',nvolperiod_daily(j));
        res_daily(i,j) = mean(pnls_daily{i,j}(:,6))/std(pnls_daily{i,j}(:,6));
    end
end
fprintf('done optimization for daily price....\n');
%optimal parameter:nfractal_daily=6,nvolperiod_daily=6
%%
codes = {'T1709';'T1712';...
    'T1803';'T1806';'T1809';'T1812';...
    'T1903';'T1906';'T1909';'T1912';...
    'T2003';'T2006'};
%%
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
T_5m = cell(length(codes),1);
T_15m = cell(length(codes),1);
T_30m = cell(length(codes),1);
T_60m = cell(length(codes),1);
for i = 1:length(codes)
    T_5m{i} = timeseries_compress(T_1m{i},'tradinghours',instruments{i}.trading_hours,'tradingbreak',instruments{i}.trading_break,'frequency','5m');
    T_15m{i} = timeseries_compress(T_1m{i},'tradinghours',instruments{i}.trading_hours,'tradingbreak',instruments{i}.trading_break,'frequency','15m');
    T_30m{i} = timeseries_compress(T_1m{i},'tradinghours',instruments{i}.trading_hours,'tradingbreak',instruments{i}.trading_break,'frequency','30m');
    T_60m{i} = timeseries_compress(T_1m{i},'tradinghours',instruments{i}.trading_hours,'tradingbreak',instruments{i}.trading_break,'frequency','60m');
end
save('T_5m','T_5m');
save('T_15m','T_15m');
save('T_30m','T_30m');
save('T_60m','T_60m');
%%
% load('T_1m.mat');
% load('T_15m.mat');
% load('T_30m.mat');
% load('T_60m.mat');
%% 5m
nfractal = 2:10;
nvolperiod = [0,4:20];
res_5m = zeros(length(nfractal),length(nvolperiod));
pnls_5m = cell(length(nfractal),length(nvolperiod));
for i = 1:length(nfractal)
    for j = 1:length(nvolperiod)
        temp = cell(length(codes),1);
        for k = 1:length(codes)
            p = T_5m{k};
            temp{k} = fractal_backtest(p,nfractal(i),'code',codes{k},'freq','30m','volatilityperiod',nvolperiod(j));
        end
        pnls_5m{i,j} = cell2mat(temp);
        res_5m(i,j) = mean(pnls_5m{i,j}(:,6))/std(pnls_5m{i,j}(:,6));
    end
end
fprintf('done optimization for intraday 5m price....\n');
%% 15m
nfractal = 2:10;
nvolperiod = [0,4:20];
res_15m = zeros(length(nfractal),length(nvolperiod));
pnls_15m = cell(length(nfractal),length(nvolperiod));
for i = 1:length(nfractal)
    for j = 1:length(nvolperiod)
        temp = cell(length(codes),1);
        for k = 1:length(codes)
            p = T_15m{k};
            temp{k} = fractal_backtest(p,nfractal(i),'code',codes{k},'freq','30m','volatilityperiod',nvolperiod(j));
        end
        pnls_15m{i,j} = cell2mat(temp);
        res_15m(i,j) = mean(pnls_15m{i,j}(:,6))/std(pnls_15m{i,j}(:,6));
    end
end
fprintf('done optimization for intraday 15m price....\n');
%% 30m
nfractal = 2:10;
nvolperiod = [0,4:20];
res_30m = zeros(length(nfractal),length(nvolperiod));
pnls_30m = cell(length(nfractal),length(nvolperiod));
for i = 1:length(nfractal)
    for j = 1:length(nvolperiod)
        temp = cell(length(codes),1);
        for k = 1:length(codes)
            p = T_30m{k};
            temp{k} = fractal_backtest(p,nfractal(i),'code',codes{k},'freq','30m','volatilityperiod',nvolperiod(j));
        end
        pnls_30m{i,j} = cell2mat(temp);
        res_30m(i,j) = mean(pnls_30m{i,j}(:,6))/std(pnls_30m{i,j}(:,6));
    end
end
fprintf('done optimization for intraday 30m price....\n');
%% 60m
nfractal = 2:10;
nvolperiod = [0,4:20];
res_60m = zeros(length(nfractal),length(nvolperiod));
pnls_60m = cell(length(nfractal),length(nvolperiod));
for i = 1:length(nfractal)
    for j = 1:length(nvolperiod)
        temp = cell(length(codes),1);
        for k = 1:length(codes)
            p = T_60m{k};
            temp{k} = fractal_backtest(p,nfractal(i),'code',codes{k},'freq','30m','volatilityperiod',nvolperiod(j));
        end
        pnls_60m{i,j} = cell2mat(temp);
        res_60m(i,j) = mean(pnls_60m{i,j}(:,6))/std(pnls_60m{i,j}(:,6));
    end
end
fprintf('done optimization for intraday 60m price....\n');
%%
save('pnls_5m','pnls_5m');save('res_5m','res_5m');
save('pnls_15m','pnls_15m');save('res_15m','res_15m');
save('pnls_30m','pnls_30m');save('res_30m','res_30m');
save('pnls_60m','pnls_60m');save('res_60m','res_60m');















