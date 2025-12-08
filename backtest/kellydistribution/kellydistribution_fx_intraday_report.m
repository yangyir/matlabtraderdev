code2check = 'XAUUSD';
freq2check = '15m';
replay1 = '2025-01-01';
replay2 = '2025-11-16';
showLogs = true;
doPlot = true;

appendix = lower(freq2mt4freq(freq2check));

dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
strat_fx_i = load([dir_,'strat_fx_',appendix,'.mat']);
strat_fx_i = strat_fx_i.(['strat_fx_',appendix]);
%
nfractal2check = charlotte_freq2nfractal(freq2check);
[ut,ct,tbl2check_fx] = charlotte_backtest_period('code',code2check,'fromdate',replay1,'todate',replay2,'kellytables',strat_fx_i,'showlogs',showLogs,'doplot',doPlot,'frequency',freq2check,'nfractal',nfractal2check);
open tbl2check_fx
%%
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
codes_fx = {'audusd';'eurusd';'gbpusd';'usdcad';'usdchf';'usdjpy';'xauusd'};
% codes_fx = {'xauusd';};
% freqs = {'15m';'30m';'1h';'4h'};
% freqsmt4 = {'m15';'m30';'h1';'h4'};
freqs = {'1h';'4h'};
freqsmt4 = {'h1';'h4'};
count = 0;
code = cell(100,1);
nTotal = zeros(100,1);
pWin = zeros(100,1);
rRet = zeros(100,1);
kRet = zeros(100,1);
maxDrawdown = zeros(100,1);
annualRet = zeros(100,1);
freq = cell(100,1);
% cashpnl = zeros(100,1);
riskLimit = zeros(100,1);
for ifreq = 1:length(freqs)
    data = load([dir_,'tbl2check_fx_',freqsmt4{ifreq},'_all.mat']);
    tbl2check = data.(['tbl2check_fx_',freqsmt4{ifreq},'_all']);
    for i = 1:size(codes_fx,1)
        idxselect = strcmpi(tbl2check.code,codes_fx{i});
        pnlret = tbl2check.pnlrel(idxselect);
        [winp_running,r_running,kelly_running] = calcrunningkelly(pnlret);
        Wret = winp_running(end);
        Rret = r_running(end);
        Kret = kelly_running(end);
        pnlretcum = cumsum(pnlret);
        pnlretmax = pnlretcum;
        for j = 1:length(pnlretmax)
            pnlretmax(j) = max(pnlretcum(1:j));
            if pnlretmax(j) < 0, pnlretmax(j) = 0;end
        end
        pnlretdrawdown = pnlretcum - pnlretmax;
        pnlretdrawdownmax = min(pnlretdrawdown);
        count = count + 1;
        code{count} = codes_fx{i};
        freq{count} = freqsmt4{ifreq};
        nTotal(count) = size(pnlret,1);
        pWin(count) = Wret;
        rRet(count) = Rret;
        kRet(count) = Kret;
        maxDrawdown(count) = pnlretdrawdownmax;
        t2 = tbl2check.closedatetime(idxselect);
        t2 = datenum(t2(end),'yyyy-mm-dd HH:MM:SS');
        t1 = tbl2check.opendatetime(idxselect);
        t1 = datenum(t1(1),'yyyy-mm-dd HH:MM:SS');
        deltaT = (t2-t1)/365;
        annualRet(count) = pnlretcum(end)/deltaT;
%         cashpnl(count) = sum(tbl2check.closepnl(idxselect));
        if strcmpi(codes_fx{i},'xauusd')
            riskLimit(count) = 1000;
        else
            riskLimit(count) = 1000;
        end
    end
end
code = code(1:count);
freq = freq(1:count);
nTotal = nTotal(1:count);
pWin = pWin(1:count);
rRet = rRet(1:count);
kRet = kRet(1:count);
% cashpnl = cashpnl(1:count);
maxDrawdown = maxDrawdown(1:count);
annualRet = annualRet(1:count);
riskLimit = riskLimit(1:count);
% tblreport = table(code,freqcol,nTotal,pWin,rRet,kRet,maxDrawdown,annualRet,cashpnl);
tblreport = table(code,freq,nTotal,pWin,rRet,kRet,maxDrawdown,annualRet,riskLimit);
tblreport = sortrows(tblreport,'code','ascend');
open tblreport;

