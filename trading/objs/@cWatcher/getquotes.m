function quotes = getquotes(watcher,timestr)
    if nargin < 1
        timestr = '';
    end
    
    if isempty(watcher)
        quotes = [];
        return
    end

    if strcmpi(watcher.conn,'wind')
        quotes = getquotes_wind(watcher);
    elseif strcmpi(watcher.conn,'bbg') || strcmpi(watcher.conn,'bloomberg')
        quotes = getquotes_bbg(watcher);
    elseif strcmpi(watcher.conn,'ctp')
        quotes = getquotes_ctp(watcher);
    elseif strcmpi(watcher.conn,'local')
        quotes = getquotes_local(watcher,timestr);
    else
        quotes = [];
    end 
end
%end of getquotes