%% parameters
defParams.leftEyeBars = 12;
defParams.minLeftEyeScore = 5.0;
defParams.clusterToleranceATR = 0.25;   
defParams.clusterLookback = 200;    
defParams.maxTimeGap = 30; 
defParams.maxClusterAge = 50;
defParams.strcutureLookback = 100; 
defParams.rejectionScoreThreshold = 4;
defParams.rightEyeWindowLength = 3;
defParams.maxStructureAge = 100;
defParams.invalidationATR = 1.0;
defParams.proximityATR = 0.2;
defParams.leftEyeWeight = 0.3;
defParams.isolatedFractalWeight = 0.6;
%% pre-calculation
freq_h4 = 'h4';
nfractal_h4 = charlotte_freq2nfractal(freq_h4);
dir_ = [getenv('onedrive'),'\fractal backtest\kelly distribution\matlab\fx\'];
data = load([dir_,'strat_fx_h4_recalib.mat']);
strat_fx_h4_recalib = data.strat_fx_h4_recalib;
data = load([dir_,'tbltrades_fx_h4_recalib.mat']);
tbltrades_fx_h4_recalib = data.tbltrades_fx_h4_recalib;

code = 'eurusd';
fut = code2instrument(code);
% ---- load historical data ----
[~,ei] = charlotte_loaddata('futcode',code,'frequency',freq_h4,'nfractal',nfractal_h4,'usemt5',1);
cutoffdt = '2023-09-12';
cutoffidx = find(ei.px(:,1)>=datenum(cutoffdt,'yyyy-mm-dd'),1,'first');
ei = fractal_truncate(ei,size(ei.px,1),cutoffidx);
% ---- fractal clusters ----
clusters = buildfractalclusters('px',ei.px,'topf',ei.topf,'botf',ei.botf,'atr',ei.atr,...
    'nfractal',nfractal_h4,...
    'tolerance',defParams.clusterToleranceATR,...
    'nlookback',defParams.clusterLookback,...
    'maxTimeGap',defParams.maxTimeGap);
% ---- left eye score ----
nBars = size(ei.px,1);
leftEyeScores = struct('top',cell(nBars,1),'bottom',cell(nBars,1));
for i = defParams.leftEyeBars+1:nBars
    if ei.topf(i) == 1
        [score,details] = scorelefteye('px',ei.px,'fractalIdx',i,'fractalType','top',...
            'lefteyebars',defParams.leftEyeBars,...
            'atr',ei.atr);
        leftEyeScores(i).top.score = score;
        leftEyeScores(i).top.details = details;
    end
    if ei.botf(i) == 1
        [score,details] = scorelefteye('px',ei.px,'fractalIdx',i,'fractaslType','bottom',...
            'lefteyebars',defParams.leftEyeBars,...
            'atr',ei.atr);
        leftEyeScores(i).bottom.score = score;
        leftEyeScores(i).bottom.details = details;
    end
end
% ---- structure levels ----
structureLevels = buildrejectionstructures('px',ei.px,...
    'topF',ei.topf,'botF',ei.botf,...
    'atr',ei.atr,...
    'nlookup',defParams.strcutureLookback,...
    'nfractal',nfractal_h4,...
    'scoreThreshold',defParams.rejectionScoreThreshold,...
    'rightEyeWindowLength',defParams.rightEyeWindowLength);

fprintf('pre-calculation done......\n')
%% generate trades with conditional breakout signals
condsignals = cell(nBars,2);
for i = 1:nBars
    ei_ = fractal_truncate(ei,i);
    condsignal = fractal_signal_conditional2('extrainfo',ei_,...
        'ticksize',fut.tick_size,...
        'nfractal',nfractal_h4,...
        'kellytables',strat_fx_h4_recalib,...
        'assetname',fut.asset_name,...
        'ticksizeratio',1);
    if ~isempty(condsignal)
        condsignals{i,1} = condsignal.directionkellied;
        condsignals{i,2} = condsignal;
    end
end
fprintf('conditional signals calculated....\n');
%%
% pop-up trades w.o running through their backtesting
ltrades = cTradeOpenArray;strades = cTradeOpenArray;
for i = 2:nBars
    if isempty(condsignals{i-1}), continue; end
    if condsignals{i-1,1} == 0, continue;end

    ei_ = fractal_truncate(ei,i);
    trade = fractal_gentrade2(ei_,code,i,freq_h4,nfractal_h4,strat_fx_h4_recalib);
    if ~isempty(trade)
        if trade.opendirection_ == 1 && condsignals{i-1,1} == 1
            ltrades.push(trade);
        elseif trade.opendirection_ == -1 && condsignals{i-1,1} == -1
            strades.push(trade);
        end
    end
end
fprintf('trades with conditional breakout signals generated....\n');
%%
topfpoints = find(ei.topf == 1);
botfpoints = find(ei.botf == 1);
trades = ltrades;
ntrades = trades.latest_;
openid = zeros(ntrades,1);
barrierold = zeros(ntrades,1);
barriernew = zeros(ntrades,1);
barrierdistatr = zeros(ntrades,1);
score = zeros(ntrades,1);
bias = cell(ntrades,1);

for i = 1:ntrades
    trade = trades.node_(i);
    openid(i) = trade.id_;
    refidx = trade.id_ - 1;
    % update structure
    structureLevels_i = updatestructurelevels('structures',structureLevels,...
        'px',ei.px,...
        'atr',ei.atr,...
        'topf',ei.topf,...
        'botf',ei.botf,...
        'nfractal',nfractal_h4,...
        'maxStructureAge',defParams.maxStructureAge,...
        'invalidationATR',defParams.invalidationATR,...
        'proximityatr',defParams.proximityATR,...
        'referenceIdx',refidx);
    %
    proximityStatus = checkpriceproximity('currentidx',refidx,...
        'px',ei.px,...
        'atr',ei.atr,...
        'clusters',clusters,...
        'structures',structureLevels_i,...
        'maxclusterage',defParams.maxClusterAge,...
        'maxstructureage',defParams.maxStructureAge,...
        'proximityatr',defParams.proximityATR);
    %
    if trade.opendirection_ == 1
        barrierold(i) = trade.opensignal_.hh_;
        if isempty(proximityStatus.nearestresistancelevel)
            barriernew(i) = nan;
            barrierdistatr(i) = nan;
            j = topfpoints(find(topfpoints<=refidx,1,'last'));
            score(i) = leftEyeScores(j).top.score;
        else
            barriernew(i) = proximityStatus.nearestresistancelevel;
            barrierdistatr(i) = proximityStatus.nearestresistancedistance;
            score(i) = leftEyeScores(proximityStatus.nearestresistanceidx).top.score;
        end
        
    else
        barrierold(i) = trade.opensignal_.ll_;
        if isempty(proximityStatus.nearestsupportlevel)
            barriernew(i) = nan;
            barrierdistatr(i) = nan;
            j = botfpoints(find(botfpoints<=refidx,1,'last'));
            score(i) = leftEyeScores(j).top.score;
        else
            barriernew(i) = proximityStatus.nearestsupportlevel;
            barrierdistatr(i) = proximityStatus.nearestsupportdistance;
            score(i) = leftEyeScores(proximityStatus.nearestsupportidx).bottom.score;
        end
        
    end
    bias{i} = proximityStatus.bias;
end
%
breaktype = zeros(ntrades,1);
breakidx = zeros(ntrades,1);
opensignal = cell(ntrades,1);
shadowlineratio = zeros(ntrades,1);
atropen = zeros(ntrades,1);
atravg = zeros(ntrades,1);

atrmultiplier = 1;
% 1.breach barrier successfully
% 2.stoploss price breached
% 3.reject on open candle given long upper/down shadow line
for i = 1:ntrades
    trade = trades.node_(i);
    checkidx = trade.id_;
    atr_i = ei.atr(checkidx-1);
    atropen(i) = atr_i;
    atravg(i) = mean(ei.atr(checkidx-28:checkidx-1));
    opensignal{i} = trade.opensignal_.mode_;
    shadowlineratio(i) = (ei.px(checkidx,3) - ei.px(checkidx,5))/(ei.px(checkidx,3) - ei.px(checkidx,4));
    for j = checkidx:nBars
        if trade.opendirection_ == 1
            if j == checkidx
                if ei.px(j,5) < barrierold(i)
                    totalrange = ei.px(j,3) - ei.px(j,4);
                    if totalrange < 0.382*ei.atr(j-1)
                        continue;
                    end
                    
                    if shadowlineratio(i) > 0.85 && ei.px(j,5) < ei.px(j,2)
                        breaktype(i) = 3;
                        breakidx(i) = j;
                        break;
                    end
                end

            end


            if ei.px(j,4) < trade.openprice_ - atrmultiplier*atr_i && j > checkidx
                breaktype(i) = 2;
                breakidx(i) = j;
                break
            end

            if ei.px(j,5) > barrierold(i)
                breaktype(i) = 1;
                breakidx(i) = j;
                break;
            end
            

        elseif trade.opendirection_ == -1
            if ei.px(j,3) > trade.openprice_ + atrmultiplier*atr_i && j > checkidx
                breaktype(i) = 2;
                breakidx(i) = j;
                break
            end

            if ei.px(j,5) < barrierold(i)
                breaktype(i) = 1;
                breakidx(i) = j;
                break
            end
        end
    end
end

idx = 1:ntrades;idx = idx';
summaryTable = table(idx,openid,barrierold,barriernew,barrierdistatr,atropen,atravg,score,bias,breaktype,breakidx,opensignal,shadowlineratio);
%% plot
itrade = 8;
idxStart = trades.node_(itrade).id_;

structureLevel_itrade = updatestructurelevels('structures',structureLevels,...
        'px',ei.px,...
        'atr',ei.atr,...
        'topf',ei.topf,...
        'botf',ei.botf,...
        'nfractal',nfractal_h4,...
        'maxStructureAge',defParams.maxStructureAge,...
        'invalidationATR',defParams.invalidationATR,...
        'proximityatr',defParams.proximityATR,...
        'referenceIdx',idxStart-1);

proximityStatus = checkpriceproximity('currentidx',idxStart-1,...
        'px',ei.px,...
        'atr',ei.atr,...
        'clusters',clusters,...
        'structures',structureLevel_itrade,...
        'maxclusterage',defParams.maxClusterAge,...
        'maxstructureage',defParams.maxStructureAge,...
        'proximityatr',defParams.proximityATR);

%% plot trades in multi-dimension
trades = ltrades;
for itrade = 1:trades.latest_
    trade = trades.node_(itrade);
    opensignal = trade.opensignal_.mode_;
    if strcmpi(opensignal,'conditional-uptrendconfirmed-2') || ...
            strcmpi(opensignal,'conditional-uptrendconfirmed-1')
        continue;
    end

    pause(30);

    fractal_plottrade(ltrades.node_(itrade));
    
%     openid = summaryTable.openid(itrade);
%     closeid = [];
%     for i = openid:size(ei.px,1)
%         if ei.px(i,4) < ei.teeth(i)
%             closeid = i;
%             break;
%         end
%     end
%     figure(1);
%     shift = 5;
%     candle(ei.px(openid:closeid+shift,2:5));hold on;
%     stairs(ei.hh(openid) * ones(closeid+shift-openid+1,1),'r--');
%     plot(ei.jaw(openid:closeid+shift),'b');
%     plot(ei.teeth(openid:closeid+shift),'r');
%     plot(ei.lips(openid:closeid+shift),'g');
%     title([num2str(itrade),': eurusd-4h'])
%     hold off;
%     xtick = get(gca,'XTick');
%     nxtick = length(xtick);
%     xticklabel = cell(nxtick,1);
%     for i = 1:nxtick
%         if xtick(i) > size(ei.px,1), continue;end
%         if xtick(i) == 0
%             continue;
%         else
%             try
%                 xticklabel{i}= datestr(ei.px(xtick(i)+openid-1,1),'yyyy-mm-dd HH:MM');
%             catch
%                 continue;
%             end
%         end
%     end
%     set(gca,'XTickLabel',xticklabel,'fontsize',8);
% 
%     % plot how the price behaved in a higher frequency, i.e. 30m
%     idx1_m30 = find(ei_30m.px(:,1) >= ei.px(openid,1),1,'first');
%     idx2_m30 = find(ei_30m.px(:,1) < ei.px(openid+1,1),1,'last');
%     figure(2);
%     try
%         candle(ei_30m.px(idx1_m30:idx2_m30,2:5));hold on;
%         stairs(ei.hh(openid) * ones(idx2_m30-idx1_m30+1,1),'r--');
%         plot(ei_30m.jaw(idx1_m30:idx2_m30),'b');
%         plot(ei_30m.teeth(idx1_m30:idx2_m30),'r');
%         plot(ei_30m.lips(idx1_m30:idx2_m30),'g');
%         title('eurusd-30m')
%         hold off;
%         xtick = get(gca,'XTick');
%         nxtick = length(xtick);
%         xticklabel = cell(nxtick,1);
%         for i = 1:nxtick
%             if xtick(i) > size(ei_30m.px,1), continue;end
%             if xtick(i) == 0
%                 continue;
%             else
%                 try
%                     xticklabel{i}= datestr(ei_30m.px(xtick(i)+idx1_m30-1,1),'yyyy-mm-dd HH:MM');
%                 catch
%                     continue;
%                 end
%             end
%         end
%         set(gca,'XTickLabel',xticklabel,'fontsize',8);
%     catch
%     end
%     % plot how the price behaved in a higher frequency, i.e. 15m
%     idx1_m15 = find(ei_15m.px(:,1) >= ei.px(openid,1),1,'first');
%     idx2_m15 = find(ei_15m.px(:,1) < ei.px(openid+1,1),1,'last');
%     figure(3);
%     try
%         candle(ei_15m.px(idx1_m15:idx2_m15,2:5));hold on;
%         stairs(ei.hh(openid) * ones(idx2_m15-idx1_m15+1,1),'r--');
%         plot(ei_15m.jaw(idx1_m15:idx2_m15),'b');
%         plot(ei_15m.teeth(idx1_m15:idx2_m15),'r');
%         plot(ei_15m.lips(idx1_m15:idx2_m15),'g');
%         title('eurusd-15m')
%         hold off;
%         xtick = get(gca,'XTick');
%         nxtick = length(xtick);
%         xticklabel = cell(nxtick,1);
%         for i = 1:nxtick
%             if xtick(i) > size(ei_30m.px,1), continue;end
%             if xtick(i) == 0
%                 continue;
%             else
%                 try
%                     xticklabel{i}= datestr(ei_15m.px(xtick(i)+idx1_m15-1,1),'yyyy-mm-dd HH:MM');
%                 catch
%                     continue;
%                 end
%             end
%         end
%         set(gca,'XTickLabel',xticklabel,'fontsize',8);
%     catch
%     end

end

    
%%
replay1 = datestr(floor(ei.px(openid,1)),'yyyy-mm-dd');
replay2 = datestr(ceil(ei.px(openid+10,1)),'yyyy-mm-dd');

[ut,ct,tbl2check_fx,resstruct] = charlotte_backtest_period('code','eurusd','fromdate',replay1,'todate',replay2,'kellytables',strat_fx_h4_recalib,'showlogs',true,'doplot',true,'frequency','4h','nfractal',2);
%%
trades = ltrades;
closeids = zeros(trades.latest_,1);
closestr = cell(trades.latest_,1);
closepnl = zeros(trades.latest_,1);
for i = 1:trades.latest_
    trade_i = trades.node_(i);
    for j = trade_i.id_:nBars
        ei_j = fractal_truncate(ei,j);
        ei_j.latestopen = ei.px(j,5);
        ei_j.latestdt = ei.px(j,1);
        tradeout = trade_i.riskmanager_.riskmanagementwithcandle([],...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',ei_j,...
            'RunRiskManagementBeforeMktClose',false,...
            'KellyTables',strat_fx_h4_recalib,...
            'CompulsoryCheckForConditional',true);
        if ~isempty(tradeout)

            closeids(i) = j;
            closestr{i} = tradeout.riskmanager_.closestr_;
            closepnl(i) = tradeout.opendirection_ *(tradeout.closeprice_-tradeout.openprice_);

            break
        end
    end
end
%%
count_m30 = zeros(trades.latest_,1);
count_m15 = zeros(trades.latest_,1);
openpxadj = zeros(trades.latest_,1);
fallbackflag = zeros(trades.latest_,1);
for itrade = 1:trades.latest_
    openid = summaryTable.openid(itrade);
    
    %check with 30m
    idx1_m30 = find(ei_30m.px(:,1) >= ei.px(openid,1),1,'first');
    idx2_m30 = find(ei_30m.px(:,1) < ei.px(openid+1,1),1,'last');
    icount_m30 = 0;
    for k = idx1_m30:idx2_m30
        if ei_30m.px(k-1,5) < summaryTable.barrierold(itrade) && ei_30m.px(k,5) > summaryTable.barrierold(itrade) + fut.tick_size
            icount_m30 = icount_m30 + 1;
            if icount_m30 == 1
               openpxadj(itrade) =  ei_30m.px(k,5) - trades.node_(itrade).openprice_;
            end
            %
        end
        %
        if icount_m30 > 0 && fallbackflag(itrade) == 0 && ei_30m.px(k,5) < summaryTable.barrierold(itrade)
            fallbackflag(itrade) = 1;
        end
    end
    
    count_m30(itrade) = icount_m30;
    %
    %check with 15m
    idx1_m15 = find(ei_15m.px(:,1) >= ei.px(openid,1),1,'first');
    idx2_m15 = find(ei_15m.px(:,1) < ei.px(openid+1,1),1,'last');
    icount_m15 = 0;
    for k = idx1_m15:idx2_m15
        if ei_15m.px(k-1,5) < summaryTable.barrierold(itrade) && ei_15m.px(k,5) > summaryTable.barrierold(itrade) + fut.tick_size
            icount_m15 = icount_m15 + 1;
            if icount_m15 == 1
            end
        end
    end
    count_m15(itrade) = icount_m15;
end



    
    
    


