clear;

code_list = {'cu1801';'al1801';'zn1801';'pb1801';'ni1801'};

n = length(code_list);

%%
% portfolio
p = cPortfolio;
px = 80;
%%

for i = 1:n
    
    f = cFutures;
    f.loadinfo([code_list{i},'_info.txt']);
    p.updateinstrument(f,80,1);
    
end

%%
% quotes
quotes = cell(n,1);
last_trade = 100;
for i = 1:n
    
    quotes{i} = cQuoteFut;
    quotes{i}.init(code_list{i});
    quotes{i}.last_trade = 100;
    
end

%%
strat = cStratFutSingleSyntheticOpt;
strat.registerinstrument(p.instrument_list{2});
strat.registerinstrument(p.instrument_list{3});
strat.registerinstrument(p.instrument_list{5});

pnl = strat.calcpnl(p,quotes);

if pnl ~= (last_trade-px)*2*5+(last_trade-px)
    error('internal error')
else
    fprintf('pnl successfully calculated\n');
end
