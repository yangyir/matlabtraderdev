quantform = cFORM('UseMT5',1,...
    'SignalFrequency','H1',...
    'IncludeBreachTDSQLevel',0,...
    'IncludeBreachTDSQHV',0);
codes = quantform.codes_;
ncodes = length(codes);
%% ATRSL calibration
atrsl_initial = 2.0;
atrsl_guess = 1.8;
xvalues = zeros(ncodes,1);
target = 0.9;
for i = 1:ncodes
    tradeout =  quantform.gettradesbest('code',codes{i},'datefrom','2023-07-01');
    output = charlotte_atr_run('Trades',tradeout,...
        'ExtraInfo',quantform.ei_signal_{i},...
        'ATRBreakEven',[],...
        'ATRSL',atrsl_initial,...
        'ATRTP',[]);
    pnl = output.PnL;
    atrmae = output.MAE;
    atrmfe = output.MFE;
    initialloss = output.InitialLoss;

    % initial stop optimization with profit-weighted MAE
    idxwin = pnl >= 0;
    maedist = [atrmae(idxwin),pnl(idxwin)];
    maedist = sortrows(maedist);
    idx = find(maedist(:,1)<=atrsl_guess,1,'last');
    v = cumsum(maedist(:,2));
    xvalues(i) = v(idx)/v(end);
    if xvalues(i) > target
        fprintf('%s:ATRSL pass with %2.1f at %2.1f%%\n',codes{i},atrsl_guess,100*xvalues(i));
    else
        fprintf('%s:ATRSL failed with %2.1f at %2.1f%%\n',codes{i},atrsl_guess,100*xvalues(i));
    end
end
%% ATRTP calibration
tps = 2.0:0.1:6;
ntps = length(tps);
sharpstp = cell(ncodes,1);
totalpnltp = cell(ncodes,1);
yvalues = zeros(ncodes,1);
for i = 1:ncodes
    tradeout =  quantform.gettradesbest('code',codes{i},'datefrom','2023-07-01');
    output = charlotte_atr_run('Trades',tradeout,...
    'ExtraInfo',quantform.ei_signal_{i},...
    'ATRBreakEven',[],...
    'ATRSL',1.8,...
    'ATRTP',[]);
    
    pnl = output.PnL;
    atrmae = output.MAE;
    atrmfe = output.MFE;
    initialloss = output.InitialLoss;

    mfedist = [atrmfe,pnl,initialloss];
    sharp_i = zeros(ntps,1);
    totalpnl_i = zeros(ntps,1);

    for j = 1:ntps
        pnl_j = mfedist(:,2);
        for k = 1:size(mfedist,1)
            if mfedist(k,1) > tps(j)
                pnl_j(k) = tps(j)*mfedist(k,3);
            end
        end
        temp = kellyratio2(pnl_j);
        sharp_i(j) = temp.sharp;
        totalpnl_i(j) = temp.totalpl;
    end
    sharpstp{i} = sharp_i;
    totalpnltp{i} = totalpnl_i;
%     [~,idx] = max(totalpnl_i);
%     yvalues(i) = tps(idx);
end

figure(3)
for i = 1:ncodes
    subplot(2,4,i)
    [hAx,hLine1,hLine2] = plotyy(tps,sharpstp{i},tps,totalpnltp{i});
    title(codes{i});
    xlabel('ATRTP');grid on;
    ylabel(hAx(1),'sharp') % left y-axis 
    ylabel(hAx(2),'total pnl') % right y-axis
end
%% ATR Lambda calibration
% ATR lambda calibration
statsperfx = cell(ncodes,1);
atrlambdavec = 0:0.1:1;
nlambda = length(atrlambdavec);
for i = 1:ncodes
    trades_i = quantform.gettradesbest('code',codes{i},'datefrom','2023-07-01');
    ei_i = quantform.ei_signal_{i};
    nbars_i = size(ei_i.px,1);
    ntrades_i = size(trades_i,1);
    stats_i = cell(nlambda,1);
    for ilambda = 1:nlambda
        output = charlotte_atr_run('Trades',trades_i,...
            'ExtraInfo',ei_i,...
            'ATRBreakEven',1.5,...
            'ATRSL',1.8,...
            'ATRTP',5,...
            'ATRLambda',atrlambdavec(ilambda));
        stats_i{ilambda} = kellyratio2(output.PnL);
    end
    statsperfx{i} = stats_i;
end
%%
i = 7;
stats = statsperfx{i};
kvec = 0*atrlambdavec;
wvec = kvec;
rvec = kvec;
sharpvec = kvec;
calmarvec = kvec;
totalpnlvec = kvec;
for j = 1:length(stats)
    kvec(j) = stats{j}.k;
    wvec(j) = stats{j}.w;
    rvec(j) = stats{j}.r;
    sharpvec(j) = stats{j}.sharp;
    calmarvec(j) = stats{j}.calmar;
    totalpnlvec(j) = stats{j}.totalpl;
end
figure(4);
subplot(231);plot(atrlambdavec,kvec,'b');title([codes{i},'-kelly']);xlabel('lamdba');grid on;
subplot(232);plot(atrlambdavec,wvec,'b');title([codes{i},'-winp']);xlabel('lamdba');grid on;
subplot(233);plot(atrlambdavec,rvec,'b');title([codes{i},'-ratio']);xlabel('lamdba');grid on;
subplot(234);plot(atrlambdavec,sharpvec,'b');title([codes{i},'-sharp']);xlabel('lamdba');grid on;
subplot(235);plot(atrlambdavec,calmarvec,'b');title([codes{i},'-calmar']);xlabel('lamdba');grid on;
subplot(236);plot(atrlambdavec,totalpnlvec,'b');title([codes{i},'-pnl']);xlabel('lamdba');grid on;

%% kelly table for all available history
[stratbest,tablebest,tradesbest] = quantform.kellybest;
%%
% kelly table for the last 3 years
[stratbest_3y,tablebest_3y,tradesbest_3y] = quantform.kellybest('datefrom','2023-07-01');
%%
% Kelly table over the last 5 years
[stratbest_5y,tablebest_5y,tradesbest_5y] = quantform.kellybest('datefrom','2021-07-01');
%%
% kelly table cover the covid period
[stratbest_covid,tablebest_covid,tradesbest_covid] = quantform.kellybest('datefrom','2019-12-01','dateto','2022-11-30');
%%
[~,~,tradesempirical] = quantform.kellyempirical('kellytables',stratbest_3y,'datefrom','2023-07-01','overridetrades',0);
