close all;
hd_50etf = cDataFileIO.loadDataFromTxtFile('510050_daily.txt');
op_50etf = tools_technicalplot1(hd_50etf,2,0,'change',0.001,'volatilityperiod',0);
[wad_50etf,trh_50etf,trl_50etf] = williamsad(hd_50etf,0);
shift = 60;
tools_technicalplot2(op_50etf(end-shift:end,:),1,'510050 CH Equity',true);
%%
close all;
[~,~,~,~,~,~,volsmooth] = fractalenhanced(hd_50etf,2,'volatilityperiod',13,'tolerance',0.001);
figure(2);
plot(volsmooth(end-63:end));xlabel('businessdays');title('volatility monitor');
%%
close all;
fut_50 = code2instrument('IH2006');
raw_50etf = conn.ds_.timeseries(bbgcode_50etf,{today-30,[datestr(today,'yyyy-mm-dd'),' 15:00:00']},1,'trade');
intraday_50etf = timeseries_compress(raw_50etf,'tradinghours',fut_50.trading_hours,'tradingbreak',fut_50.trading_break,'frequency','30m');
op_50etf_intraday = tools_technicalplot1(intraday_50etf,4,0,'change',0.000,'volatilityperiod',0);
tools_technicalplot2(op_50etf_intraday(end-45:end,:),2,'510050-intraday');
%%
close all;
fprintf('510050 SH Equity:\n');
fprintf('%15s\t%s\n','date:',datestr(hd_50etf(end,1),'yyyy-mm-dd'));
fprintf('%15s\t%s\n','closeprice:',num2str(hd_50etf(end,5)));
fprintf('%15s\t%4.1f%%\n','pricechg%:',100*(hd_50etf(end,5)/hd_50etf(end-1,5)-1));
fprintf('%15s\t%4.1f%%\n','volumechg%:',100*(hd_50etf(end,6)/hd_50etf(end-1,6)-1));
fprintf('%15s\t%s\n','f-upper:',num2str(op_50etf(end,8)));
fprintf('%15s\t%s\n','f-lower:',num2str(op_50etf(end,9)));
fprintf('%15s\t%s\n','tdst-upper:',num2str(op_50etf(end,15)));
fprintf('%15s\t%s\n','tdst-lower:',num2str(op_50etf(end,16)));
%
volume_opt50_c_may = zeros(length(k_50),2);
volume_opt50_p_may = zeros(length(k_50),2);
for i = 1:length(opt50_c_may)
    code_bbg = opt50_c_may{i};
    try
        fn = [code_bbg(1:6),'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7),'_daily.txt'];
        data = cDataFileIO.loadDataFromTxtFile(fn);
        volume_opt50_c_may(i,1) = data(end-1,6);
        volume_opt50_c_may(i,2) = data(end,6);
    catch
    end
    %
    code_bbg = opt50_p_may{i};
    try
        fn = [code_bbg(1:6),'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7),'_daily.txt'];
        data = cDataFileIO.loadDataFromTxtFile(fn);
        volume_opt50_p_may(i,1) = data(end-1,6);
        volume_opt50_p_may(i,2) = data(end,6);
    catch
    end
end
pcratio = sum(volume_opt50_p_may(:,2))/sum(volume_opt50_c_may(:,2));
fprintf('%15s\t%4.2f\n','pc-ratio',pcratio);
%
%
n_opt50_c_may = length(opt50_c_may);
bd_opt50_c_may = cell(n_opt50_c_may,1);
tbl_opt50_c_may = [k_50',zeros(n_opt50_c_may,3)];
cobdate = hd_50etf(end,1);
for i = 1:length(opt50_c_may)
    try
        bd_opt50_c_may{i} = pnlriskbreakdownbbg(opt50_c_may{i},datenum(cobdate));
        tbl_opt50_c_may(i,2) = bd_opt50_c_may{i}.iv1;
        tbl_opt50_c_may(i,3) = bd_opt50_c_may{i}.iv2;
        tbl_opt50_c_may(i,4) = bd_opt50_c_may{i}.deltacarry/bd_opt50_c_may{i}.spot2/10000;
    catch
        bd_opt50_c_may{i} = [];
        tbl_opt50_c_may(i,2:4) = NaN;
    end
end
% PUT
n_opt50_p_may = n_opt50_c_may;
bd_opt50_p_may = cell(n_opt50_p_may,1);
tbl_opt50_p_may = [k_50',zeros(n_opt50_p_may,3)];
for i = 1:n_opt50_p_may
    try
        bd_opt50_p_may{i} = pnlriskbreakdownbbg(opt50_p_may{i},datenum(cobdate));
        tbl_opt50_p_may(i,2) = bd_opt50_p_may{i}.iv1;
        tbl_opt50_p_may(i,3) = bd_opt50_p_may{i}.iv2;
        tbl_opt50_p_may(i,4) = bd_opt50_p_may{i}.deltacarry/bd_opt50_p_may{i}.spot2/10000;
    catch
        bd_opt50_p_may{i} = [];
        tbl_opt50_p_may(i,2:4) = NaN;
    end
end
m1 = zeros(length(opt50_c_may),1);
m2 = zeros(length(opt50_c_may),1);
for i = 1:length(opt50_c_may)
    try
        m1(i) = tbl_opt50_c_may(i,1)/bd_opt50_c_may{i}.fwd1;
    catch
        m1(i) = NaN;
    end
    try
        m2(i) = tbl_opt50_c_may(i,1)/bd_opt50_c_may{i}.fwd2;
    catch
        m2(i) = NaN;
    end
end
idx = ~isnan(m1);
m1 = m1(idx);
m2 = m2(idx);
tbl_opt50_c_may = tbl_opt50_c_may(idx,:);
m = max(min(m1),min(m2)):0.01:min(max(m1),max(m2));
volinterp1 = interp1(m1,tbl_opt50_c_may(:,2),m);
volinterp2 = interp1(m1,tbl_opt50_c_may(:,3),m);
atmf1 = interp1(m1,tbl_opt50_c_may(:,2),1);
atmf2 = interp1(m1,tbl_opt50_c_may(:,3),1);
fprintf('%15s\t%4.1f%%\n','atmfvol:',atmf2*100);
fprintf('%15s\t%4.1f%%\n','atmfvolchg:',(atmf2-atmf1)*100);

subplot(211);
% plot(m1,tbl_c_may(:,2),'-');hold on;
plot(m,volinterp1,'-');hold on;
if hd_50etf(end-1,5) < hd_50etf(end,5)
    color = 'r';
    plot(m,volinterp2,'r-');
else
    color = 'g';
    plot(m,volinterp2,'g-');
end
hold off;
legend(datestr(hd_50etf(end-1,1),'yyyy-mm-dd'),datestr(hd_50etf(end,1),'yyyy-mm-dd'));
xlabel('moneyness');ylabel('vol');
subplot(212);

bar(m,volinterp2-volinterp1,color);
xlabel('moneyness');ylabel('spread');