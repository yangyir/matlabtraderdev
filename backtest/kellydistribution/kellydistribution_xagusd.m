dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
codes_ag = {'xagusd'};
freqs = {'5m';'15m';'30m';'1h';'4h'};
%%
recalib_flag = input('Recalibrate Kelly Tables?Y/N: ','s');
if strcmpi(recalib_flag,'Y')
    output_xagusd = cell(length(freqs),1);
    strat_xagusd = output_xagusd;
    parfor i = 1:length(freqs)
        if i == 4
            freqstr = 'intraday-60m';
        elseif i == 5
            freqstr = 'intraday-240m';
        else
            freqstr = ['intraday-',freqs{i}]; 
        end
        output_xagusd{i} = fractal_kelly_summary('codes',codes_ag,...
        'frequency',freqstr,'usefractalupdate',0,'usefibonacci',1,'direction','both',...
        'nfractal',charlotte_freq2nfractal(freqs{i}));
        [~,~,~,~,~,~,~,strat_xagusd{i}] = kellydistributionsummary(output_xagusd{i});
    end
else
    strat_i = load([dir_,'strat_ag_',freq2mt4freq(freq{i}),'.mat']);
    strat_i = strat_i.(['strat_ag_',freq2mt4freq(freq{i})]);
    strat_xagusd{i} = strat_i;
end
%%
% charlotte_strat_compare('strat1',strat_fx_m15_existing,'strat2',strat_fx_m15,'assetname','eurusd');
%%
tbl2check_xagusd = cell(length(freqs),1);
parfor i = 1:length(freqs)
    [~,ei] = charlotte_loaddata('futcode','xagusd','frequency',freqs{i},'nfractal',charlotte_freq2nfractal(freqs{i}));
    dt1 = datestr(ei.px(1,1),'yyyy-mm-dd');
    dt2 = datestr(ei.px(end,1),'yyyy-mm-dd');
    [~,~,tbl2check_xagusd{i}] = charlotte_backtest_period('code','xagusd','fromdate',dt1,'todate',dt2,...
        'kellytables',strat_xagusd{i},...
        'showlogs',false,'doplot',false,'frequency',freqs{i},...
        'nfractal',charlotte_freq2nfractal(freqs{i}),...
        'compulsorycheckforconditional',true);
    ntrades = size(tbl2check_xagusd{i},1);
    freq = cell(ntrades,1);
    for j = 1:ntrades
        freq{j} = freqs{i};
    end
    if ~isempty(tbl2check_xagusd{i})
        tbl2check_xagusd{i}.freq = freq;
    end
end
tbl2check_xagusd_all = tbl2check_xagusd{1};
for i = 2:size(codes_ag,1)
    temp = [tbl2check_xagusd_all;tbl2check_xagusd{i}];
    tbl2check_xagusd_all = temp;
