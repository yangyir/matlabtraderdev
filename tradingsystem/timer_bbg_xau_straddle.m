%create a timer object
xauStraddleTimer = timer('StartDelay', 4, ...
    'Period', 60, ...
    'TasksToExecute', 270, ...
    'ExecutionMode', 'fixedRate');

%Specify the value of the StartFcn callback. Note that the example 
%specifies the value in a cell array because the callback function needs 
%to access arguments passed to it:
xauStraddleTimer.StartFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time),' starts']);


%Specify the value of the StopFcn callback. Again, the value is specified 
%in a cell array because the callback function needs to access the 
%arguments passed to it:
xauStraddleTimer.StopFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time),' stops']);

%Specify the value of the TimerFcn callback. The example specifies the 
%MATLAB commands in a text string:;
xauStraddleTimer.TimerFcn = {@callback_bbg_xau_straddle,c};

set(xauStraddleTimer,'UserData',{});

% %Start the timer object:
start(xauStraddleTimer);
% 
% %Delete the timer object after you are finished with it.
% delete(t);
