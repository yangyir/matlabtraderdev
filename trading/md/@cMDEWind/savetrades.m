function [] = savetrades(obj,varargin)
%cMDEWind doesn't save trades
%the trades are saved between 15:15pm and 15:25pm, when we can disconnect
%the MDE
    if ~(strcmpi(obj.mode_,'realtime') || ...
            strcmpi(obj.mode_,'demo'))
        return
    end
    
    if isempty(obj.conn_)
        isconnected = false;
    else
        if isa(obj.conn_.ds_,'windmatlab')
            isconnected = obj.conn_.ds_.isconnected;
        else
            isconnected = false;
        end
    end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
        p.parse(varargin{:});
    t = p.Results.Time;
    
    fprintf('cMDEWind:savetrades:%s\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
    
    if ~isconnected, return;end
    
    obj.logoff;
    
    
end