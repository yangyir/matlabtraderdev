function [] = OnError(obj,~,eventData)
% a charlotteDataFeedFX method
    msg = eventData.Message;

    if ~strcmpi(obj.onerror_,'resume')
        obj.stop;
        error(msg)
    else
        fprintf('WARNING:%s\n',msg);
    end

end