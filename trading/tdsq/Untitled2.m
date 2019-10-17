k1 = 50;
k2 = n_30m;
outputs_30m = tdsq_plot2withboundary(data_govtbond_30m,k1,k2,lf_govtbond);
tdsq_plot2(data_govtbond_30m,k1,k2,lf_govtbond);
%%
idxvec = 2:size(data_govtbond_30m,1);idxvec = idxvec';
ma = outputs_30m.macd;
sigvec = outputs_30m.sig;
diffvec = outputs_30m.macd - outputs_30m.sig;
bs = outputs_30m.tdbuysetup;
ss = outputs_30m.tdsellsetup;
bc = outputs_30m.tdbuycountdown;
sc = outputs_30m.tdsellcountdown;
ub = outputs_30m.upperbound;
lb = outputs_30m.lowerbound;
[mabs,mass] = tdsq_setup(outputs_30m.macd);
[macdbs,macdss] = tdsq_setup(diffvec);

%%
%第一种情况开仓：市场一直向下，只有upperbound而没有lowerbound
%观点是市场依然是bearish知道市场向上突破upperbound后才认为转为bullish
%优化的条件：a.MACD由正转负
%b.MACD在下降通道上,i.e.MACD Buy Setup Sequential>1
openidx1 = idxvec(diffvec(1:end-1) > 0 & diffvec(2:end) < 0 & ...
    macdbs(2:end)>1 & ...
    (ma(2:end)<0 | mabs(2:end)>4) & ...
    ~isnan(ub(2:end)) &...
    isnan(lb(2:end)) & ...
    data_govtbond_30m(2:end,5) < ub(2:end));
%第一种情况风控：
n1 = length(openidx1);
closeidx1 = openidx1;
for i = 1:n1
    ub_i = ub(openidx1(i));
    for j = openidx1(i)+1:size(data_govtbond_30m,1)
        %a.如果开仓后的某一时间周期的收盘价向上突破开仓是的upperbound
        if data_govtbond_30m(j,5) > ub_i
            closeidx1(i) = j;
            break
        end
        %b.如果开仓后的某一时间周期的收盘价计算的MACD由负转正
        if diffvec(j)>0
            closeidx1(i) = j;
            break
        end
        %c.如果开仓后的某一时间周期的MA的Buy Setup Sequential变为0
        if mabs(j) == 0
            closeidx1(i) = j;
            break
        end
        %d.如果开仓后的某一时间周期的MACD的Buy Setup Sequential变成0且MA为正
        if macdbs(j) == 0 && ma(j) > 0
            closeidx1(i) = j;
            break
        end
        %e.如果开仓后的某一时间周期的Buy Countdown大于等于12
        if bc(j) >= 12
            closeidx1(i) = j;
            break
        end
    end
end
pnl1 = data_govtbond_30m(openidx1,5) - data_govtbond_30m(closeidx1,5);
%%
%第二种情况开仓：市场一直向上，只有lowerbound而没有upperbound
%观点是市场依然是bullish知道市场向下突破upperbound后才认为转为bearish
%优化的条件：a.MACD由负转正
%b.MACD在上行通道上,i.e.MACD Sell Setup Sequential>1
openidx2 = idxvec(diffvec(1:end-1) < 0 & diffvec(2:end) > 0 & ...
    macdss(2:end)>1 & ...
    (ma(2:end)>0 | mass(2:end)>4) & ...
    ~isnan(lb(2:end)) &...
    isnan(ub(2:end)) & ...
    data_govtbond_30m(2:end,5) > lb(2:end));
%第二种情况风控：
n2 = length(openidx2);
closeidx2 = openidx2;
for i = 1:n2
    lb_i = lb(openidx2(i));
    for j = openidx2(i)+1:size(data_govtbond_30m,1)
        %a.如果开仓后的某一时间周期的收盘价向下突破开仓是的lowerbound
        if data_govtbond_30m(j,5) < lb_i
            closeidx2(i) = j;
            break
        end
        %b.如果开仓后的某一时间周期的收盘价计算的MACD由正转负
        if diffvec(j)<0
            closeidx2(i) = j;
            break
        end
        %c.如果开仓后的某一时间周期的MA的Sell Setup Sequential变为0
        if mass(j) == 0
            closeidx2(i) = j;
            break
        end
        %d.如果开仓后的某一时间周期的MACD的Buy Setup Sequential变成0且MA为负
        if macdss(j) == 0 && ma(j) < 0
            closeidx2(i) = j;
            break
        end
        %e.如果开仓后的某一时间周期的Sell Countdown大于等于12
        if sc(j) >= 12
            closeidx2(i) = j;
            break
        end
    end
end
pnl2 = -data_govtbond_30m(openidx2,5) + data_govtbond_30m(closeidx2,5);
%%
%第三种开仓情况：市场原本在upperbound之下，然后市场突破了前面的upperbound
%第一步是找到满足条件的突破时间点
openidx3 = idxvec(~isnan(ub(1:end-1)) & ...
    data_govtbond_30m(1:end-1,5) < ub(1:end-1) & ...
    data_govtbond_30m(2:end,5) > ub(1:end-1));
%第二步是确定在突破时间点后，价格继续留在upperbound之上，且MACD转正时为真正的开仓点
for i = 1:n3
    ub_i = ub
    for j = openidx3(i):size(data_govtbond_30m,1)
        if diffvec(j) > 0 && data_govtbond_30m(j,5) > 
        
            closeidx3(i) = j;
            break
        
        

    end
end
n3 = length(openidx3);
closeidx3 = openidx3;
closepx3 = zeros(n3,1);

pnl3 = -data_govtbond_30m(openidx3,5) + data_govtbond_30m(closeidx3,5);
%%
lvlup = outputs_30m.tdstresistence;
lvldn = outputs_30m.tdstsupport;
tempoutput = [openidx3,ss(openidx3),bs(openidx3),data_govtbond_30m(openidx3,5),...
    lvlup(openidx3),lvldn(openidx3),ub(openidx3-1)];


