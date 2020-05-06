p = cDataFileIO.loadDataFromTxtFile('510050_daily.txt');
fprintf('last record date:%s\n',datestr(p(end,1)));
%%
nfractal = 2;
res = tools_technicalplot1(p,nfractal,0,'volatilityperiod',0,'tolerance',0.001);
res(:,1) = x2mdate(res(:,1));
px = res(:,1:5);
idxHH = res(:,6);idxLL = res(:,7);HH = res(:,8);LL = res(:,9);
jaw = res(:,10);teeth = res(:,11);lips = res(:,12);
bs = res(:,13);ss = res(:,14);
lvlup = res(:,15);lvldn = res(:,16);
bc = res(:,17);sc = res(:,18);
wad = williamsad(px);
[a,b] = macd(px(:,5));macdvec = a-b;
%%
% res = timeseries_window(res,'fromdate','2017-01-01','todate','2020-02-21');
%tools_technicalplot2(res);
%
%%
flagweakb1 = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,'level','weak');
flagmediumb1 = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,'level','medium');
flagstrongb1 = fractal_isbreachb(px,HH,LL,jaw,teeth,lips,'level','strong');
flagb1 = flagweakb1 + flagmediumb1 + flagstrongb1;
%1.weak;2.medium;3.strong
idxfractalb1 = [find(flagb1==1),ones(length(find(flagb1==1)),1);...
    find(flagb1==2),2*ones(length(find(flagb1==2)),1);...
    find(flagb1==3),3*ones(length(find(flagb1==3)),1)];
idxfractalb1 = sortrows(idxfractalb1);
idxfractalb1 = idxfractalb1(idxfractalb1(:,2) ~= 1,:);
%%
commentsb1 = cell(size(idxfractalb1));
clc;
for i = 1:size(idxfractalb1,1)
    %double check whether the open price on the next candle is still valid
    %for a breach as per trading code
    j = idxfractalb1(i,1);
    if j < size(p,1)
        if p(j,5) <= p(j,3)-0.382*(p(j,3)-LL(j))
            commentsb1{i,1} = 'breach break:below initial stoploss';
            fprintf('%3s:breach break:below initial stoploss:%d\n',num2str(i),j);
            continue
        end
        if p(j,5) > HH(j)+1.618*(HH(j)-LL(j))
            commentsb1{i,1} = 'breach break:above initial target';
            fprintf('%3s:breach break:above initial target:%d\n',num2str(i),j);
            continue
        end
        if p(j+1,2) < lips(j)
            commentsb1{i,1} = 'breach break:next open below lips';
            fprintf('%3s:breach break:next open below lips:%d\n',num2str(i),j);
            continue
        end
        if p(j,5) - HH(j) < 0.0002
            commentsb1{i,1} = 'breach break:close less than 2 ticks above HH';
            fprintf('%3s:breach break:close less than 2 ticks above HH:%d\n',num2str(i),j);
            continue
        end
    end
end
%%
tradesfractalb1 = cTradeOpenArray;
for i = 1:size(idxfractalb1,1)
    j = idxfractalb1(i);
    signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency','daily');
    riskmanager = struct('hh0_',HH(j),'hh1_',HH(j),'ll0_',LL(j),'ll1_',LL(j),'type_','breachup-B',...
        'wadopen_',wad(j),'cpopen_',p(j,5),'wadhigh_',wad(j),'cphigh_',p(j,5),'wadlow_',wad(j),'cplow_',p(j,5));
    tradenew = cTradeOpen('id',i,'opendatetime',px(j,1),'openprice',px(j,5),...
        'opendirection',1,'openvolume',1);
    tradenew.status_ = 'set';
    tradenew.setsignalinfo('name','fractal','extrainfo',signalinfo);
    tradenew.setriskmanager('name','spiderman','extrainfo',riskmanager);
    if ss(j) >= 9
        ssreached = ss(j);
        tradenew.riskmanager_.tdhigh_ = max(px(j-ssreached+1:j,3));
        tdidx = find(px(j-ssreached+1:end,3)==tradenew.riskmanager_.tdhigh_,1,'last')+j-ssreached;
        tradenew.riskmanager_.tdlow_ = px(tdidx,4);
        if tradenew.riskmanager_.tdlow_ - (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_) > tradenew.riskmanager_.pxstoploss_
            tradenew.riskmanager_.pxstoploss_ = tradenew.riskmanager_.tdlow_ - (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_);
        end
    end
    tradesfractalb1.push(tradenew);
