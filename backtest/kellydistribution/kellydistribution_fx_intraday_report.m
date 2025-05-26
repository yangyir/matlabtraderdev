% code2check = 'GBPUSD';
% freq2check = '4h';
% replay1 = '2025-05-01';
% replay2 = '2025-05-26';
% 
% if strcmpi(freq2check,'5m')
%     appendix = 'm5';
% elseif strcmpi(freq2check,'15m')
%     appendix = 'm15';
% elseif strcmpi(freq2check,'30m')
%     appendix = 'm30';
% elseif strcmpi(freq2check,'1h')
%     appendix = 'h1';
% elseif strcmpi(freq2check,'4h')
%     appendix = 'h4';
% end
% 
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
% strat_fx_existing = load([dir_,'strat_fx_',appendix,'.mat']);
% strat_fx_existing = strat_fx_existing.(['strat_fx_',appendix]);
% %
% nfractal2check = charlotte_freq2nfractal(freq2check);
% [ut,ct,tbl2check_fx] = charlotte_backtest_period('code',code2check,'fromdate',replay1,'todate',replay2,'kellytables',strat_fx_existing,'showlogs',false,'doplot',false,'frequency',freq2check,'nfractal',nfractal2check);
% open tbl2check_fx
%%
codes_fx = {'eurusd';'usdjpy';'gbpusd';'audusd';'usdcad';'usdchf';'xauusd'};
freqs = {'5m';'15m';'30m';'1h';'4h'};
freqsmt4 = {'m5';'m15';'m30';'h1';'h4'};
count = 0;
code = cell(100,1);
nTotal = zeros(100,1);
pWin = zeros(100,1);
rRet = zeros(100,1);
kRet = zeros(100,1);
maxDrawdown = zeros(100,1);
annualRet = zeros(100,1);
freqcol = cell(100,1);
cashpnl = zeros(100,1);
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
        freqcol{count} = freqsmt4{ifreq};
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
        cashpnl(count) = sum(tbl2check.closepnl(idxselect));
    end
end
code = code(1:count);
freqcol = freqcol(1:count);
nTotal = nTotal(1:count);
pWin = pWin(1:count);
rRet = rRet(1:count);
kRet = kRet(1:count);
cashpnl = cashpnl(1:count);
maxDrawdown = maxDrawdown(1:count);
annualRet = annualRet(1:count);
tblreport = table(code,freqcol,nTotal,pWin,rRet,kRet,maxDrawdown,annualRet,cashpnl);
tblreport = sortrows(tblreport,'code','ascend');
%%
path_ = [getenv('APPDATA'),'\MetaQuotes\Terminal\Common\Files\Data\'];
fn_ = 'kellytable.txt';
fid = fopen([path_,fn_],'w');
if fid
    fprintf(fid,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',...
        'code',...
        'freq',...
        'nTotal',...
        'pWin',...
        'rRet',...
        'kRet',...
        'maxDrawdownRet',...
        'annualRet');
    for i = 1:size(tblreport,1)
        fprintf(fid,'%s\t%s\t%d\t%f\t%f\t%f\t%f\t%f\n',...
            [upper(code{i}),'.lmx'],...
            upper(freqcol{i}),...
            nTotal(i),...
            pWin(i),...
            rRet(i),...
            kRet(i),...
            maxDrawdown(i),...
            annualRet(i));
            
        
    end
      
end
fclose(fid);  