%%
n = size(tblreport,1);
nSelect = 0;
codesSelected = cell(n,5);
%
kThreshold = [0.167,0.14];
pThreshold = [0.5,0.42];
%
for i = 1:n
    if (tblreport.kRet(i) > kThreshold(1) && tblreport.pWin(i) > pThreshold(1)) || ...
            (tblreport.kRet(i) > kThreshold(2) && tblreport.pWin(i) > pThreshold(2))
        nSelect = nSelect + 1;
        codesSelected{nSelect,1} = tblreport.code{i};
        codesSelected{nSelect,2} = tblreport.freq{i};
    end        
end
codesSelected = codesSelected(1:nSelect,:);
%
%calculate the pnl with trading cost adjustments
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
for i = 1:nSelect
    data = load([dir_,'tbl2check_fx_',codesSelected{i,2},'_all.mat']);
    tbl2check = data.(['tbl2check_fx_',codesSelected{i,2},'_all']);
    idx2check = strcmpi(tbl2check.code,codesSelected{i,1});
    pnlrel2check = tbl2check.pnlrel(idx2check);
    notional2check = tbl2check.opennotional(idx2check);
    if strcmpi(codesSelected{i,1},'audusd') || ...
            strcmpi(codesSelected{i,1},'eurusd') || ...
            strcmpi(codesSelected{i,1},'gbpusd')
        codesSelected{i,3} = sum(pnlrel2check);
        if strcmpi(codesSelected{i,1},'audusd')
            baspread = 2;
        elseif strcmpi(codesSelected{i,1},'eurusd')
            baspread = 3;
        elseif strcmpi(codesSelected{i,1},'gbpusd')
            baspread = 4;
        end
        codesSelected{i,4} = sum((2+baspread)./notional2check);
    elseif strcmpi(codesSelected{i,1},'xauusd')
        baspread = 14;
        codesSelected{i,3} = sum(pnlrel2check);
        codesSelected{i,4} = sum((2+baspread)./notional2check);
    elseif strcmpi(codesSelected{i,1},'xagusd')
        baspread = 15;
        codesSelected{i,3} = sum(pnlrel2check);
        codesSelected{i,4} = sum((2+baspread)*5./notional2check);
    else
        if strcmpi(codesSelected{i,1},'usdcad')
            baspread = 6;
        elseif strcmpi(codesSelected{i,1},'usdchf')
            baspread = 6;
        elseif strcmpi(codesSelected{i,1},'usdjpy')
            baspread = 5;
        end
        codesSelected{i,3} = sum(pnlrel2check);
        codesSelected{i,4} = size(pnlrel2check,1)*(2+baspread)/1e5;
    end
    if codesSelected{i,3} > codesSelected{i,4}
        codesSelected{i,5} = 'select';
    else
        codesSelected{i,5} = 'high cost';
    end
end
%
idxSelected = strcmpi(codesSelected(:,5),'select');
codesSelected = codesSelected(idxSelected,:);
open codesSelected;
%
code = codesSelected(idxSelected,1);
freq = codesSelected(idxSelected,2);
selected = table(code,freq);
selected = join(selected,tblreport);
open selected;
%% portfolio optimization
% idx = ~strcmpi(selected.freq,'m5');
% port = selected(idx,:);
port = selected;
n = size(port,1);
names = cell(n,1);
for i = 1:n
    names{i} = [port.code{i},'-',port.freq{i}];
end
p = port.pWin;
b = port.rRet;
fprintf('sum of kellies: %.4f\n', sum(port.kRet));

% number of outcomes (2^n?)
clear outcomes;
[outcomes{1:n}] = ndgrid([0,1]); % 0=?, 1=?
outcome_mat = reshape(cat(n+1, outcomes{:}), [], n);
num_outcomes = size(outcome_mat, 1);

% probability of different scenarios
prob = prod(outcome_mat .* p' + (1-outcome_mat) .* (1-p'), 2);

