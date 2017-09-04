%%
clc;
fprintf('running backtest of product gold call...\n');
fromdate = '2016-08-01';
issuefreq = 'zero';
datasampling = 'eod';

%hard coded control variable inputs
ntickadj = 1;

underlying = cContract('AssetName','gold','Tenor','1612');

strategy = cStrategyDeltaNeutral;

%%
todate = businessdate(today,-1);
issuedates = gendates('fromdate',fromdate,'todate',todate,'frequency',issuefreq);
nissue = size(issuedates,1);
backtestresults = cell(nissue,1);
for i = 1:nissue
    issuedate = issuedates(i);
    product = product_vanillaonfutures('ProductIssueDate',issuedate,...
        'Underlying',underlying,'Strike',280,'OptionType','Call',...
        'Unit',1e5);
    backtestresults{i} = backtest_vanilla(product,strategy,...
        'FromDate',fromdate,...
        'ToDate',todate,...
        'DataSampling',datasampling,...
        'LiquidityAdjustment',ntickadj,...
        'PrintResults',true);
end




%%
fprintf('\nbacktest of product gold call done...\n');