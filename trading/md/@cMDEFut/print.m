function [] = print(obj,varargin)
    
    if ~obj.printflag_, return; end
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    time = p.Results.Time;
      
    if strcmpi(obj.status_,'sleep')
        fprintf('%s:mdefut sleeps......\n',datestr(time,'yyyy-mm-dd HH:MM:SS'));
    elseif strcmpi(obj.status_,'working')
        obj.printmarket;
    end
    
end