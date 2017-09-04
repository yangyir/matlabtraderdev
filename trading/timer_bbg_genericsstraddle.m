%%
% initialization
answer = who('c');
if isempty(answer) || isempty(c)
    c = bbgconnect;
end
display(c);

%%
% --- user inputs of timer object
%number of seconds between the start of the timer and the first execution 
%of the function specified in 'TimerFcn'
delay = 4;
%number of seconds between execuations of 'TimerFcn'
period = 60;
%string representing the timer object
name = 'GenericStraddle';
%string that defines how the timer object schedules timer event
executionMode = 'fixedRate';
%number greater than 0,indicating the number of times the timer object is
%to execute the 'TimerFcn' callback
tasksToExecute = Inf;

%%
% --- user inputs of trading underlying variables
instrument = struct('BloombergCode','jpy curncy','ContractSize',100);
iv = struct('Instrument',instrument,'Vol',0.11);
stradTradeDate = today;
stradExpiryDate = dateadd(stradTradeDate,'1m');
stradNotional = 1e6;

strad = cStraddle('underlier',instrument,...
    'strike',1,...
    'tradedate',stradTradeDate,...
    'expirydate',stradExpiryDate,...
    'notional',stradNotional);

%%
%create the timer object
mode = 'realtime';
timerGenericStraddle = timer('Name',name,'StartDelay',delay,...
    'Period',period,'ExecutionMode',executionMode,...
    'TasksToExecute',tasksToExecute,'UserData',{});

%specify the value of the 'StartFcn' callback.
timerGenericStraddle.StartFcn = @(~,thisEvent)fprintf('%s timer starts on %s\n',...
    name,datestr(thisEvent.Data.time));

%specify the value of the 'StopFcn' callback
timerGenericStraddle.StopFcn = @(~,thisEvent)fprintf('%s timer stops on %s\n',...
    name,datestr(thisEvent.Data.time));

%specify the value of the 'TimerFcn' callback
timerGenericStraddle.TimerFcn = {@callback_bbg_genericstraddle,'Connection',c,...
    'Product',strad,'Vol',iv,'Mode',mode};

start(timerGenericStraddle);