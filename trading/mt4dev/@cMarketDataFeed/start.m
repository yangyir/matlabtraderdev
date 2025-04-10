function start(obj)
%a cMarketDataFeed method
    if ~obj.Running
        obj.Running = true;
        obj.Timer = timer(...
            'ExecutionMode', 'fixedSpacing', ...
            'Period', obj.UpdateInterval, ...
            'TimerFcn', @(~,~)obj.generateNewData);
        start(obj.Timer);
    end
end