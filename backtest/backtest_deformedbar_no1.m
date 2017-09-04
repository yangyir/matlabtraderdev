%%
clc;
fprintf('running backtest of product deformedbar No.1...\n');
fromdate = '2016-01-04';
% fromdate = '2016-10-19';
issuefreq = 'zero';

%hard coded control variable inputs
ntickadj = 1;

strategy = cStrategyDeltaNeutral;

%%
todate = businessdate(today,-1);
issuedates = gendates('fromdate',fromdate,'todate',todate,'frequency',issuefreq);
nissue = size(issuedates,1);
backtestresults = cell(nissue,1);
for i = 1:nissue
    issuedate = issuedates(i);
    product = product_deformedbar_no1('ProductIssueDate',issuedate);
    backtestresults{i} = backtest_vanilla(product,strategy,...
        'FromDate',fromdate,...
        'ToDate',todate,...
        'DataSampling','eod',...
        'LiquidityAdjustment',ntickadj,...
        'PrintResults',true);
end




%%
fprintf('\nbacktest of product deformedbar No.1 done...\n');