end
tbl2check_xagusd_all = sortrows(tbl2check_xagusd_all,'opendatetime','ascend');
%%
strat_xagusd_m5 = strat_xagusd{1};
strat_xagusd_m15 = strat_xagusd{2};
strat_xagusd_m30 = strat_xagusd{3};
strat_xagusd_h1 = strat_xagusd{4};
strat_xagusd_h4 = strat_xagusd{5};
save([dir_,'strat_xagusd_m5.mat'],'strat_xagusd_m5');
save([dir_,'strat_xagusd_m15.mat'],'strat_xagusd_m15');
save([dir_,'strat_xagusd_m30.mat'],'strat_xagusd_m30');
save([dir_,'strat_xagusd_h1.mat'],'strat_xagusd_h1');
save([dir_,'strat_xagusd_h4.mat'],'strat_xagusd_h4');
fprintf('strat tables saved\n');
%%
statsout = cell(length(freqs),1);
for i = 1:length(freqs)    
    pnlret = tbl2check_xagusd{i}.pnlrel;
    opendt = tbl2check_xagusd{i}.opendatetime;
    opendt = datestr(opendt,'yyyymm');
    opendtyymm = zeros(size(opendt,1),1);
    for j = 1:size(opendt,1)
        opendtyymm(j) = str2double(opendt(j,:));
    end
        
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
    
    opendtyymmunique = unique(opendtyymm);
    res_i = opendtyymmunique;
    for j = 1:size(opendtyymmunique)
        idx_j = find(opendtyymm <= opendtyymmunique(j),1,'last');
        res_i(j,2) = idx_j;
        res_i(j,3) = winp_running(idx_j);
        res_i(j,4) = r_running(idx_j);
        res_i(j,5) = kelly_running(idx_j);
    end
    
    p_converge = -1;
    for j = 2:size(winp_running)
        if winp_running(j) == inf || winp_running(j) == -inf, continue;end
        x = winp_running(j:end);
        x = (x - mean(x))/std(x);
        h = kstest(x,'alpha',0.05);
        if h == 0
            p_converge = j;
            break;
        end
    end
    
    r_converge = -1;
    for j = 2:size(r_running)
        if r_running(j) == inf || r_running(j) == -inf, continue;end
        x = r_running(j:end);
        x = (x - mean(x))/std(x);
        h = kstest(x,'alpha',0.05);
        if h == 0
            r_converge = j;
            break;
        end
    end
    
    k_converge = -1;
    for j = 2:size(kelly_running)
        if kelly_running(j) == inf || kelly_running(j) == -inf, continue;end
        x = kelly_running(j:end);
        x = (x - mean(x))/std(x);
        h = kstest(x,'alpha',0.05);
        if h == 0
            k_converge = j;
            break;
        end
    end

    statsout{i} = struct('code','xagusd',...
        'freqs',freqs{i},...
        'nTotal',size(pnlret,1),...
        'Pwin',Wret,...
        'Rret',Rret,...
        'Kret',Kret,...
        'MaxDrawdownret',pnlretdrawdownmax,...
        'PConverge',p_converge,...
        'RConverge',r_converge,...
        'KConverge',k_converge,...
        'ResMonthByMonth',{res_i},...
        'PRunning',{winp_running},...
        'RRunning',{r_running},...
        'KRunning',{kelly_running});
%
end
fprintf('done...\n');
%% visualization
for i = 1:length(freqs)
    cumulativeMeans = statsout{i}.PRunning;
    if i == 1
        figure('color','white');
    end
    subplot(length(freqs),1,i);
    n = length(cumulativeMeans);
    fit_start = floor(size(cumulativeMeans,1)*0.2);
    
    x_fit = cumulativeMeans(fit_start:n);
    x = (x_fit - mean(x_fit))/std(x_fit);
    h = kstest(x,'tail','larger');
    [xMu,xSigma] = normfit(x_fit,0.01);

    
    plot(1:fit_start-1, cumulativeMeans(1:fit_start-1), 'b--', 'LineWidth', 1.8);
    hold on;
    plot(fit_start:n, x_fit, 'b', 'LineWidth', 1.8);
    yline(cumulativeMeans(end), 'r--', 'LineWidth', 1.5, 'Label', 'lastvalue');
    hold off;
    title(freqs{i},'FontSize', 10, 'FontWeight', 'bold');
    xlabel('#Trades', 'FontSize', 10);
    ylabel('Win Ratio', 'FontSize', 10);
%     set(gca, 'FontSize', 11, 'XScale', 'log');
end    
%%  
for i = 1:length(freqs)
    cumulativeMeans = statsout{i}.RRunning;
    if i == 1
        figure('color','white');
    end
    subplot(length(freqs),1,i);
    n = length(cumulativeMeans);
    fit_start = floor(size(cumulativeMeans,1)*0.2);
    
    x_fit = cumulativeMeans(fit_start:n);
    x = (x_fit - mean(x_fit))/std(x_fit);
    h = kstest(x,'tail','larger');
    [xMu,xSigma] = normfit(x_fit,0.01);

    
    plot(1:fit_start-1, cumulativeMeans(1:fit_start-1), 'b--', 'LineWidth', 1.8);
    hold on;
    plot(fit_start:n, x_fit, 'b', 'LineWidth', 1.8);
    yline(cumulativeMeans(end), 'r--', 'LineWidth', 1.5, 'Label', 'lastvalue');
    hold off;
    title(freqs{i},'FontSize', 10, 'FontWeight', 'bold');
    xlabel('#Trades', 'FontSize', 10);
    ylabel('Fraction Odds', 'FontSize', 10);
%     set(gca, 'FontSize', 11, 'XScale', 'log');
end
%%
for i = 1:length(freqs)
    fprintf('%3s: win ratio:%.2f%% (kelly: %.2f%%)\n', ...
        freqs{i}, statsout{i}.Pwin*100,statsout{i}.Kret*100);
end



