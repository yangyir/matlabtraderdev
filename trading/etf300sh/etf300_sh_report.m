close all;
hd_300etf = cDataFileIO.loadDataFromTxtFile('510300_daily.txt');
op_300etf = tools_technicalplot1(hd_300etf,2,0,'change',0.001,'volatilityperiod',0);
[wad_300etf,trh_300etf,trl_300etf] = williamsad(hd_300etf,0);
shift = 60;
tools_technicalplot2(op_300etf(end-shift:end,:),1,'510300 CH Equity',true);
fprintf('510300 SH Equity:\n');
fprintf('%15s\t%s\n','date:',datestr(hd_300etf(end,1),'yyyy-mm-dd'));
fprintf('%15s\t%s\n','closeprice:',num2str(hd_300etf(end,5)));
fprintf('%15s\t%4.1f%%\n','pricechg%:',100*(hd_300etf(end,5)/hd_300etf(end-1,5)-1));
fprintf('%15s\t%4.1f%%\n','volumechg%:',100*(hd_300etf(end,6)/hd_300etf(end-1,6)-1));
fprintf('%15s\t%s\n','f-upper:',num2str(op_300etf(end,8)));
fprintf('%15s\t%s\n','f-lower:',num2str(op_300etf(end,9)));
fprintf('%15s\t%s\n','tdst-upper:',num2str(op_300etf(end,15)));
fprintf('%15s\t%s\n','tdst-lower:',num2str(op_300etf(end,16)));
%%
close all;
[~,~,~,~,~,~,volsmooth] = fractalenhanced(hd_300etf,2,'volatilityperiod',13,'tolerance',0.001);
figure(2);
plot(volsmooth(end-63:end));xlabel('businessdays');title('volatility monitor');
%%
close all;
fut_300 = code2instrument('IF2006');
raw_300etf = conn.ds_.timeseries(bbgcode_300etf,{today-30,[datestr(today,'yyyy-mm-dd'),' 15:00:00']},1,'trade');
intraday_300etf = timeseries_compress(raw_300etf,'tradinghours',fut_300.trading_hours,'tradingbreak',fut_300.trading_break,'frequency','30m');
op_300etf_intraday = tools_technicalplot1(intraday_300etf,4,0,'tolerance',0.001,'volatilityperiod',0);
tools_technicalplot2(op_300etf_intraday(end-45:end,:),2,'510300 intraday');
%%
close all;
volume_opt300_c_jul = zeros(length(k_300),2);
volume_opt300_p_jul = zeros(length(k_300),2);
for i = 1:length(opt300_c_jul)
    code_bbg = opt300_c_jul{i};
    try
        fn = [code_bbg(1:6),'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7),'_daily.txt'];
        data = cDataFileIO.loadDataFromTxtFile(fn);
        volume_opt300_c_jul(i,1) = data(end-1,6);
        volume_opt300_c_jul(i,2) = data(end,6);
    catch
    end
    %
    code_bbg = opt300_p_jul{i};
    try
        fn = [code_bbg(1:6),'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7),'_daily.txt'];
        data = cDataFileIO.loadDataFromTxtFile(fn);
        volume_opt300_p_jul(i,1) = data(end-1,6);
        volume_opt300_p_jul(i,2) = data(end,6);
    catch
    end
end
pcratio = sum(volume_opt300_p_jul(:,2))/sum(volume_opt300_c_jul(:,2));
fprintf('%15s\t%4.2f\n','pc-ratio',pcratio);
%
%
n_opt300_c_jul = length(opt300_c_jul);
bd_opt300_c_jul = cell(n_opt300_c_jul,1);
tbl_opt300_c_jul = [k_300',zeros(n_opt300_c_jul,3)];
cobdate = hd_300etf(end,1);
for i = 1:length(opt300_c_jul)
    try
        bd_opt300_c_jul{i} = pnlriskbreakdownbbg(opt300_c_jul{i},datenum(cobdate));
        tbl_opt300_c_jul(i,2) = bd_opt300_c_jul{i}.iv1;
        tbl_opt300_c_jul(i,3) = bd_opt300_c_jul{i}.iv2;
        tbl_opt300_c_jul(i,4) = bd_opt300_c_jul{i}.deltacarry/bd_opt300_c_jul{i}.spot2/10000;
    catch
        bd_opt300_c_jul{i} = [];
        tbl_opt300_c_jul(i,2:4) = NaN;
    end
end
% PUT
n_opt300_p_jul = n_opt300_c_jul;
bd_opt300_p_jul = cell(n_opt300_p_jul,1);
tbl_opt300_p_jul = [k_300',zeros(n_opt300_p_jul,3)];
for i = 1:n_opt300_p_jul
    try
        bd_opt300_p_jul{i} = pnlriskbreakdownbbg(opt300_p_jul{i},datenum(cobdate));
        tbl_opt300_p_jul(i,2) = bd_opt300_p_jul{i}.iv1;
        tbl_opt300_p_jul(i,3) = bd_opt300_p_jul{i}.iv2;
        tbl_opt300_p_jul(i,4) = bd_opt300_p_jul{i}.deltacarry/bd_opt300_p_jul{i}.spot2/10000;
    catch
        bd_opt300_p_jul{i} = [];
        tbl_opt300_p_jul(i,2:4) = NaN;
    end
end
m1 = zeros(length(opt300_c_jul),1);
m2 = zeros(length(opt300_c_jul),1);
for i = 1:length(opt300_c_jul)
    try
        m1(i) = tbl_opt300_c_jul(i,1)/bd_opt300_c_jul{i}.fwd1;
    catch
        m1(i) = NaN;
    end
    try
        m2(i) = tbl_opt300_c_jul(i,1)/bd_opt300_c_jul{i}.fwd2;
    catch
        m2(i) = NaN;
    end
end
idx = ~isnan(m1);
m1 = m1(idx);
m2 = m2(idx);
tbl_opt300_c_jul = tbl_opt300_c_jul(idx,:);
m = max(min(m1),min(m2)):0.01:min(max(m1),max(m2));
volinterp1 = interp1(m1,tbl_opt300_c_jul(:,2),m);
volinterp2 = interp1(m1,tbl_opt300_c_jul(:,3),m);
atmf1 = interp1(m1,tbl_opt300_c_jul(:,2),1);
atmf2 = interp1(m1,tbl_opt300_c_jul(:,3),1);
fprintf('%15s\t%4.1f%%\n','atmfvol:',atmf2*100);
fprintf('%15s\t%4.1f%%\n','atmfvolchg:',(atmf2-atmf1)*100);

subplot(211);
% plot(m1,tbl_c_jul(:,2),'-');hold on;
plot(m,volinterp1,'-');hold on;
if hd_300etf(end-1,5) < hd_300etf(end,5)
    color = 'r';
    plot(m,volinterp2,'r-');
else
    color = 'g';
    plot(m,volinterp2,'g-');
end
hold off;
legend(datestr(hd_300etf(end-1,1),'yyyy-mm-dd'),datestr(hd_300etf(end,1),'yyyy-mm-dd'));
xlabel('moneyness');ylabel('vol');
subplot(212);

bar(m,volinterp2-volinterp1,color);
xlabel('moneyness');ylabel('spread');