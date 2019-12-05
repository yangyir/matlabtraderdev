function [] = savetrades(obj,varargin)
%cMDEOptSimple
    % the trades are saved between 15:15pm and 15:25pm, when we can disconnect
    % the MDE
    if ~strcmpi(obj.mode_,'realtime'), return; end
    
    if ~obj.qms_.isconnect, return; end

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
        p.parse(varargin{:});
    t = p.Results.Time;
    
    obj.logoff;
    fprintf('cMDEOptSimple:logoff from MD on %s......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
end