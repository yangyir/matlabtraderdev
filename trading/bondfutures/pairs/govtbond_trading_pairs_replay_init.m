%% init local connection
if ~exist('conn','var') || ~isa(conn,'cLocal'), conn = cLocal;end

%% 初始化 pairs
codes = {'TF1712';'T1712'};
instruments = cell(size(codes,1),1);
for i = 1:size(codes,1)
    instruments{i} = cFutures(codes{i});
    instruments{i}.loadinfo([codes{i},'_info.txt']);
end

%% 初始化前一个交易日的历史数据(Bloomberg)
date_from = '09-Aug-2017';
date_to = '13-Sep-2017';
interval = 1;

data = cell(size(codes,1),1);
for i = 1:size(codes,1)
    data{i} = conn.intradaybar(instruments{i},date_from,date_to,interval,'trade');
end

[t,idx1,idx2] = intersect(data{1}(:,1),data{2}(:,1));
externaldata = [t,data{1}(idx1,end),data{2}(idx2,end)];


%% 初始化前一个交易日的历史数据(WIND)
% 注释：WIND的数据不是很干净，而且我们也没有用到cContract类的一些方法
lastBusDate = datestr(getlastbusinessdate(today),'yyyy-mm-dd');
startBusDate = datestr(businessdate(lastBusDate,-1),'yyyy-mm-dd');

[externaldata_leg1,~,~,t_leg1] = w.wsi(instrument_5y,'close',[startBusDate,' 09:15:00'],[lastBusDate,' 15:15:00']);
[externaldata_leg2,~,~,t_leg2] = w.wsi(leg2,'close',[startBusDate,' 09:15:00'],[lastBusDate,' 15:15:00']);
% 此处需要对历史数据做一下处理
externaldata_leg1 = [t_leg1,externaldata_leg1];
externaldata_leg2 = [t_leg2,externaldata_leg2];
[t,idx1,idx2] = intersect(externaldata_leg1(:,1),externaldata_leg2(:,1));
externaldata = [t,externaldata_leg1(idx1,2),externaldata_leg2(idx2,2)];

%% 初始化交易model
lookbackPeriod = 270;
rebalancePeriod = 60;
upperBound = 3;
lowerBound = -3;

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

