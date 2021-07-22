function [] = refresh(obj, varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.Time;
    
    fprintf('cWind:refresh:%s\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
    
    obj.saveticks2mem;
    %
    obj.updatecandleinmem
end