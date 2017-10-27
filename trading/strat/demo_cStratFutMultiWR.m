%demo_cStratFutMultiWR

%%
codes = {'cu1801';'al1801';'zn1801';'pb1801';'ni1801'};
futs = cell(size(codes,1),1);
for i = 1:size(codes,1)
    futs{i} = cFutures(codes{i});
    futs{i}.loadinfo([codes{i},'_info.txt']);
end
%%
demo_strat_wr = cStratFutMultiWR;
for i = 1:size(futs,1), demo_strat_wr.registerinstrument(futs{i}); end


%%
params = struct('numofperiods',144);
demo_strat_wr.setparameters(futs{1},params);

%set trading frequency with usage of candles
trading_freq = 3;
demo_strat_wr.settradingfreq(futs{1},trading_freq);
