%% 初始化 WIND matlab
if ~exist('w','var') || ~isa(w,'windmatlab')
    w = windmatlab;
end

%% 初始化 pairs
leg1 = 'TF1709.CFE';
leg2 = 'T1709.CFE';
% leg1 = 'TF1712.CFE';
% leg2 = 'T1712.CFE';
pairs = [leg1,',',leg2];
%% 初始化前一个交易日的历史数据(Bloomberg)
fut1 = windcode2contract(leg1(1:length(leg1)-4));
fut2 = windcode2contract(leg2(1:length(leg2)-4));
date_from = '08-May-2017';
date_to = '09-Aug-2017';
freq = '1m';

data1 = fut1.getTimeSeries('connection','bloomberg','fromdate',date_from,...
    'todate',date_to,'fields',{'close','volume'},'frequency',freq);
data2 = fut2.getTimeSeries('connection','bloomberg','fromdate',date_from,...
    'todate',date_to,'fields',{'close','volume'},'frequency',freq);
[t,idx1,idx2] = intersect(data1(:,1),data2(:,1));
externaldata = [t,data1(idx1,2),data2(idx2,2)];


%% 初始化前一个交易日的历史数据(WIND)
% 注释：WIND的数据不是很干净，而且我们也没有用到cContract类的一些方法
lastBusDate = datestr(getlastbusinessdate(today),'yyyy-mm-dd');
startBusDate = datestr(businessdate(lastBusDate,-1),'yyyy-mm-dd');

[externaldata_leg1,~,~,t_leg1] = w.wsi(leg1,'close',[startBusDate,' 09:15:00'],[lastBusDate,' 15:15:00']);
[externaldata_leg2,~,~,t_leg2] = w.wsi(leg2,'close',[startBusDate,' 09:15:00'],[lastBusDate,' 15:15:00']);
% 此处需要对历史数据做一下处理
externaldata_leg1 = [t_leg1,externaldata_leg1];
externaldata_leg2 = [t_leg2,externaldata_leg2];
[t,idx1,idx2] = intersect(externaldata_leg1(:,1),externaldata_leg2(:,1));
externaldata = [t,externaldata_leg1(idx1,2),externaldata_leg2(idx2,2)];

%% 初始化交易model
lookbackPeriod = 270;
rebalancePeriod = 60;
upperBound = 1.65;
lowerBound = -1.65;

model_replay = struct('LookbackPeriod',lookbackPeriod,...
    'RebalancePeriod',rebalancePeriod,...
    'UpperBound',upperBound,...
    'LowerBound',lowerBound,...
    'HD0',externaldata(1:lookbackPeriod,:));

warning('off','econ:egcitest:LeftTailStatTooSmall')
warning('off','econ:egcitest:LeftTailStatTooBig')

%% 初始化 timer
timer_govtbond_replay_pairs = timer('startDelay',4,'period',1,'tasksToExecute',1000,'executionMode','fixedRate');

timer_govtbond_replay_pairs.StartFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time,'yyyy-mm-dd HH:MM'),' timer starts...']);

timer_govtbond_replay_pairs.StopFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time,'yyyy-mm-dd HH:MM'),' timer stops...']);

timer_govtbond_replay_pairs.TimerFcn = {@govtbond_trading_pairs_callback,w,pairs,model_replay,'replay',externaldata};

set(timer_govtbond_replay_pairs,'UserData',{});

%%
%
start(timer_govtbond_replay_pairs);
% 
%%
%
stop(timer_govtbond_replay_pairs);
set(timer_govtbond_replay_pairs,'UserData',{});

%%
scaling = sqrt(252*270);
pairs_integration(externaldata(:,2:3),lookbackPeriod,rebalancePeriod,upperBound,scaling);

