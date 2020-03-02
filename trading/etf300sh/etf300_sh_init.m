if ~(exist('conn','var') && isa(conn,'cBloomberg')), conn = cBloomberg;end
code_bbg_underlier = '510300 CH Equity';

%%
exp_feb = '2020-02-26';
exp_mar = '2020-03-25';
exp_jun = '2020-06-24';
k = 3.6:0.1:4.4;
opt300_c_feb = cell(length(k),1);opt300_p_feb = opt300_c_feb;
opt300_c_mar = cell(length(k),1);opt300_p_mar = opt300_c_mar;
opt300_c_jun = cell(length(k),1);opt300_p_jun = opt300_c_jun;
for i = 1:length(k)
    opt300_c_feb{i} = ['510300 CH ',datestr(exp_feb,'mm/dd/yy'),' C',num2str(k(i)),' Equity'];
    opt300_p_feb{i} = ['510300 CH ',datestr(exp_feb,'mm/dd/yy'),' P',num2str(k(i)),' Equity'];
    opt300_c_mar{i} = ['510300 CH ',datestr(exp_mar,'mm/dd/yy'),' C',num2str(k(i)),' Equity'];
    opt300_p_mar{i} = ['510300 CH ',datestr(exp_mar,'mm/dd/yy'),' P',num2str(k(i)),' Equity'];
    opt300_c_jun{i} = ['510300 CH ',datestr(exp_jun,'mm/dd/yy'),' C',num2str(k(i)),' Equity'];
    opt300_p_jun{i} = ['510300 CH ',datestr(exp_jun,'mm/dd/yy'),' P',num2str(k(i)),' Equity'];
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