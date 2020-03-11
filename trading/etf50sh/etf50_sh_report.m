hd_50etf = cDataFileIO.loadDataFromTxtFile('510050_daily.txt');
op_50etf = tools_technicalplot1(hd_50etf,2,0,'change',0.001,'volatilityperiod',0);
[wad_50etf,trh_50etf,trl_50etf] = williamsad(hd_50etf,0);
shift = 60;
tools_technicalplot2(op_50etf(end-shift:end,:),1,'510050 CH Equity',true);
%%
fprintf('510050 SH Equity:\n');
fprintf('%15s\t%s\n','date:',datestr(hd_50etf(end,1),'yyyy-mm-dd'));
fprintf('%15s\t%s\n','closeprice:',num2str(hd_50etf(end,5)));
fprintf('%15s\t%4.1f%%\n','pricechg%:',100*(hd_50etf(end,5)/hd_50etf(end-1,5)-1));
fprintf('%15s\t%4.1f%%\n','volumechg%:',100*(hd_50etf(end,6)/hd_50etf(end-1,6)-1));
fprintf('%15s\t%s\n','f-upper:',num2str(op_50etf(end,7)));
fprintf('%15s\t%s\n','f-lower:',num2str(op_50etf(end,8)));
fprintf('%15s\t%s\n','tdst-upper:',num2str(op_50etf(end,14)));
fprintf('%15s\t%s\n','tdst-lower:',num2str(op_50etf(end,15)));
%
volume_opt50_c_mar = zeros(length(k_50),2);
volume_opt50_p_mar = zeros(length(k_50),2);
for i = 1:length(opt50_c_mar)
    code_bbg = opt50_c_mar{i};
    fn = [code_bbg(1:6),'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7),'_daily.txt'];
    data = cDataFileIO.loadDataFromTxtFile(fn);
    volume_opt50_c_mar(i,1) = data(end-1,6);
    volume_opt50_c_mar(i,2) = data(end,6);
    %
    code_bbg = opt50_p_mar{i};
    fn = [code_bbg(1:6),'_',datestr(code_bbg(11:18),'mmmyy'),'_',code_bbg(20:end-7),'_daily.txt'];
    data = cDataFileIO.loadDataFromTxtFile(fn);
    volume_opt50_p_mar(i,1) = data(end-1,6);
    volume_opt50_p_mar(i,2) = data(end,6);
end
pcratio = sum(volume_opt50_p_mar(:,2))/sum(volume_opt50_c_mar(:,2));
fprintf('%15s\t%4.2f\n','pc-ratio',pcratio);
%
%
n_opt50_c_mar = length(opt50_c_mar);
bd_opt50_c_mar = cell(n_opt50_c_mar,1);
tbl_opt50_c_mar = [k_50',zeros(n_opt50_c_mar,3)];
cobdate = hd_50etf(end,1);
for i = 1:length(opt50_c_mar)
    try
        bd_opt50_c_mar{i} = pnlriskbreakdownbbg(opt50_c_mar{i},datenum(cobdate));
        tbl_opt50_c_mar(i,2) = bd_opt50_c_mar{i}.iv1;
        tbl_opt50_c_mar(i,3) = bd_opt50_c_mar{i}.iv2;
        tbl_opt50_c_mar(i,4) = bd_opt50_c_mar{i}.deltacarry/bd_opt50_c_mar{i}.spot2/10000;
    catch
        bd_opt50_c_mar{i} = [];
        tbl_opt50_c_mar(i,2:4) = NaN;
    end
end
% PUT
n_opt50_p_mar = n_opt50_c_mar;
bd_opt50_p_mar = cell(n_opt50_p_mar,1);
tbl_opt50_p_mar = [k_50',zeros(n_opt50_p_mar,3)];
for i = 1:n_opt50_p_mar
    try
        bd_opt50_p_mar{i} = pnlriskbreakdownbbg(opt50_p_mar{i},datenum(cobdate));
        tbl_opt50_p_mar(i,2) = bd_opt50_p_mar{i}.iv1;
        tbl_opt50_p_mar(i,3) = bd_opt50_p_mar{i}.iv2;
        tbl_opt50_p_mar(i,4) = bd_opt50_p_mar{i}.deltacarry/bd_opt50_p_mar{i}.spot2/10000;
    catch
        bd_opt50_p_mar{i} = [];
        tbl_opt50_p_mar(i,2:4) = NaN;
    end
end
fwd1 = bd_opt50_c_mar{1}.fwd1;fwd2 = bd_opt50_c_mar{1}.fwd2;
m1 = tbl_opt50_c_mar(:,1)/fwd1;
m2 = tbl_opt50_c_mar(:,1)/fwd2;
m = max(min(m1),min(m2)):0.01:min(max(m1),max(m2));
volinterp1 = interp1(m1,tbl_opt50_c_mar(:,2),m);
volinterp2 = interp1(m1,tbl_opt50_c_mar(:,3),m);
atmf1 = interp1(m1,tbl_opt50_c_mar(:,2),1);
atmf2 = interp1(m1,tbl_opt50_c_mar(:,3),1);
fprintf('%15s\t%4.1f%%\n','atmfvol:',atmf2*100);
fprintf('%15s\t%4.1f%%\n','atmfvolchg:',(atmf2-atmf1)*100);

subplot(211);
% plot(m1,tbl_c_mar(:,2),'-');hold on;
plot(m,volinterp1,'-');hold on;
if bd_opt50_c_mar{1}.spot1 < bd_opt50_c_mar{1}.spot2
    color = 'r';
    plot(m,volinterp2,'r-');
else
    color = 'g';
    plot(m,volinterp2,'g-');
end
hold off;
legend(bd_opt50_c_mar{1}.date1,bd_opt50_c_mar{1}.date2);
xlabel('moneyness');ylabel('vol');
subplot(212);

bar(m,volinterp2-volinterp1,color);
xlabel('moneyness');ylabel('spread');