%demo_cStratFutMultiWR
demo_strat_wr = cStratFutMultiWR;
demo_strat_wr.counter_ = c_kim;

%%
fprintf('define futures......\n')
codes = {'cu1801'};
futs = cell(size(codes,1),1);
for i = 1:size(codes,1)
    futs{i} = cFutures(codes{i});
    futs{i}.loadinfo([codes{i},'_info.txt']);
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

maxsize = 2;
for i = 1:size(codes,1), demo_strat_wr.setmaxunits(futs{i},maxsize);end

%%
fprintf('initiate data for strat wr......\n');
demo_strat_wr.initdata;

%%
demo_strat_wr.loadportfoliofromcounter;
demo_strat_wr.portfolio_.print;

%%
demo_strat_wr.start;

%%
demo_strat_wr.stop;

%%
hc = demo_strat_wr.mde_fut_.hist_candles_{end-1};
rc = demo_strat_wr.mde_fut_.candles_{end-1};