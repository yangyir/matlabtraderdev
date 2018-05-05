function tick = gettickdata(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('time',{},...
        @(x) validateattributes(x,{'char','numeric'},{},'','time'));
    p.parse(varargin{:});
    codestr = p.Results.code;
    if isempty(codestr), tick = [];return;end
    timeinput = p.Results.time;
    if ischar(timeinput)
        timenum = datenum(timeinput);
    else
        timenum = timeinput;
    end
    
    [flag,idx] = obj.instruments_.hasinstrument(codestr);
    if ~flag,tick = [];return;end
    ticks = obj.tickdata_{idx};
    secondsperday = 86400;
    i = ticks(:,1) > timenum-1/secondsperday &...
        ticks(:,1) < timenum+1/secondsperday;
    temp = ticks(i,:);
    if isempty(temp)
        tick = [];
    else
        tick = zeros(size(temp));
        count = 0;
        for i = 1:size(temp,1)
            if strcmpi(datestr(temp(i,1)),datestr(timenum))
                count = count + 1;
                tick(count,:) = temp(i,:);
            end
        end
        tick = tick(1:count,:);
    end
    
    
end