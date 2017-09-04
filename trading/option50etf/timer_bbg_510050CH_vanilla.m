%create a timer object
etfvanillaTimer = timer('StartDelay', 4, ...
    'Period', 60, ...
    'TasksToExecute', 270, ...
    'ExecutionMode', 'fixedRate');

%Specify the value of the StartFcn callback. Note that the example 
%specifies the value in a cell array because the callback function needs 
%to access arguments passed to it:
etfvanillaTimer.StartFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time),' timer starts...']);


%Specify the value of the StopFcn callback. Again, the value is specified 
%in a cell array because the callback function needs to access the 
%arguments passed to it:
etfvanillaTimer.StopFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time),' timer stops...']);

%Specify the value of the TimerFcn callback. The example specifies the 
%MATLAB commands in a text string:;
tenor = 5;
etfvanillaTimer.TimerFcn = {@callback_bbg_510050CH_vanilla,c,tenor};

set(etfvanillaTimer,'UserData',{});

% %Start the timer object:
start(etfvanillaTimer);
% 
% %Delete the timer object after you are finished with it.
% delete(t);
