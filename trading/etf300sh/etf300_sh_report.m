close all;
hd_300etf = cDataFileIO.loadDataFromTxtFile('510300_daily.txt');
op_300etf = tools_technicalplot1(hd_300etf,2,0,'change',0.001,'volatilityperiod',0);
[wad_300etf,trh_300etf,trl_300etf] = williamsad(hd_300etf,0);
shift = 60;
tools_technicalplot2(op_300etf(end-shift:end,:),1,'510300 CH Equity',true);
%%
fprintf('510300 SH Equity:\n');
fprintf('%15s\t%s\n','date:',datestr(hd_300etf(end,1),'yyyy-mm-dd'));
fprintf('%15s\t%s\n','closeprice:',num2str(hd_300etf(end,5)));
fprintf('%15s\t%4.1f%%\n','pricechg%:',100*(hd_300etf(end,5)/hd_300etf(end-1,5)-1));
fprintf('%15s\t%4.1f%%\n','volumechg%:',100*(hd_300etf(end,6)/hd_300etf(end-1,6)-1));
fprintf('%15s\t%s\n','f-upper:',num2str(op_300etf(end,7)));
fprintf('%15s\t%s\n','f-lower:',num2str(op_300etf(end,8)));
fprintf('%15s\t%s\n','tdst-upper:',num2str(op_300etf(end,14)));
fprintf('%15s\t%s\n','tdst-lower:',num2str(op_300etf(end,15)));
%
volume_opt300_c_apr = zeros(length(k_300),2);
volume_opt300_p_apr = zeros(length(k_300),2);
for i = 1:length(opt300_c_apr)
    code_bbg = opt300_c_apr{i};
    fn = [code_bbg(1:6),'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7),'_daily.txt'];
    data = cDataFileIO.loadDataFromTxtFile(fn);
    volume_opt300_c_apr(i,1) = data(end-1,6);
    volume_opt300_c_apr(i,2) = data(end,6);
    %
    code_bbg = opt300_p_apr{i};
    fn = [code_bbg(1:6),'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7),'_daily.txt'];
    data = cDataFileIO.loadDataFromTxtFile(fn);
    volume_opt300_p_apr(i,1) = data(end-1,6);
    volume_opt300_p_apr(i,2) = data(end,6);
end
pcratio = sum(volume_opt300_p_apr(:,2))/sum(volume_opt300_c_apr(:,2));
fprintf('%15s\t%4.2f\n','pc-ratio',pcratio);
%
%
n_opt300_c_apr = length(opt300_c_apr);
bd_opt300_c_apr = cell(n_opt300_c_apr,1);
tbl_opt300_c_apr = [k_300',zeros(n_opt300_c_apr,3)];
cobdate = hd_300etf(end,1);
for i = 1:length(opt300_c_apr)
    try
        bd_opt300_c_apr{i} = pnlriskbreakdownbbg(opt300_c_apr{i},datenum(cobdate));
        tbl_opt300_c_apr(i,2) = bd_opt300_c_apr{i}.iv1;
        tbl_opt300_c_apr(i,3) = bd_opt300_c_apr{i}.iv2;
        tbl_opt300_c_apr(i,4) = bd_opt300_c_apr{i}.deltacarry/bd_opt300_c_apr{i}.spot2/10000;
    catch
        bd_opt300_c_apr{i} = [];
        tbl_opt300_c_apr(i,2:4) = NaN;
    end
end
% PUT
n_opt300_p_apr = n_opt300_c_apr;
bd_opt300_p_apr = cell(n_opt300_p_apr,1);
tbl_opt300_p_apr = [k_300',zeros(n_opt300_p_apr,3)];
for i = 1:n_opt300_p_apr
    try
        bd_opt300_p_apr{i} = pnlriskbreakdownbbg(opt300_p_apr{i},datenum(cobdate));
        tbl_opt300_p_apr(i,2) = bd_opt300_p_apr{i}.iv1;
        tbl_opt300_p_apr(i,3) = bd_opt300_p_apr{i}.iv2;
        tbl_opt300_p_apr(i,4) = bd_opt300_p_apr{i}.deltacarry/bd_opt300_p_apr{i}.spot2/10000;
    catch
        bd_opt300_p_apr{i} = [];
        tbl_opt300_p_apr(i,2:4) = NaN;
    end
end
m1 = zeros(length(opt300_c_apr),1);
m2 = zeros(length(opt300_c_apr),1);
for i = 1:length(opt300_c_apr)
    m1(i) = tbl_opt300_c_apr(i,1)/bd_opt300_c_apr{i}.fwd1;
    m2(i) = tbl_opt300_c_apr(i,1)/bd_opt300_c_apr{i}.fwd2;
end
m = max(min(m1),min(m2)):0.01:min(max(m1),max(m2));
volinterp1 = interp1(m1,tbl_opt300_c_apr(:,2),m);
volinterp2 = interp1(m1,tbl_opt300_c_apr(:,3),m);
atmf1 = interp1(m1,tbl_opt300_c_apr(:,2),1);
atmf2 = interp1(m1,tbl_opt300_c_apr(:,3),1);
fprintf('%15s\t%4.1f%%\n','atmfvol:',atmf2*100);
fprintf('%15s\t%4.1f%%\n','atmfvolchg:',(atmf2-atmf1)*100);

subplot(211);
% plot(m1,tbl_c_apr(:,2),'-');hold on;
plot(m,volinterp1,'-');hold on;
if bd_opt300_c_apr{1}.spot1 < bd_opt300_c_apr{1}.spot2
    color = 'r';
    plot(m,volinterp2,'r-');
else
    color = 'g';
    plot(m,volinterp2,'g-');
end
hold off;
legend(bd_opt300_c_apr{1}.date1,bd_opt300_c_apr{1}.date2);
xlabel('moneyness');ylabel('vol');
subplot(212);

bar(m,volinterp2-volinterp1,color);
xlabel('moneyness');ylabel('spread');