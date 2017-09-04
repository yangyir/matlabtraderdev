%create a timer object
govtbondRealTimeTimer = timer('StartDelay', 4, ...
    'Period', 60, ...
    'TasksToExecute', 1000, ...
    'ExecutionMode', 'fixedRate');

%Specify the value of the StartFcn callback. Note that the example 
%specifies the value in a cell array because the callback function needs 
%to access arguments passed to it:
govtbondRealTimeTimer.StartFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time),' timer starts...']);


%Specify the value of the StopFcn callback. Again, the value is specified 
%in a cell array because the callback function needs to access the 
%arguments passed to it:
govtbondRealTimeTimer.StopFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time),' timer stops...']);

%Specify the value of the TimerFcn callback. The example specifies the 
%MATLAB commands in a text string:;
govtbondRealTimeTimer.TimerFcn = {@govtbond_trading_realtimecallback,conn,rollinfo5y,rollinfo10y};

set(govtbondRealTimeTimer,'UserData',{});

% %Start the timer object:
start(govtbondRealTimeTimer);
% 
% %Delete the timer object after you are finished with it.
% delete(t);
