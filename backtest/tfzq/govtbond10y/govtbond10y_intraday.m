db = cLocal;
% code = 'T2006';p = db.intradaybar(code2instrument(code),'2020-02-01','2020-02-24',30,'trade');
% code = 'T2003';p = db.intradaybar(code2instrument(code),'2019-11-01','2020-02-07',30,'trade');
% code = 'T1912';p = db.intradaybar(code2instrument(code),'2019-08-01','2019-11-07',30,'trade');
% code = 'T1909';p = db.intradaybar(code2instrument(code),'2019-05-01','2019-08-07',30,'trade');
% code = 'T1906';p = db.intradaybar(code2instrument(code),'2019-02-01','2019-05-07',30,'trade');
% code = 'T1903';p = db.intradaybar(code2instrument(code),'2018-11-01','2019-02-07',30,'trade');
code = 'T1812';p = db.intradaybar(code2instrument(code),'2018-08-01','2018-11-07',30,'trade');

%%
nfractals = 6;
res = tools_technicalplot1(p,nfractals,1);res(:,1) = x2mdate(res(:,1));
px = res(:,1:5);
fractalidx = res(:,6);HH = res(:,7);LL = res(:,8);
jaw = res(:,9);teeth = res(:,10);lips = res(:,11);
bs = res(:,12);ss = res(:,13);lvlup = res(:,14);lvldn = res(:,15);bc = res(:,16);sc = res(:,17);
%%
[ idxfractalb1,idxfractals1 ] = fractal_genindicators1( px,HH,LL,jaw,teeth,lips );
%%
tradesfractalb1 = fractal_gentradesb1( idxfractalb1,px,HH,LL,bs,ss,'code',code,'freq','30m');
%%
fprintf('\n');pnlb1 = [idxfractalb1,zeros(tradesfractalb1.latest_,2)];
for i = 1:tradesfractalb1.latest_
    %%
    tradein = tradesfractalb1.node_(i);
    tradeout = fractal_runtrade(tradein,px,HH,LL,jaw,teeth,lips,bs,ss,bc,sc,lvlup,lvldn);
    if isempty(tradeout)
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
commentaryb1 = cell(tradesfractalb1.latest_,6);
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
    
    if HH(j) < lips(j),commentaryb1{i,3} = 'hh<lips';end
    
    if idxfractalb1(i,2) == 2 && ss(j) >= 9 && px(j,5) >= max(px(j-ss(j)+1:j,5)) && px(j,3) >= max(px(j-ss(j)+1:j,3))
       commentaryb1{i,4} = 'ssperfect'; 
    end
    
    idxHH = find(fractalidx(1:j)==1,1,'last');
    if HH(idxHH)<teeth(idxHH-nfractals)
        commentaryb1{i,5} = 'buy fractal < teeth';
    end
    idxLL = find(fractalidx(idxHH:j)==-1,1,'first')+idxHH-1;
    if ~isempty(idxLL)
        if LL(idxLL)<teeth(idxLL-nfractals) && idxLL<j
            commentaryb1{i,6} = 'sell fractal < teeth between';
        end
    end 
end

%% CHECK INDIVIDUAL LONG TRADE
i =18;
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
%
%
%%
tradesfractals1 = fractal_gentradess1( idxfractals1,px,HH,LL,bs,ss,'code',code,'freq','30m');
%% RUN PNL OF SHORT TRADES
fprintf('\n');pnls1 = [idxfractals1,zeros(tradesfractals1.latest_,2)];
for i = 1:tradesfractals1.latest_
    %%
    tradein = tradesfractals1.node_(i);
    tradeout = fractal_runtrade(tradein,px,HH,LL,jaw,teeth,lips,bs,ss,bc,sc,lvlup,lvldn);
    if isempty(tradeout)
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
commentarys1 = cell(tradesfractals1.latest_,6);
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
    
    if bc(j) == 13,commentarys1{i,2} = 'bc13';end
    
    if LL(j) > lips(j),commentarys1{i,3} = 'll<lips';end
    
    if idxfractals1(i,2) == 2 && bs(j) >= 9 && px(j,5) <= min(px(j-bs(j)+1:j,5)) && px(j,4) <= min(px(j-bs(j)+1:j,4))
       commentarys1{i,4} = 'bsperfect'; 
    end
    
    idxLL = find(res(1:j,6)==-1,1,'last');
    if LL(idxLL)>teeth(idxLL-2)
        commentarys1{i,5} = 'sell fractal > teeth';
    end
    idxHH = find(res(idxLL:j,6)==1,1,'first')+idxLL-1;
    if ~isempty(idxHH)
        if HH(idxHH)>teeth(idxHH-2) && idxHH<j
            commentarys1{i,6} = 'buy fractal > teeth between';
        end
    end
    
end

%% CHECK INDIVIDUAL SHORT TRADE
i = 13;
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