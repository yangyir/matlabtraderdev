%demo_cStratFutMultiWR
demo_strat_wr = cStratFutMultiWR;
if exist('c_kim','var')
    demo_strat_wr.registercounter(c_kim);
else
    fprintf('counter is missing......\n');
end

%%
%todo:parameters and variables are loaded from .txt (.csa) file

%%
fprintf('define futures......\n')
codes = {'rb1801'};
futs = cell(size(codes,1),1);
for i = 1:size(codes,1)
    futs{i} = cFutures(codes{i});futs{i}.loadinfo([codes{i},'_info.txt']);
end

%%
fprintf('set parameters for strat wr......\n');
%register instrument
for i = 1:size(futs,1), demo_strat_wr.registerinstrument(futs{i}); end

%set parameter for WR
params = struct('numofperiods',144);
for i = 1:size(codes,1), demo_strat_wr.setparameters(futs{1},params);end

%set trading frequency with usage of candles
trading_freq = 5;
for i = 1:size(codes,1), demo_strat_wr.settradingfreq(futs{i},trading_freq);end

%set maximum position size
maxsize = 2;
for i = 1:size(codes,1), demo_strat_wr.setmaxunits(futs{i},maxsize);end

pnl_stop = 0.05;
pnl_limit = 0.1;
for i = 1:size(codes,1), demo_strat_wr.setstoplimit(futs{i},pnl_stop,pnl_limit);end

bidspread = 0;
askspread = 0;
for i = 1:size(codes,1), demo_strat_wr.setbidaskspread(futs{i},bidspread,askspread);end

autotrade = 1;
for i = 1:size(codes,1), demo_strat_wr.setautotradeflag(futs{i},autotrade); end

%%
demo_strat_wr.loadportfoliofromcounter;
demo_strat_wr.portfolio_.print;

%%
fprintf('initiate data for strat wr......\n');
demo_strat_wr.initdata;

%%
demo_strat_wr.startat([datestr(today,'yyyy-mm-dd'),' 09:00:00']);

%%
demo_strat_wr.start;

%%
demo_strat_wr.stop;

%%
demo_strat_wr.printinfo
