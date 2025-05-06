function start(obj)
%a charlotteDataFeedFX method
    if ~obj.running_
        obj.running_ = true;
        obj.timer_ = timer(...
            'ExecutionMode', 'fixedSpacing', ...
            'Period', obj.updateinterval_, ...
            'TimerFcn', @(~,~)obj.generateNewData);
        start(obj.timer_);
        fprintf('fx feed starts...\n');
    end
end