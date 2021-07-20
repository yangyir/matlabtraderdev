function [] = loadtrades(obj,varargin)
%cMDEWind doesn't load trades
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
    
    %for equity/fund only
%     if hour(t) >= 15, return;end
    
    fprintf('cMDEWind:loadtrades:%s\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
    
    if isconnected, return;end
    
    obj.login;
    
end