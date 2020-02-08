if ~(exist('conn','var') && isa(conn,'cBloomberg')), conn = cBloomberg;end
code_bbg = 'SSE50 Index';
%% 5y historical data
dt1 = datenum('2014-01-01','yyyy-mm-dd');
dt2 = today;
hd = conn.history(code_bbg,{'px_open','px_high','px_low','px_last'},dt1,dt2);
%%
output = tools_technicalplot1(hd);
output = [x2mdate(output(:,1)),output(:,2:end)];
output2use = timeseries_window(output,'fromdate','2017-01-01','todate',today);
tools_technicalplot2(output2use);
%%
script_buy1;
%%
script_fractal_tdst