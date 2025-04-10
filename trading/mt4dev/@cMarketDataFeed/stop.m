function stop(obj)
%a cMarketDataFeed function
    if obj.Running
        stop(obj.Timer);
        delete(obj.Timer);
        obj.Running = false;
    end
end