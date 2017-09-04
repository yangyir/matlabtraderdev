%create a timer object
soymealvanillaTimer = timer('StartDelay', 4, ...
    'Period', 60, ...
    'TasksToExecute', 270, ...
    'ExecutionMode', 'fixedRate');

%Specify the value of the StartFcn callback. Note that the example 
%specifies the value in a cell array because the callback function needs 
%to access arguments passed to it:
soymealvanillaTimer.StartFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time),' timer starts...']);


%Specify the value of the StopFcn callback. Again, the value is specified 
%in a cell array because the callback function needs to access the 
%arguments passed to it:
soymealvanillaTimer.StopFcn = @(~,thisEvent)disp([datestr(thisEvent.Data.time),' timer stops...']);

%Specify the value of the TimerFcn callback. The example specifies the 
%MATLAB commands in a text string:;
tenor = '1709';
soymealvanillaTimer.TimerFcn = {@callback_bbg_soymeal_vanilla,c,tenor};

set(soymealvanillaTimer,'UserData',{});

% %Start the timer object:
start(soymealvanillaTimer);
% 
% %Delete the timer object after you are finished with it.
% delete(t);
