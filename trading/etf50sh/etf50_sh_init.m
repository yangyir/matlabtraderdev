if ~(exist('conn','var') && isa(conn,'cBloomberg')), conn = cBloomberg;end
bbgcode_50etf = '510050 CH Equity';

%%
% exp_feb = '2020-02-26';
% exp_mar = '2020-03-25';
exp_apr = '2020-04-22';
exp_may = '2020-05-27';
exp_jun = '2020-06-24';
exp_jul = '2020-07-22';
exp_aug = '2020-08-26';
exp_sep = '2020-09-23';
exp_oct = '2020-10-28';
exp_nov = '2020-11-25';
exp_dec = '2020-12-23';
k_50 = [2.4,2.45,2.5,2.55,2.6,2.65,2.7,2.75,2.8,2.85,2.9,2.95,3,3.1,3.2,3.3,3.4,3.5,3.6,3.7,3.8,3.9,];
% opt50_c_feb = cell(length(k_50),1);opt50_p_feb = opt50_c_feb;
% opt50_c_mar = cell(length(k_50),1);opt50_p_mar = opt50_c_mar;
% opt50_c_apr = cell(length(k_50),1);opt50_p_apr = opt50_c_apr;
% opt50_c_may = cell(length(k_50),1);opt50_p_may = opt50_c_may;
% opt50_c_jun = cell(length(k_50),1);opt50_p_jun = opt50_c_jun;
% opt50_c_jul = cell(length(k_50),1);opt50_p_jul = opt50_c_jul;
% opt50_c_aug = cell(length(k_50),1);opt50_p_aug = opt50_c_aug;
% opt50_c_sep = cell(length(k_50),1);opt50_p_sep = opt50_c_sep;
% opt50_c_oct = cell(length(k_50),1);opt50_p_oct = opt50_c_oct;
opt50_c_nov = cell(length(k_50),1);opt50_p_nov = opt50_c_nov;
opt50_c_dec = cell(length(k_50),1);opt50_p_dec = opt50_c_dec;

for i = 1:length(k_50)
%     opt50_c_feb{i} = ['510050 CH ',datestr(exp_feb,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
%     opt50_p_feb{i} = ['510050 CH ',datestr(exp_feb,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
%     opt50_c_mar{i} = ['510050 CH ',datestr(exp_mar,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
%     opt50_p_mar{i} = ['510050 CH ',datestr(exp_mar,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
%     opt50_c_apr{i} = ['510050 CH ',datestr(exp_apr,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
%     opt50_p_apr{i} = ['510050 CH ',datestr(exp_apr,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
%     opt50_c_may{i} = ['510050 CH ',datestr(exp_may,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
%     opt50_p_may{i} = ['510050 CH ',datestr(exp_may,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
%     opt50_c_jun{i} = ['510050 CH ',datestr(exp_jun,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
%     opt50_p_jun{i} = ['510050 CH ',datestr(exp_jun,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
%     opt50_c_jul{i} = ['510050 CH ',datestr(exp_jul,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
%     opt50_p_jul{i} = ['510050 CH ',datestr(exp_jul,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
%     opt50_c_aug{i} = ['510050 CH ',datestr(exp_aug,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
%     opt50_p_aug{i} = ['510050 CH ',datestr(exp_aug,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
%     opt50_c_sep{i} = ['510050 CH ',datestr(exp_sep,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
%     opt50_p_sep{i} = ['510050 CH ',datestr(exp_sep,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
%     opt50_c_oct{i} = ['510050 CH ',datestr(exp_oct,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
%     opt50_p_oct{i} = ['510050 CH ',datestr(exp_oct,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
    opt50_c_nov{i} = ['510050 CH ',datestr(exp_nov,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
    opt50_p_nov{i} = ['510050 CH ',datestr(exp_nov,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
    opt50_c_dec{i} = ['510050 CH ',datestr(exp_dec,'mm/dd/yy'),' C',num2str(k_50(i)),' Equity'];
    opt50_p_dec{i} = ['510050 CH ',datestr(exp_dec,'mm/dd/yy'),' P',num2str(k_50(i)),' Equity'];
end
%%
db = cLocal;
%%
hd_50etf = cDataFileIO.loadDataFromTxtFile('510050_daily.txt');
fprintf('last date recorded on local file is %s\n',datestr(hd_50etf(end,1)));
%%
% op_50 = tools_technicalplot1(hd_50etf,2,0,'change',0.001,'volatilityperiod',0);
% shift = 60;
% tools_technicalplot2(op_50(end-shift:end,:));
%%
opt50_c_1 = opt50_c_dec;
opt50_p_1 = opt50_c_dec;
n_opt50c = length(k_50);
bd_opt50c_1 = cell(n_opt50c,1);
tbl_opt50c_1 = [k_50',zeros(length(k_50),3)];
for i = 1:n_opt50c
    try
        bd_opt50c_1{i} = pnlriskbreakdownbbg(opt50_c_1{i},getlastbusinessdate);
        tbl_opt50c_1(i,2) = bd_opt50c_1{i}.iv1;
        tbl_opt50c_1(i,3) = bd_opt50c_1{i}.iv2;
        tbl_opt50c_1(i,4) = bd_opt50c_1{i}.deltacarry/bd_opt50c_1{i}.spot2/10000;
    catch
        bd_opt50c_1{i} = [];
        tbl_opt50c_1(i,2:4) = NaN;
    end
end
% PUT
n_opt50p_1 = length(k_50);
bd_opt50p_1 = cell(n_opt50p_1,1);
tbl_opt50p_1 = [k_50',zeros(length(k_50),3)];
for i = 1:n_opt50p_1
    try
        bd_opt50p_1{i} = pnlriskbreakdownbbg(opt50_p_1{i},getlastbusinessdate);
        tbl_opt50p_1(i,2) = bd_opt50p_1{i}.iv1;
        tbl_opt50p_1(i,3) = bd_opt50p_1{i}.iv2;
        tbl_opt50p_1(i,4) = bd_opt50p_1{i}.deltacarry/bd_opt50p_1{i}.spot2/10000;
    catch
        bd_opt50p_1{i} = [];
        tbl_opt50p_1(i,2:4) = NaN;
    end
end
display(tbl_opt50c_1);
display(tbl_opt50p_1);