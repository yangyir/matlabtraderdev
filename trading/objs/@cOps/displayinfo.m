function [ret] = displayinfo(obj,time,varargin)
%bydefault we use time interval as of 1 minute
p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('MinuteInterval',[],@isnumeric);
p.parse(varargin{:});
interval = p.Results.MinuteInterval;
if isempty(interval), interval = 1; end

minutesperday = 1440;
minutebuckets = 0:interval:minutesperday;

thisminute = 60*hour(time)+minute(time);

idx = minutebuckets(1:end-1) < thisminute & minutebuckets(2:end) >= thisminute;

thiscount = find(minutebuckets == minutebuckets(idx));

if thiscount ~= obj.minute_count_
    ret = 1;
    obj.minute_count_ = thiscount;
else
    ret = 0;
end


end