end
%%
fprintf('\n');
pnlb1 = [idxfractalb1,zeros(tradesfractalb1.latest_,1)];
for i = 1:tradesfractalb1.latest_
    %%
    tradein = tradesfractalb1.node_(i);
    j = idxfractalb1(i,1);
    for k = j+1:length(px)
        if k == length(px)
            latestopen = p(k,5);
        else
            latestopen = p(k+1,2);
        end
        extrainfo = struct('p',px(1:k,:),'hh',HH(1:k),'ll',LL(1:k),...
            'jaw',jaw(1:k),'teeth',teeth(1:k),'lips',lips(1:k),...
            'bs',bs(1:k),'ss',ss(1:k),'bc',bc(1:k),'sc',sc(1:k),...
            'lvlup',lvlup(1:k),'lvldn',lvldn(1:k),'wad',wad(1:k),...
            'latestopen',latestopen);
        tradeout = tradein.riskmanager_.riskmanagementwithcandle(px(k,:),...
            'usecandlelastonly',false,...
            'debug',false,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',extrainfo);
        if ~isempty(tradeout)
            tradein.closedatetime1_ = px(k,1);
            break;
        end
    end
    if isempty(tradein.closepnl_)
        pnlb1(i,end) = tradein.runningpnl_;
    else
        pnlb1(i,end) =  tradein.closepnl_;
    end
    fprintf('pnl:%s\n',num2str(pnlb1(i,end)));
end
figure(2);plot(cumsum(pnlb1(:,end)));
%%
commentaryb1 = cell(tradesfractalb1.latest_,3);
for i = 1:tradesfractalb1.latest_
    j = idxfractalb1(i,1);
    if jaw(j) < teeth(j) && teeth(j) < lips(j)
        commentaryb1{i,1} = 'jaw<teeth<lips';
    elseif jaw(j) < lips(j) && lips(j) < teeth(j)
        commentaryb1{i,1} = 'jaw<lips<teeth';
    elseif lips(j) < teeth(j) && teeth(j) < jaw(j)
        commentaryb1{i,1} = 'lips<teeth<jaw';
    elseif lips(j) < jaw(j) && jaw(j) < teeth(j)
        commentaryb1{i,1} = 'lips<jaw<teeth';    
    elseif teeth(j) < jaw(j) && jaw(j) < lips(j)
        commentaryb1{i,1} = 'teeth<jaw<lips';
    elseif teeth(j) < lips(j) && lips(j) < jaw(j)
        commentaryb1{i,1} = 'teeth<lips<jaw';
    end
    
    if sc(j) == 13,commentaryb1{i,2} = 'sc13';end
    
    if HH(j) < lips(j)
        commentaryb1{i,3} = 'hh<lips';
    end  
end
%%
commentaryb1_2 = cell(tradesfractalb1.latest_,3);
for i = 1:tradesfractalb1.latest_
    %%
    idxopen = pnlb1(i,1);
    idxHH = find(res(1:idxopen,6)==1,1,'last');
    if HH(idxHH)<teeth(idxHH-2)
        commentaryb1_2{i,1} = 'buy fractal < teeth';
    end
    idxLL = find(res(idxHH:idxopen,6)==-1,1,'first')+idxHH-1;
    if ~isempty(idxLL)
        if LL(idxLL)<teeth(idxLL-2) && idxLL<idxopen
            commentaryb1_2{i,2} = 'sell fractal < teeth between';
        end
    end
end
%%
i = 13;
trade2plot = tradesfractalb1.node_(i);
idx1 = find(res(:,1) == trade2plot.opendatetime1_);
idx2 = find(res(:,1) == trade2plot.closedatetime1_);
idx1 = find(res(1:idx1,6)==1,1,'last');
temp = timeseries_window(res,'fromdate',p(idx1-4,1),'todate',p(idx2+5,1));
tools_technicalplot2(temp);
%%
flagweaks1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','weak');
flagmediums1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','medium');
flagstrongs1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','strong');
flags1 = flagweaks1 + flagmediums1 + flagstrongs1;
%1.weak;2.medium;3.strong
idxfractals1 = [find(flags1==1),ones(length(find(flags1==1)),1);...
    find(flags1==2),2*ones(length(find(flags1==2)),1);...
    find(flags1==3),3*ones(length(find(flags1==3)),1)];
idxfractals1 = sortrows(idxfractals1);
% % optional:exclude buy countdown 13 
% for i = 1:size(idxfractals1,1)
%     j = idxfractals1(i,1);
%     if bc(j) == 13,idxfractals1(i,2) = 0;end
% end
% idxfractals1 = idxfractals1(idxfractals1(:,2) ~= 0,:);
% % optional:exclude perfect buy sequential if it is not a 'strong' breach
% for i = 1:size(idxfractals1,1)
%     if idxfractals1(i,2) == 3, continue;end
%     %teeth is less than jaw in other cases
%     j = idxfractals1(i,1);
%     if bs(j) >= 9 && px(j,5) <= min(px(j-bs(j)+1:j,5)) && px(j,4) <= min(px(j-bs(j)+1:j,4))
%         idxfractals1(i,2) = 0;
%     end
% end
% idxfractals1 = idxfractals1(idxfractals1(:,2) ~= 0,:);
% % optional:exclude those with buy fractal between
% for i = 1:size(idxfractals1,1)
%     idxopen = idxfractals1(i,1);
%     idxLL = find(res(1:idxopen,6)==-1,1,'last');
%     idxHH = find(res(idxLL:idxopen,6)==1,1,'first')+idxLL-1;
%     if ~isempty(idxHH)
%         if HH(idxHH)>teeth(idxHH-2) && idxHH<idxopen
%             idxfractals1(i,2) = 0;
%         end
%     end
% end
% idxfractals1 = idxfractals1(idxfractals1(:,2) ~= 0,:);
% idxfractals1 = idxfractals1(idxfractals1(:,2) ~= 1,:);

%
tradesfractals1 = cTradeOpenArray;
for i = 1:size(idxfractals1,1)
    j = idxfractals1(i);
    signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency','daily');
    riskmanager = struct('hh0_',HH(j),'hh1_',HH(j),'ll0_',LL(j),'ll1_',LL(j),'type_','breachdn-S');
    tradenew = cTradeOpen('id',i,'opendatetime',px(j,1),'openprice',px(j,5),...
        'opendirection',-1,'openvolume',1);
    tradenew.status_ = 'set';
    tradenew.setsignalinfo('name','fractal','extrainfo',signalinfo);
    tradenew.setriskmanager('name','spiderman','extrainfo',riskmanager);
    if bs(j) >= 9
        bsreached = bs(j);
        tradenew.riskmanager_.tdlow_ = min(px(j-bsreached+1:j,4));
        tdidx = find(px(j-bsreached+1:end,4)==tradenew.riskmanager_.tdlow_,1,'last')+j-bsreached;
        tradenew.riskmanager_.tdhigh_ = px(tdidx,3);
        if tradenew.riskmanager_.tdhigh_ + (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_) < tradenew.riskmanager_.pxstoploss_
            tradenew.riskmanager_.pxstoploss_ = tradenew.riskmanager_.tdhigh_ + (tradenew.riskmanager_.tdhigh_-tradenew.riskmanager_.tdlow_);
        end
    end
    tradesfractals1.push(tradenew);
end
%%
fprintf('\n');
pnls1 = [idxfractals1,zeros(tradesfractals1.latest_,2)];
for i = 1:tradesfractals1.latest_
    %%
    tradein = tradesfractals1.node_(i);
    j = idxfractals1(i,1);
    for k = j+1:length(px)
        extrainfo = struct('p',px(1:k,:),'hh',HH(1:k),'ll',LL(1:k),...
            'jaw',jaw(1:k),'teeth',teeth(1:k),'lips',lips(1:k),...
            'bs',bs(1:k),'ss',ss(1:k),'bc',bc(1:k),'sc',sc(1:k),...
            'lvlup',lvlup(1:k),'lvldn',lvldn(1:k),'wad',wad(1:k));
        tradeout = tradein.riskmanager_.riskmanagementwithcandle(px(k,:),...
            'usecandlelastonly',false,...
            'debug',true,...
            'updatepnlforclosedtrade',true,...
            'extrainfo',extrainfo);
        if ~isempty(tradeout)
            tradein.closedatetime1_ = px(k,1);
            break;
        end
    end
    if isempty(tradein.closepnl_)
        pnls1(i,end) = tradein.runningpnl_;
        pnls1(i,3) = size(px,1);
    else
        pnls1(i,end) =  tradein.closepnl_;
        pnls1(i,3) = find(px(:,1) == tradein.closedatetime1_);
    end
    fprintf('pnl:%s\n',num2str(pnls1(i,end)));
end
figure(3);plot(cumsum(pnls1(:,end)));
%%
commentarys1 = cell(tradesfractalb1.latest_,3);
for i = 1:tradesfractals1.latest_
    j = idxfractals1(i,1);
    if jaw(j) < teeth(j) && teeth(j) < lips(j)
        commentarys1{i,1} = 'jaw<teeth<lips';
    elseif jaw(j) < lips(j) && lips(j) < teeth(j)
        commentarys1{i,1} = 'jaw<lips<teeth';
    elseif lips(j) < teeth(j) && teeth(j) < jaw(j)
        commentarys1{i,1} = 'lips<teeth<jaw';
    elseif lips(j) < jaw(j) && jaw(j) < teeth(j)
        commentarys1{i,1} = 'lips<jaw<teeth';    
    elseif teeth(j) < jaw(j) && jaw(j) < lips(j)
        commentarys1{i,1} = 'teeth<jaw<lips';
    elseif teeth(j) < lips(j) && lips(j) < jaw(j)
        commentarys1{i,1} = 'teeth<lips<jaw';
    end
    
    if bc(j) == 13,commentarys1{i,2} = 'sc13';end
    
    if px(j,5) < jaw(j)
        commentarys1{i,3} = 'close<jaw';
    end  
end
%%
i = 32;
trade2plot = tradesfractals1.node_(i);
idx1 = find(res(:,1) == trade2plot.opendatetime1_);
idx2 = find(res(:,1) == trade2plot.closedatetime1_);
idx1 = find(res(1:idx1,7)==-1,1,'last');
temp = timeseries_window(res,'fromdate',p(idx1-4,1),'todate',p(idx2+5,1));
tools_technicalplot2(temp);
%%
commentarys1_2 = cell(tradesfractals1.latest_,3);
for i = 1:tradesfractals1.latest_
    %%
    idxopen = pnls1(i,1);
    idxLL = find(res(1:idxopen,6)==-1,1,'last');
    if LL(idxLL)>teeth(idxLL-2)
        commentarys1_2{i,1} = 'sell fractal > teeth';
    end
    idxHH = find(res(idxLL:idxopen,6)==1,1,'first')+idxLL-1;
    if ~isempty(idxHH)
        if HH(idxHH)>teeth(idxHH-2) && idxHH<idxopen
            commentarys1_2{i,2} = 'buy fractal > teeth between';
        end
    end
end
%%
nb = tradesfractalb1.latest_;
ns = tradesfractals1.latest_;
signal_nb = zeros(size(px,1),nb);
signal_ns = zeros(size(px,1),ns);
ptraded = px(:,5);
for i = 1:nb
    idx1 = find(px(:,1)==tradesfractalb1.node_(i).opendatetime1_);
    idx2 = find(px(:,1)==tradesfractalb1.node_(i).closedatetime1_);
    signal_nb(idx1:idx2-1,i) = 1;
    ptraded(idx2) = tradesfractalb1.node_(i).closeprice_;
end
signal_nb = sum(signal_nb,2);
%
for i = 1:ns
    idx1 = find(px(:,1)==tradesfractals1.node_(i).opendatetime1_);
    try
        idx2 = find(px(:,1)==tradesfractals1.node_(i).closedatetime1_);
    catch
        idx2 = size(px,1);
    end
    signal_ns(idx1:idx2-1,i) = -1;
    try
        ptraded(idx2) = tradesfractals1.node_(i).closeprice_;
    catch
        ptraded(idx2) = px(idx2,5);
    end
end
signal_ns = sum(signal_ns,2);
%
runningpnl = [0;signal_nb(1:end-1).*(ptraded(2:end,1)-ptraded(1:end-1,1))]+...
    [0;signal_ns(1:end-1).*(ptraded(2:end,1)-ptraded(1:end-1,1))];








