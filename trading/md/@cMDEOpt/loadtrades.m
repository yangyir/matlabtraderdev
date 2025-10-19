function [] = loadtrades(obj,varargin)
%cMDEOpt doesn't load trades
%     variablenotused(obj)
    %as the trade array is supposed to be loaded via cOps between 1)
    %08:50am and 09:00am or 2)between 20:50pm and 21:00pm, we tried to
    %reconnect the MD then
    if ~(strcmpi(obj.mode_,'realtime') || ...
            strcmpi(obj.mode_,'demo'))
        return
    end
    
    if obj.qms_.isconnect, return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.Time;
    
    if ~isempty(obj.qms_.watcher_.ds)
        if isa(obj.qms_.watcher_.ds,'cCTP')
            countername = obj.qms_.watcher_.ds.char;
            obj.login('Connection','CTP','CounterName',countername);
            fprintf('cMDEOpt:login to TD server on %s......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
        else
            error('cMDEOpt:data source not supported');
        end
    end
end