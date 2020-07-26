function [] = savetrades(obj,varargin)
%note:cMDEFut doesn't save trades
%     variablenotused(obj);
% the trades are saved between 15:15pm and 15:25pm, when we can disconnect
% the MDE
    if ~(strcmpi(obj.mode_,'realtime') ||...
            strcmpi(obj.mode_,'demo')) 
        return; 
    end
    
    if ~obj.qms_.isconnect, return; end

    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
        p.parse(varargin{:});
    t = p.Results.Time;
    
    obj.logoff;
    fprintf('cMDEFut:logoff from MD on %s......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
    
end