leg1 = cContract('assetname','govtbond_5y','tenor','1709');
leg2 = cContract('assetname','govtbond_10y','tenor','1709');

date_from = '08-May-2017';
date_to = '09-Aug-2017';

freq = '1m';

data1 = leg1.getTimeSeries('connection','bloomberg','fromdate',date_from,...
    'todate',date_to,'fields',{'close','volume'},'frequency',freq);
data2 = leg2.getTimeSeries('connection','bloomberg','fromdate',date_from,...
    'todate',date_to,'fields',{'close','volume'},'frequency',freq);

%%
[t,idx1,idx2] = intersect(data1(:,1),data2(:,1));
series2 = [t,data1(idx1,2),data2(idx2,2)];
dates = unique(floor(t));
%%
spread = 1.96;
M = 270;
N = 60;
scaling = 16*sqrt(270);

pairs_integration(series2(:,2:end),M,N,spread,scaling);
%%
% [w_wsq_data,w_wsq_codes,w_wsq_fields,w_wsq_times,w_wsq_errorid,w_wsq_reqid]=w.wsq('XAUCNY.IDC','rt_ask1,rt_bid1')
% [w_wsq_data,~,~,~,~,~] = w.wsq('SPTAUUSDOZ.IDC','rt_bid1','rt_ask1')
[w_wsq_data,~,~,~,~,~] = w.wsq('T1712.CFE','rt_bid1,rt_ask1')

%%
leg1 = cContract('assetname','govtbond_5y','tenor','1712');
leg2 = cContract('assetname','govtbond_10y','tenor','1712');

date_from = '07-Aug-2017';
date_to = '09-Aug-2017';

freq = '1m';
data1 = leg1.getTimeSeries('connection','bloomberg','fromdate',date_from,...
    'todate',date_to,'fields',{'close','volume'},'frequency',freq);
data2 = leg2.getTimeSeries('connection','bloomberg','fromdate',date_from,...
    'todate',date_to,'fields',{'close','volume'},'frequency',freq);

%%
[w_wsi_data,]=w.wsi('TF1712.CFE,T1712.CFE','close','2017-08-09 09:15:00','2017-08-09 15:15:00');