% objective function
objective = @(f) -kelly_calcgrowth(f,b,p);

% constraints
usage = 0.95;
A = ones(1, n); 
b_sum = usage;
lb = zeros(1, n);
ub = usage*ones(1,n);

% initial value
f0 = min(1, selected.kRet / sum(selected.kRet)) * 1.0;
f0 = usage*min(1, ones(n,1)/n);
% f0 = selected.kRet;
% calibration parameters
options = optimoptions('fmincon', 'Display', 'iter', ...
    'Algorithm', 'sqp', 'MaxFunctionEvaluations', 10000);

% use fmincon to calibrate
[f_opt, fval] = fmincon(objective, f0, A, b_sum, [], [], lb, ub, [], options);
optimal_growth = -fval;
port.f_opt = f_opt;
% port = port(port.f_opt > 0.01,:);
open port

%%
path_ = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Data\'];
fn_ = 'kellytable.txt';
fid = fopen([path_,fn_],'w');
if fid
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
        'code',...
        'freq',...
        'nTotal',...
        'pWin',...
        'rRet',...
        'kRet',...
        'maxDrawdownRet',...
        'annualRet',...
        'riskLimit',...
        'fOpt');
    for i = 1:size(port,1)
        fprintf(fid,'%s\t%s\t%d\t%f\t%f\t%f\t%f\t%f\t%f\t%f\n',...
            [upper(port.code{i}),'.lmx'],...
            upper(port.freq{i}),...
            port.nTotal(i),...
            port.pWin(i),...
            port.rRet(i),...
            port.kRet(i),...
            port.maxDrawdown(i),...
            port.annualRet(i),...
            port.riskLimit(i),...
            port.f_opt(i));
            
        
    end
      
end
fclose(fid);  
%%
nSelect = size(port,1);
for i = 1:nSelect
    data = load([dir_,'tbl2check_fx_',codesSelected{i,2},'_all.mat']);
    tbl2check = data.(['tbl2check_fx_',codesSelected{i,2},'_all']);
    idx2check = strcmpi(tbl2check.code,port.code{i,1});
    tbl_i = tbl2check(idx2check,:);
    tbl_i.freq = cell(size(tbl_i,1),1);
    for j = 1:size(tbl_i,1)
        tbl_i.freq{j} = port.freq{i,1};
    end
    
    if i == 1
        tblSelected = tbl_i;
    else
        tblSelected = union(tblSelected,tbl_i);
    end
end
 tblSelected = sortrows(tblSelected,'opendatetime','ascend');
 writetable(tblSelected,'C:\yangyiran\tblselected.xlsx');
%%
replay1 = '2025-08-22';
replay2 = '2025-08-29';
for i = 1:size(port,1)
    strat_fx_i = load([dir_,'strat_fx_',port.freq{i},'.mat']);
    strat_fx_i = strat_fx_i.(['strat_fx_',port.freq{i}]);
    nfractal2check = charlotte_freq2nfractal(port.freq{i});
    [~,~,tbl2check_i] = charlotte_backtest_period('code',port.code{i},'fromdate',replay1,'todate',replay2,'kellytables',strat_fx_i,'showlogs',false,'doplot',false,'frequency',port.freq{i},'nfractal',nfractal2check);
    ntrades = size(tbl2check_i,1);
    freqs = cell(ntrades,1);
    for j = 1:ntrades
        freqs{j} = port.freq{i};
    end
    if ~isempty(tbl2check_i)
        tbl2check_i.freq = freqs;
    end
        
    if i == 1
        if ~isempty(tbl2check_i)
            tbl2check_month = tbl2check_i;
        else
            tbl2check_month = [];
        end
    else
        if ~isempty(tbl2check_month)
            if ~isempty(tbl2check_i)
                tbl2check_month = union(tbl2check_month,tbl2check_i);
            end
        else
            if ~isempty(tbl2check_i)
                tbl2check_month = tbl2check_i;
            else
                tbl2check_month = [];
            end
        end
    end
end
tbl2check_month = sortrows(tbl2check_month,'opendatetime','ascend');
writetable(tbl2check_month,'C:\yangyiran\tbl2check_month.xlsx');
%%



