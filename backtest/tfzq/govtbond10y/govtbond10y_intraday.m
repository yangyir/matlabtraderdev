db = cLocal;
% code = 'T2003';p = db.intradaybar(code2instrument(code),'2019-11-01','2020-02-07',30,'trade');
code = 'T1912';p = db.intradaybar(code2instrument(code),'2019-08-01','2019-11-07',30,'trade');
%%
nfractals = 6;
res = tools_technicalplot1(p,nfractals,1);res(:,1) = x2mdate(res(:,1));
px = res(:,1:5);
fractalidx = res(:,6);HH = res(:,7);LL = res(:,8);
jaw = res(:,9);teeth = res(:,10);lips = res(:,11);
bs = res(:,12);ss = res(:,13);lvlup = res(:,14);lvldn = res(:,15);bc = res(:,16);sc = res(:,17);
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
%%
tradesfractalb1 = cTradeOpenArray;
for i = 1:size(idxfractalb1,1)
    j = idxfractalb1(i);
    signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency','1d');
    riskmanager = struct('hh0_',HH(j),'hh1_',HH(j),'ll0_',LL(j),'ll1_',LL(j),'type_','breachup-B');
    tradenew = cTradeOpen('id',i,'opendatetime',px(j,1),'openprice',px(j,5),...
        'opendirection',1,'openvolume',1,'code',code);
    tradenew.status_ = 'set';
    tradenew.setsignalinfo(signalinfo);
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
pnlb1 = [idxfractalb1,zeros(tradesfractalb1.latest_,2)];
for i = 1:tradesfractalb1.latest_
    %%
    tradein = tradesfractalb1.node_(i);
    j = idxfractalb1(i,1);
    for k = j+1:length(px)
        extrainfo = struct('p',px(1:k,:),'hh',HH(1:k),'ll',LL(1:k),...
            'jaw',jaw(1:k),'teeth',teeth(1:k),'lips',lips(1:k),...
            'bs',bs(1:k),'ss',ss(1:k),'bc',bc(1:k),'sc',sc(1:k),...
            'lvlup',lvlup(1:k),'lvldn',lvldn(1:k));
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
        pnlb1(i,end) = tradein.runningpnl_;
        pnlb1(i,3) = size(px,1);
    else
        pnlb1(i,end) =  tradein.closepnl_;
        pnlb1(i,3) = find(px(:,1) == tradein.closedatetime1_);
    end
    fprintf('pnl:%s\n',num2str(pnlb1(i,end)));
end
figure(2);plot(cumsum(pnlb1(:,end)));
%%
commentaryb1_2 = cell(tradesfractalb1.latest_,2);
for i = 1:tradesfractalb1.latest_
    %%
    idxopen = pnlb1(i,1);
    idxHH = find(fractalidx(1:idxopen)==1,1,'last');
    if HH(idxHH)<teeth(idxHH-nfractals)
        commentaryb1_2{i,1} = 'buy fractal < teeth';
    end
    idxLL = find(fractalidx(idxHH:idxopen)==-1,1,'first')+idxHH-1;
    if ~isempty(idxLL)
        if LL(idxLL)<teeth(idxLL-nfractals) && idxLL<idxopen
            commentaryb1_2{i,2} = 'sell fractal < teeth between';
        end
    end
end
%% CHECK INDIVIDUAL LONG TRADE
i = 10;
trade2plot = tradesfractalb1.node_(i);
idx1 = find(res(:,1) == trade2plot.opendatetime1_);
if isempty(trade2plot.closedatetime1_)
    idx2 = size(px,1);
else
    idx2 = find(res(:,1) == trade2plot.closedatetime1_);
end
idx2 = min(size(px,1),idx2+5);
idx1 = find(fractalidx(1:idx1)==1,1,'last');
temp = res(idx1-nfractals:idx2,:);
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
%%
tradesfractals1 = cTradeOpenArray;
for i = 1:size(idxfractals1,1)
    j = idxfractals1(i);
    signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency','1d');
    riskmanager = struct('hh0_',HH(j),'hh1_',HH(j),'ll0_',LL(j),'ll1_',LL(j),'type_','breachdn-S');
    tradenew = cTradeOpen('id',i,'opendatetime',px(j,1),'openprice',px(j,5),...
        'opendirection',-1,'openvolume',1,'code',code);
    tradenew.status_ = 'set';
    tradenew.setsignalinfo(signalinfo);
    tradenew.setriskmanager('name','spiderman','extrainfo',riskmanager);
    if bs(j) >= 9
        bsreached = bs(j);
        tradenew.riskmanager_.tdlow_ = min(px(j-ssreached+1:j,4));
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
            'lvlup',lvlup(1:k),'lvldn',lvldn(1:k));
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
%% CHECK INDIVIDUAL SHORT TRADE
i = 4;
trade2plot = tradesfractals1.node_(i);
idx1 = find(res(:,1) == trade2plot.opendatetime1_);
if isempty(trade2plot.closedatetime1_)
    idx2 = size(px,1);
else
    idx2 = find(res(:,1) == trade2plot.closedatetime1_);
end
idx2 = min(size(px,1),idx2+5);
idx1 = find(fractalidx(1:idx1)==1,1,'last');
temp = res(idx1-nfractals:idx2,:);
tools_technicalplot2(temp);