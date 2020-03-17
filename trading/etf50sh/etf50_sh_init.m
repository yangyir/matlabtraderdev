if ~(exist('conn','var') && isa(conn,'cBloomberg')), conn = cBloomberg;end
bbgcode_50etf = '510050 CH Equity';

%%
exp_feb = '2020-02-26';
exp_mar = '2020-03-25';
exp_apr = '2020-04-22';
exp_jun = '2020-06-24';
k_50 = [2.65,2.7,2.75,2.8,2.85,2.9,2.95,3,3.1,3.2,3.3];
opt50_c_feb = cell(length(k_50),1);opt50_p_feb = opt50_c_feb;
opt50_c_mar = cell(length(k_50),1);opt50_p_mar = opt50_c_mar;
opt50_c_apr = cell(length(k_50),1);opt50_p_apr = opt50_c_apr;
opt50_c_jun = cell(length(k_50),1);opt50_p_jun = opt50_c_jun;
for i = 1:length(k_50)
    opt50_c_feb{i} = ['510050 CH ',datestr(exp_feb,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
    opt50_p_feb{i} = ['510050 CH ',datestr(exp_feb,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
    opt50_c_mar{i} = ['510050 CH ',datestr(exp_mar,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
    opt50_p_mar{i} = ['510050 CH ',datestr(exp_mar,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
    opt50_c_apr{i} = ['510050 CH ',datestr(exp_apr,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
    opt50_p_apr{i} = ['510050 CH ',datestr(exp_apr,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
    opt50_c_jun{i} = ['510050 CH ',datestr(exp_jun,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
    opt50_p_jun{i} = ['510050 CH ',datestr(exp_jun,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
end
%%
db = cLocal;
%%
hd_50etf = cDataFileIO.loadDataFromTxtFile('510050_daily.txt');
fprintf('last date recorded on local file is %s\n',datestr(hd_50etf(end,1)));
%%
op_50 = tools_technicalplot1(hd_50etf,2,0,'change',0.001,'volatilityperiod',0);
shift = 60;
tools_technicalplot2(op_50(end-shift:end,:));
%%
n_opt50c_mar = length(opt50_c_mar);
bd_opt50c_mar = cell(n_opt50c_mar,1);
tbl_opt50c_mar = [k_50',zeros(length(k_50),3)];
for i = 1:n_opt50c_mar
    try
        bd_opt50c_mar{i} = pnlriskbreakdownbbg(opt50_c_mar{i},getlastbusinessdate);
        tbl_opt50c_mar(i,2) = bd_opt50c_mar{i}.iv1;
        tbl_opt50c_mar(i,3) = bd_opt50c_mar{i}.iv2;
        tbl_opt50c_mar(i,4) = bd_opt50c_mar{i}.deltacarry/bd_opt50c_mar{i}.spot2/10000;
    catch
        bd_opt50c_mar{i} = [];
        tbl_opt50c_mar(i,2:4) = NaN;
    end
end
% PUT
n_opt50p_mar = length(opt50_p_mar);
bd_opt50p_mar = cell(n_opt50p_mar,1);
tbl_opt50p_mar = [k_50',zeros(length(k_50),3)];
for i = 1:n_opt50p_mar
    try
        bd_opt50p_mar{i} = pnlriskbreakdownbbg(opt50_p_mar{i},getlastbusinessdate);
        tbl_opt50p_mar(i,2) = bd_opt50p_mar{i}.iv1;
        tbl_opt50p_mar(i,3) = bd_opt50p_mar{i}.iv2;
        tbl_opt50p_mar(i,4) = bd_opt50p_mar{i}.deltacarry/bd_opt50p_mar{i}.spot2/10000;
    catch
        bd_opt50p_mar{i} = [];
        tbl_opt50p_mar(i,2:4) = NaN;
    end
end
display(tbl_opt50c_mar);
display(tbl_opt50p_mar);