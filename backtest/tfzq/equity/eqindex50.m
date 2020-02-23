if ~(exist('conn','var') && isa(conn,'cBloomberg')), conn = cBloomberg;end
code_bbg_underlier = '510050 CH Equity';
% historical data
dt1 = datenum('2017-01-01');
dt2 = getlastbusinessdate;
p = conn.history(code_bbg_underlier,{'px_open','px_high','px_low','px_last'},dt1,dt2);
%%
res = tools_technicalplot1(p,2);
res(:,1) = x2mdate(res(:,1));
res = timeseries_window(res,'fromdate','2017-01-01','todate','2020-02-21');
tools_technicalplot2(res);
%
px = res(:,1:5);
HH = res(:,7);LL = res(:,8);
jaw = res(:,9);teeth = res(:,10);lips = res(:,11);
bs = res(:,12);ss = res(:,13);
lvlup = res(:,14);lvldn = res(:,15);
bc = res(:,16);sc = res(:,17);
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
% optional:exclude sell countdown 13 
for i = 1:size(idxfractalb1,1)
    j = idxfractalb1(i,1);
    if sc(j) == 13 && lips(j)>teeth(j)&&teeth(j)>jaw(j),idxfractalb1(i,2) = 0;end
end
idxfractalb1 = idxfractalb1(idxfractalb1(:,2) ~= 0,:);
%optional:exclude perfect sell sequential if it is not a 'strong' breach
for i = 1:size(idxfractalb1,1)
    if idxfractalb1(i,2) == 3, continue;end
    %teeth is less than jaw in other cases
    j = idxfractalb1(i,1);
    if ss(j) >= 9 && px(j,5) >= max(px(j-ss(j)+1:j,5)) && px(j,3) >= max(px(j-ss(j)+1:j,3))
        idxfractalb1(i,2) = 0;
    end
    %in weak or medium case we need lips greater than jaw
    if lips(j) < jaw(j)
        idxfractalb1(i,2) = 0;
    end
end
idxfractalb1 = idxfractalb1(idxfractalb1(:,2) ~= 0,:);
%
tradesfractalb1 = cTradeOpenArray;
for i = 1:size(idxfractalb1,1)
    j = idxfractalb1(i);
    signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency','1d');
    riskmanager = struct('hh0_',HH(j),'hh1_',HH(j),'ll0_',LL(j),'ll1_',LL(j),'type_','breachup-B');
    tradenew = cTradeOpen('id',i,'opendatetime',px(j,1),'openprice',px(j,5),...
        'opendirection',1,'openvolume',1);
    tradenew.status_ = 'set';
    tradenew.setsignalinfo(signalinfo);
    tradenew.setriskmanager('name','spiderman','extrainfo',riskmanager);
    if ss(j) >= 9
        ssreached = ss(j);
        tradenew.riskmanager_.tdhigh_ = max(px(end-ssreached+1:end,3));
        tdidx = find(px(end-ssreached+1:end,3)==tradenew.riskmanager_.tdhigh_,1,'last')+length(px)-ssreached;
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
flagweaks1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','weak');
flagmediums1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','medium');
flagstrongs1 = fractal_isbreachs(px,HH,LL,jaw,teeth,lips,'level','strong');
flags1 = flagweaks1 + flagmediums1 + flagstrongs1;
%1.weak;2.medium;3.strong
idxfractals1 = [find(flags1==1),ones(length(find(flags1==1)),1);...
    find(flags1==2),2*ones(length(find(flags1==2)),1);...
    find(flags1==3),3*ones(length(find(flags1==3)),1)];
idxfractals1 = sortrows(idxfractals1);
% optional:exclude buy countdown 13 
% for i = 1:size(idxfractals1,1)
%     j = idxfractals1(i,1);
%     if bc(j) == 13,idxfractals1(i,2) = 0;end
% end
% idxfractals1 = idxfractals1(idxfractals1(:,2) ~= 0,:);
%optional:exclude perfect buy sequential if it is not a 'strong' breach
% for i = 1:size(idxfractals1,1)
%     if idxfractals1(i,2) == 3, continue;end
%     %teeth is less than jaw in other cases
%     j = idxfractals1(i,1);
%     if bs(j) >= 9 && px(j,5) <= min(px(j-bs(j)+1:j,5)) && px(j,4) <= min(px(j-bs(j)+1:j,4))
%         idxfractals1(i,2) = 0;
%     end
%     %in weak or medium case we need lips less than jaw
%     if lips(j) > jaw(j)
%         idxfractals1(i,2) = 0;
%     end
% end
idxfractals1 = idxfractals1(idxfractals1(:,2) ~= 0,:);
%
tradesfractals1 = cTradeOpenArray;
for i = 1:size(idxfractals1,1)
    j = idxfractals1(i);
    signalinfo = struct('name','fractal','hh',HH(j),'ll',LL(j),'frequency','1d');
    riskmanager = struct('hh0_',HH(j),'hh1_',HH(j),'ll0_',LL(j),'ll1_',LL(j),'type_','breachdn-S');
    tradenew = cTradeOpen('id',i,'opendatetime',px(j,1),'openprice',px(j,5),...
        'opendirection',-1,'openvolume',1);
    tradenew.status_ = 'set';
    tradenew.setsignalinfo(signalinfo);
    tradenew.setriskmanager('name','spiderman','extrainfo',riskmanager);
    if bs(j) >= 9
        bsreached = bs(j);
        tradenew.riskmanager_.tdlow_ = min(px(end-ssreached+1:end,4));
        tdidx = find(px(end-bsreached+1:end,4)==tradenew.riskmanager_.tdlow_,1,'last')+length(px)-bsreached;
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

