if ~(exist('conn','var') && isa(conn,'cBloomberg')), conn = cBloomberg;end
bbgcode_50etf = '510050 CH Equity';

%%
exp_feb = '2020-02-26';
exp_mar = '2020-03-25';
exp_jun = '2020-06-24';
k = [2.65,2.7,2.75,2.8,2.85,2.9,2.95,3,3.1,3.2,3.3];
opt50_c_feb = cell(length(k),1);opt50_p_feb = opt50_c_feb;
opt50_c_mar = cell(length(k),1);opt50_p_mar = opt50_c_mar;
opt50_c_jun = cell(length(k),1);opt50_p_jun = opt50_c_jun;
for i = 1:length(k)
    opt50_c_feb{i} = ['510050 CH ',datestr(exp_feb,'mm/dd/yy'),' C',num2str(k(i)),' Equity'];
    opt50_p_feb{i} = ['510050 CH ',datestr(exp_feb,'mm/dd/yy'),' P',num2str(k(i)),' Equity'];
    opt50_c_mar{i} = ['510050 CH ',datestr(exp_mar,'mm/dd/yy'),' C',num2str(k(i)),' Equity'];
    opt50_p_mar{i} = ['510050 CH ',datestr(exp_mar,'mm/dd/yy'),' P',num2str(k(i)),' Equity'];
    opt50_c_jun{i} = ['510050 CH ',datestr(exp_jun,'mm/dd/yy'),' C',num2str(k(i)),' Equity'];
    opt50_p_jun{i} = ['510050 CH ',datestr(exp_jun,'mm/dd/yy'),' P',num2str(k(i)),' Equity'];
end
%%
db = cLocal;
%%
hd_50etf = cDataFileIO.loadDataFromTxtFile('510050_daily.txt');
fprintf('last date recorded on local file is %s\n',datestr(hd_50etf(end,1)));
%%
op_50etf = tools_technicalplot1(hd_50etf,2,0,'change',0.001,'volatilityperiod',0);
shift = 60;
tools_technicalplot2(op_50etf(end-shift:end,:));