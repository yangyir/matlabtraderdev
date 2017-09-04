%%
clc;
fprintf('running backtest of product bull spread on copper...\n');
fromdate = '2016-11-14';
issuefreq = 'zero';
datasampling = 'intradaybar';

%hard coded control variable inputs
ntickadj = 1;

underlying = cContract('AssetName','copper','Tenor','1702');

strategy = cStrategyDeltaNeutral('UseBreakEvenReturn',true,...
    'ParticipateRatio',0.5);

%%
todate = '2016-11-16';
issuedates = gendates('fromdate',fromdate,'todate',todate,'frequency',issuefreq);
nissue = size(issuedates,1);
backtestresults = cell(nissue,1);
for i = 1:nissue
    issuedate = issuedates(i);
    
    bullspread = product_bullspreadonfutures('ProductIssueDate',issuedate,...
        'Underlying',underlying,...
        'LowerStrike',46000,...
        'UpperStrike',50000,...
        'Unit',1e3);
    
    backtestresults{i} = backtest_vanilla(bullspread,strategy,...
        'FromDate',fromdate,...
        'ToDate',todate,...
        'DataSampling',datasampling,...
        'LiquidityAdjustment',ntickadj,...
        'PrintResults',true);
end