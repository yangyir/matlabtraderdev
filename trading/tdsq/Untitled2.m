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
%��һ��������֣��г�һֱ���£�ֻ��upperbound��û��lowerbound
%�۵����г���Ȼ��bearish֪���г�����ͻ��upperbound�����ΪתΪbullish
%�Ż���������a.MACD����ת��
%b.MACD���½�ͨ����,i.e.MACD Buy Setup Sequential>1
openidx1 = idxvec(diffvec(1:end-1) > 0 & diffvec(2:end) < 0 & ...
    macdbs(2:end)>1 & ...
    (ma(2:end)<0 | mabs(2:end)>4) & ...
    ~isnan(ub(2:end)) &...
    isnan(lb(2:end)) & ...
    data_govtbond_30m(2:end,5) < ub(2:end));
%��һ�������أ�
n1 = length(openidx1);
closeidx1 = openidx1;
for i = 1:n1
    ub_i = ub(openidx1(i));
    for j = openidx1(i)+1:size(data_govtbond_30m,1)
        %a.������ֺ��ĳһʱ�����ڵ����̼�����ͻ�ƿ����ǵ�upperbound
        if data_govtbond_30m(j,5) > ub_i
            closeidx1(i) = j;
            break
        end
        %b.������ֺ��ĳһʱ�����ڵ����̼ۼ����MACD�ɸ�ת��
        if diffvec(j)>0
            closeidx1(i) = j;
            break
        end
        %c.������ֺ��ĳһʱ�����ڵ�MA��Buy Setup Sequential��Ϊ0
        if mabs(j) == 0
            closeidx1(i) = j;
            break
        end
        %d.������ֺ��ĳһʱ�����ڵ�MACD��Buy Setup Sequential���0��MAΪ��
        if macdbs(j) == 0 && ma(j) > 0
            closeidx1(i) = j;
            break
        end
        %e.������ֺ��ĳһʱ�����ڵ�Buy Countdown���ڵ���12
        if bc(j) >= 12
            closeidx1(i) = j;
            break
        end
    end
end
pnl1 = data_govtbond_30m(openidx1,5) - data_govtbond_30m(closeidx1,5);
%%
%�ڶ���������֣��г�һֱ���ϣ�ֻ��lowerbound��û��upperbound
%�۵����г���Ȼ��bullish֪���г�����ͻ��upperbound�����ΪתΪbearish
%�Ż���������a.MACD�ɸ�ת��
%b.MACD������ͨ����,i.e.MACD Sell Setup Sequential>1
openidx2 = idxvec(diffvec(1:end-1) < 0 & diffvec(2:end) > 0 & ...
    macdss(2:end)>1 & ...
    (ma(2:end)>0 | mass(2:end)>4) & ...
    ~isnan(lb(2:end)) &...
    isnan(ub(2:end)) & ...
    data_govtbond_30m(2:end,5) > lb(2:end));
%�ڶ��������أ�
n2 = length(openidx2);
closeidx2 = openidx2;
for i = 1:n2
    lb_i = lb(openidx2(i));
    for j = openidx2(i)+1:size(data_govtbond_30m,1)
        %a.������ֺ��ĳһʱ�����ڵ����̼�����ͻ�ƿ����ǵ�lowerbound
        if data_govtbond_30m(j,5) < lb_i
            closeidx2(i) = j;
            break
        end
        %b.������ֺ��ĳһʱ�����ڵ����̼ۼ����MACD����ת��
        if diffvec(j)<0
            closeidx2(i) = j;
            break
        end
        %c.������ֺ��ĳһʱ�����ڵ�MA��Sell Setup Sequential��Ϊ0
        if mass(j) == 0
            closeidx2(i) = j;
            break
        end
        %d.������ֺ��ĳһʱ�����ڵ�MACD��Buy Setup Sequential���0��MAΪ��
        if macdss(j) == 0 && ma(j) < 0
            closeidx2(i) = j;
            break
        end
        %e.������ֺ��ĳһʱ�����ڵ�Sell Countdown���ڵ���12
        if sc(j) >= 12
            closeidx2(i) = j;
            break
        end
    end
end
pnl2 = -data_govtbond_30m(openidx2,5) + data_govtbond_30m(closeidx2,5);
%%
%�����ֿ���������г�ԭ����upperbound֮�£�Ȼ���г�ͻ����ǰ���upperbound
%��һ�����ҵ�����������ͻ��ʱ���
openidx3 = idxvec(~isnan(ub(1:end-1)) & ...
    data_govtbond_30m(1:end-1,5) < ub(1:end-1) & ...
    data_govtbond_30m(2:end,5) > ub(1:end-1));
%�ڶ�����ȷ����ͻ��ʱ���󣬼۸��������upperbound֮�ϣ���MACDת��ʱΪ�����Ŀ��ֵ�
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


