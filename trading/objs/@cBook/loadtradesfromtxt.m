function [] = loadtradesfromtxt(obj,fn)
    ret  = obj.checktradesfile(fn);
    if ~ret, return;end
    
    obj.positions_ = {};
    trades = cTradeOpenArray;
    trades.fromtxt(fn);
    if ~isempty(obj.bookname_), usebookname = true; else usebookname = false;end
    if ~isempty(obj.countername_), usecountername = true; else usecountername = false;end
    
    if usebookname && usecountername
        livetrades = trades.filterby('CounterName',obj.countername_,'BookName');
    elseif usebookname && ~usecountername
        livetrades = trades.filterby('BookName',obj.bookname_);
    elseif ~usebookname && usecountername
        livetrades = trades.filterby('CounterName',obj.countername_);
    elseif ~usebookname && ~usecountername
        livetrades = trades;
    end
    
    positions = livetrades.convert2positions;
    if livetrades.count > 0, obj.positions_ = positions;end
    
    if isempty(obj.bookname_) && livetrades.count > 0
        obj.bookname_ = livetrades.node_(1).bookname_;
    end
    
    if isempty(obj.countername_) && livetrades.count > 0
        obj.countername_ = livetrades.node_(1).countername_;
    end

end