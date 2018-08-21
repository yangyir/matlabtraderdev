function [] = loadmktdata(obj,varargin)
    if ~obj.fileioflag_, return; end
    %note:the mktdata is scheduled to be loaded between 08:50am and 09:00am
    %on each trading date
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    dtnum = p.Results.Time;
    
    if ~isempty(obj.candles4save_)
    else
        instruments = obj.qms_.instruments_.getinstrument;
        ns = size(instruments,1);
        if ns == 0, return; end
        fprintf('mdefut:loadmktdata on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
        obj.move2cobdate(floor(dtnum));
    end
    
end