function [] = loadmktdata(obj,varargin)
%cMDEOpt
    if ~obj.fileioflag_, return; end
    %note:the mktdata is scheduled to be loaded between 08:50am and 09:00am
    %on each trading date
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    dtnum = p.Results.Time;
    
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
                fprintf('cMDEOpt:login to MD server on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
            else
                error('cMDEOpt:data source not supported');
            end
        end
    end
end