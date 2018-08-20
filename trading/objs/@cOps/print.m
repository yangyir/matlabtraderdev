function [] = print(obj,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    time = p.Results.Time;
    
    printtimeinterval = obj.print_timeinterval_;
    
    secondsperday = 86400;
    secondsbuckets = 0:printtimeinterval:secondsperday;
    
    thissecond = 3600*hour(time)+60*minute(time)+second(time);
    
    idx = secondsbuckets(1:end-1) < thissecond & secondsbuckets(2:end) >= thissecond;
    
    thiscount = find(secondsbuckets == secondsbuckets(idx));
    
    if thiscount == obj.getprintbucket, return; end
    
    if strcmpi(obj.status_,'sleep')
        fprintf('%s:ops sleeps......\n',datestr(time,'yyyy-mm-dd HH:MM:SS'));
    elseif strcmpi(obj.status_,'working')
        obj.printrunningpnl('mdefut',obj.mdefut_);
        obj.printpendingentrusts;
    end
    
    obj.setprintbucket(thiscount);
end