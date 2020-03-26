if ~(exist('conn','var') && isa(conn,'cBloomberg')), conn = cBloomberg;end
bbgcode_300etf = '510300 CH Equity';

%%
exp_feb = '2020-02-26';
exp_mar = '2020-03-25';
exp_apr = '2020-04-22';
exp_jun = '2020-06-24';
k_300 = 3.4:0.1:4.4;
opt300_c_feb = cell(length(k_300),1);opt300_p_feb = opt300_c_feb;
opt300_c_mar = cell(length(k_300),1);opt300_p_mar = opt300_c_mar;
opt300_c_apr = cell(length(k_300),1);opt300_p_apr = opt300_c_apr;
opt300_c_jun = cell(length(k_300),1);opt300_p_jun = opt300_c_jun;
for i = 1:length(k_300)
    opt300_c_feb{i} = ['510300 CH ',datestr(exp_feb,'mm/dd/yy'),' C',num2str(k_300(i)),' Equity'];
    opt300_p_feb{i} = ['510300 CH ',datestr(exp_feb,'mm/dd/yy'),' P',num2str(k_300(i)),' Equity'];
    opt300_c_mar{i} = ['510300 CH ',datestr(exp_mar,'mm/dd/yy'),' C',num2str(k_300(i)),' Equity'];
    opt300_p_mar{i} = ['510300 CH ',datestr(exp_mar,'mm/dd/yy'),' P',num2str(k_300(i)),' Equity'];
    opt300_c_apr{i} = ['510300 CH ',datestr(exp_apr,'mm/dd/yy'),' C',num2str(k_300(i)),' Equity'];
    opt300_p_apr{i} = ['510300 CH ',datestr(exp_apr,'mm/dd/yy'),' P',num2str(k_300(i)),' Equity'];
    opt300_c_jun{i} = ['510300 CH ',datestr(exp_jun,'mm/dd/yy'),' C',num2str(k_300(i)),' Equity'];
    opt300_p_jun{i} = ['510300 CH ',datestr(exp_jun,'mm/dd/yy'),' P',num2str(k_300(i)),' Equity'];
end
%%
db = cLocal;
%%
hd_300etf = cDataFileIO.loadDataFromTxtFile('510300_daily.txt');
fprintf('last date recorded on local file is %s\n',datestr(hd_300etf(end,1)));
%%
op_300etf = tools_technicalplot1(hd_300etf,2,0,'change',0.001,'volatilityperiod',0);
shift = 60;
tools_technicalplot2(op_300etf(end-shift:end,:));
%%
n_opt300c_apr = length(opt300_c_apr);
bd_opt300c_apr = cell(n_opt300c_apr,1);
tbl_opt300c_apr = [k_300',zeros(length(k_300),3)];
for i = 1:n_opt300c_apr
    try
        bd_opt300c_apr{i} = pnlriskbreakdownbbg(opt300_c_mar{i},getlastbusinessdate);
        tbl_opt300c_apr(i,2) = bd_opt300c_apr{i}.iv1;
        tbl_opt300c_apr(i,3) = bd_opt300c_apr{i}.iv2;
        tbl_opt300c_apr(i,4) = bd_opt300c_apr{i}.deltacarry/bd_opt300c_apr{i}.spot2/10000;
    catch
        bd_opt300c_apr{i} = [];
        tbl_opt300c_apr(i,2:4) = NaN;
    end
end
% PUT
n_opt300p_apr = length(opt300_p_apr);
bd_opt300p_apr = cell(n_opt300p_apr,1);
tbl_opt300p_apr = [k_300',zeros(length(k_300),3)];
for i = 1:n_opt300p_apr
    try
        bd_opt300p_apr{i} = pnlriskbreakdownbbg(opt300_p_mar{i},getlastbusinessdate);
        tbl_opt300p_apr(i,2) = bd_opt300p_apr{i}.iv1;
        tbl_opt300p_apr(i,3) = bd_opt300p_apr{i}.iv2;
        tbl_opt300p_apr(i,4) = bd_opt300p_apr{i}.deltacarry/bd_opt300p_apr{i}.spot2/10000;
    catch
        bd_opt300p_apr{i} = [];
        tbl_opt300p_apr(i,2:4) = NaN;
    end
end
display(tbl_opt300c_apr);
display(tbl_opt300p_apr);