function [] = loadmktdata(obj,varargin)
%cMDEOptSimple
    %note:the mktdata is scheduled to be loaded between 08:50am and 09:00am
    %on each trading date
    %and we shall gurantee that we have logged into MD server in the
    %realtime mode
    if strcmpi(obj.mode_,'replay'), return; end
    
    if ~obj.qms_.isconnect
        if ~isempty(obj.qms_.watcher_.ds)
            if isa(obj.qms_.watcher_.ds,'cCTP')
                countername = obj.qms_.watcher_.ds.char;
                obj.login('Connection','CTP','CounterName',countername);
                fprintf('cMDEOptSimple:login to MD server on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
            else
                error('cMDEOptSimple:data source not supported');
            end
        end
    end
end