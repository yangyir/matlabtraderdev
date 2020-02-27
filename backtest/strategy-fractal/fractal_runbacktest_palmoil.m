%%
[p_ri,p_oidata] = bkfunc_genfutrollinfo('palm oil');
[p_cf,~,p_ci] = bkfunc_buildcontinuousfutures(p_ri,p_oidata);
%% daily optimization
% nfractal_daily = 2:10;
% nvolperiod_daily = [0,4:22];
% p_res_daily = zeros(length(nfractal_daily),length(nvolperiod_daily));
% p_pnls_daily = cell(length(nfractal_daily),length(nvolperiod_daily));
% for i = 1:length(nfractal_daily)
%     nf = nfractal_daily(i);
%     parfor j = 1:length(nvolperiod_daily)
%         p_pnls_daily{i,j} = fractal_backtest(p_cf,nf,'freq','daily','volatilityperiod',nvolperiod_daily(j));
%         p_res_daily(i,j) = mean(p_pnls_daily{i,j}(:,6))/std(p_pnls_daily{i,j}(:,6));
%     end
% end
% fprintf('palm oil:done optimization for daily price....\n');
%optimal parameter:nfractal_daily=6,nvolperiod_daily=6
%%
p_codes = {'p1901';'p1905';'p1909';'p2001';'p2005'};
%%
% db = cLocal;
% p_dt1 = cell(length(p_codes),1);
% p_dt2 = cell(length(p_codes),1);
% p_instruments = cell(length(p_codes),1);
% p_1m = cell(length(p_codes),1);
% p_5m = cell(length(p_codes),1);
% p_15m = cell(length(p_codes),1);
% p_30m = cell(length(p_codes),1);
% p_60m = cell(length(p_codes),1);
% for i = 1:length(p_codes)
%     p_instruments{i} = code2instrument(p_codes{i});
%     for k = 1:size(p_ri,1)
%         if strcmpi(p_ri{k,5},p_codes{i}),break;end
%     end
%     dt1_i = p_ri{k,1}-10;
%     dt1_i = datestr(dt1_i,'yyyy-mm-dd');
%     if i == length(p_codes)
%         dt2_i = datestr(getlastbusinessdate,'yyyy-mm-dd');
%     else
%         dt2_i = datestr(p_ri{k+1,1}+5,'yyyy-mm-dd');
%     end
%     p_dt1{i} = dt1_i;
%     p_dt2{i} = dt2_i;
% end
% for i = 1:length(p_codes)
%     p_1m{i} = db.intradaybar(p_instruments{i},p_dt1{i},p_dt2{i},1,'trade');
%     p_5m{i} = timeseries_compress(p_1m{i},'tradinghours',p_instruments{i}.trading_hours,'tradingbreak',p_instruments{i}.trading_break,'frequency','5m');
%     p_15m{i} = timeseries_compress(p_1m{i},'tradinghours',p_instruments{i}.trading_hours,'tradingbreak',p_instruments{i}.trading_break,'frequency','15m');
%     p_30m{i} = timeseries_compress(p_1m{i},'tradinghours',p_instruments{i}.trading_hours,'tradingbreak',p_instruments{i}.trading_break,'frequency','30m');
%     p_60m{i} = timeseries_compress(p_1m{i},'tradinghours',p_instruments{i}.trading_hours,'tradingbreak',p_instruments{i}.trading_break,'frequency','60m');
%     fprintf('%s\t%s\t%s\n',p_codes{i},datestr(p_1m{i}(1,1)),datestr(p_1m{i}(end,1)));
% end
% 
% %%
% save('p_1m','p_1m');
% save('p_5m','p_5m');
% save('p_15m','p_15m');
% save('p_30m','p_30m');
% save('p_60m','p_60m');
%%
% load('p_1m.mat');
% load('p_15m.mat');
% load('p_15m.mat');
% load('T_30m.mat');
% load('T_60m.mat');
%% 5m
nfractal = 2:10;
nvolperiod = [0,4:20];
p_res_5m = zeros(length(nfractal),length(nvolperiod));
p_pnls_5m = cell(length(nfractal),length(nvolperiod));
for i = 1:length(nfractal)
    for j = 1:length(nvolperiod)
        temp = cell(length(p_codes),1);
        for k = 1:length(p_codes)
            p = p_5m{k};
            temp{k} = fractal_backtest(p,nfractal(i),'code',p_codes{k},'freq','5m','volatilityperiod',nvolperiod(j));
        end
        p_pnls_5m{i,j} = cell2mat(temp);
        p_res_5m(i,j) = mean(p_pnls_5m{i,j}(:,6))/std(p_pnls_5m{i,j}(:,6));
    end
end
fprintf('done optimization for intraday 5m price....\n');
%% 15m
nfractal = 2:10;
nvolperiod = [0,4:20];
p_res_15m = zeros(length(nfractal),length(nvolperiod));
p_pnls_15m = cell(length(nfractal),length(nvolperiod));
for i = 1:length(nfractal)
    for j = 1:length(nvolperiod)
        temp = cell(length(p_codes),1);
        for k = 1:length(p_codes)
            p = p_15m{k};
            temp{k} = fractal_backtest(p,nfractal(i),'code',p_codes{k},'freq','15m','volatilityperiod',nvolperiod(j));
        end
        p_pnls_15m{i,j} = cell2mat(temp);
        p_res_15m(i,j) = mean(p_pnls_15m{i,j}(:,6))/std(p_pnls_15m{i,j}(:,6));
    end
end
fprintf('done optimization for intraday 15m price....\n');
%% 30m
nfractal = 2:10;
nvolperiod = [0,4:20];
p_res_30m = zeros(length(nfractal),length(nvolperiod));
p_pnls_30m = cell(length(nfractal),length(nvolperiod));
for i = 1:length(nfractal)
    parfor j = 1:length(nvolperiod)
        temp = cell(length(p_codes),1);
        for k = 1:length(p_codes)
            p = p_30m{k};
            temp{k} = fractal_backtest(p,nfractal(i),'code',p_codes{k},'freq','30m','volatilityperiod',nvolperiod(j));
        end
        p_pnls_30m{i,j} = cell2mat(temp);
        p_res_30m(i,j) = mean(p_pnls_30m{i,j}(:,6))/std(p_pnls_30m{i,j}(:,6));
    end
end
fprintf('done optimization for intraday 30m price....\n');
%% 60m
nfractal = 2:10;
nvolperiod = [0,4:20];
p_res_60m = zeros(length(nfractal),length(nvolperiod));
p_pnls_60m = cell(length(nfractal),length(nvolperiod));
for i = 1:length(nfractal)
    parfor j = 1:length(nvolperiod)
        temp = cell(length(p_codes),1);
        for k = 1:length(p_codes)
            p = p_60m{k};
            temp{k} = fractal_backtest(p,nfractal(i),'code',p_codes{k},'freq','60m','volatilityperiod',nvolperiod(j));
        end
        p_pnls_60m{i,j} = cell2mat(temp);
        p_res_60m(i,j) = mean(p_pnls_60m{i,j}(:,6))/std(p_pnls_60m{i,j}(:,6));
    end
end
fprintf('done optimization for intraday 60m price....\n');
%%
save('p_pnls_5m','p_pnls_5m');save('p_res_5m','p_res_5m');
save('p_pnls_15m','p_pnls_15m');save('p_res_15m','p_res_15m');
save('p_pnls_30m','p_pnls_30m');save('p_res_30m','p_res_30m');
save('p_pnls_60m','p_pnls_60m');save('p_res_60m','p_res_60m');















