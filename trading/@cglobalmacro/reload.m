function [] = reload(obj,varargin)
%cglobalmacro
n_rates = size(obj.codes_rates_,1);
n_fx = size(obj.codes_fx_,1);
n_eqindex = size(obj.codes_eqindex_,1);
n_comdty = size(obj.codes_comdty_,1);

obj.dailybarstruct_rates_ = cell(n_rates,1);
obj.dailybarstruct_fx_ = cell(n_fx,1);
obj.dailybarstruct_eqindex_ = cell(n_eqindex,1);
obj.dailybarstruct_comdty_ = cell(n_comdty,1);

obj.dailybarriers_conditional_rates_ = nan(n_rates,2);
obj.dailybarriers_conditional_fx_ = nan(n_fx,2);
obj.dailybarriers_conditional_eqindex_ = nan(n_eqindex,2);
obj.dailybarriers_conditional_comdty_ = nan(n_comdty,2);

nfractal = 2;
doplot = false;
dt2 = getlastbusinessdate;
dt1 = dateadd(dt2,'-3y');
wnames = obj.conn_.ds_.wss(obj.codes_rates_,'sec_name');
for i = 1:n_rates
    data = obj.conn_.history(obj.codes_rates_{i},'open,high,low,close',dt1,dt2);
    fprintf('利率:%s 数据下载完成...\n',wnames{i});
    [~,obj.dailybarstruct_rates_{i}] = tools_technicalplot1(data,nfractal,doplot);       
end
%
wnames = obj.conn_.ds_.wss(obj.codes_fx_,'sec_name');
for i = 1:n_fx
    data = obj.conn_.history(obj.codes_fx_{i},'open,high,low,close',dt1,dt2);
    fprintf('外汇:%s 数据下载完成...\n',wnames{i});
    [~,obj.dailybarstruct_fx_{i}] = tools_technicalplot1(data,nfractal,doplot);
end
%
wnames = obj.conn_.ds_.wss(obj.codes_eqindex_,'sec_name');
for i = 1:n_eqindex
    data = obj.conn_.history(obj.codes_eqindex_{i},'open,high,low,close',dt1,dt2);
    fprintf('股指:%s 数据下载完成...\n',wnames{i});
    [~,obj.dailybarstruct_eqindex_{i}] = tools_technicalplot1(data,nfractal,doplot);
end
%
wnames = obj.conn_.ds_.wss(obj.codes_comdty_,'sec_name');
for i = 1:n_comdty
    data = obj.conn_.history(obj.codes_comdty_{i},'open,high,low,close',dt1,dt2);
    fprintf('商品:%s 数据下载完成...\n',wnames{i});
    [~,obj.dailybarstruct_comdty_{i}] = tools_technicalplot1(data,nfractal,doplot);
end
% calc-signal
ticksize = 0;
for i = 1:n_rates
    [signal,~] = fractal_signal_conditional(obj.dailybarstruct_rates_{i},ticksize,nfractal);
end