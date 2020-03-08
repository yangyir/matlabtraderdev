if ~(exist('conn','var') && isa(conn,'cBloomberg')), conn = cBloomberg;end
code_bbg_underlier = 'SH000905 Index';
% historical data
dt1 = datenum('2010-01-01');
dt2 = getlastbusinessdate;
hd_eqindex500 = conn.history(code_bbg_underlier,{'px_open','px_high','px_low','px_last'},dt1,dt2);