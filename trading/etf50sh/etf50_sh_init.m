if ~(exist('conn','var') && isa(conn,'cBloomberg')), conn = cBloomberg;end
bbgcode_50etf = '510050 CH Equity';
%% 5y historical data
% dt1 = dateadd(today,'-3y');
% dt2 = today;
% hd = conn.history(bbgcode_50etf,{'px_open','px_high','px_low','px_last','volume','open_int'},dt1,dt2);
% rt = [hd(2:end,1),log(hd(2:end,5)./hd(1:end-1,5))];
% [res] = bkfunc_hvcalib(rt,'forecastperiod',21, 'printresults',false, 'plotconditonalvariance',true,'scalefactor',sqrt(246));
% res_tdsq = tdsq_plot2(hd(:,1:5),size(hd,1)-252,size(hd,1),0.01);
%%
% exp_feb = '2020-02-26';
exp_mar = '2020-03-25';
exp_jun = '2020-06-24';
k = [2.65,2.7,2.75,2.8,2.85,2.9,2.95,3,3.1,3.2,3.3];
% opt50_c_feb = cell(length(k),1);opt50_p_feb = opt50_c_feb;
opt50_c_mar = cell(length(k),1);opt50_p_mar = opt50_c_mar;
opt50_c_jun = cell(length(k),1);opt50_p_jun = opt50_c_jun;
for i = 1:length(k)
%     opt50_c_feb{i} = ['510050 CH ',datestr(exp_feb,'mm/dd/yy'),' C',num2str(k(i)),' Equity'];
%     opt50_p_feb{i} = ['510050 CH ',datestr(exp_feb,'mm/dd/yy'),' P',num2str(k(i)),' Equity'];
    opt50_c_mar{i} = ['510050 CH ',datestr(exp_mar,'mm/dd/yy'),' C',num2str(k(i)),' Equity'];
    opt50_p_mar{i} = ['510050 CH ',datestr(exp_mar,'mm/dd/yy'),' P',num2str(k(i)),' Equity'];
    opt50_c_jun{i} = ['510050 CH ',datestr(exp_jun,'mm/dd/yy'),' C',num2str(k(i)),' Equity'];
    opt50_p_jun{i} = ['510050 CH ',datestr(exp_jun,'mm/dd/yy'),' P',num2str(k(i)),' Equity'];
end
%%
db = cLocal;