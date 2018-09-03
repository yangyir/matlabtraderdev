function [] = loadtradesfromexcel(obj,fn,sheetn)
    obj.positions_ = {};
    trades = cTradeOpenArray;
    trades.fromexcel(fn,sheetn);
    if ~isempty(obj.bookname_), usebookname = true; else usebookname = false;end
    if ~isempty(obj.counter_), usecounter = true; else usecounter = false;end
    
    if usebookname && usecounter
        livetrades = trades.filterby('CounterName',obj.counter_.char,'BookName',obj.bookname_,'Status','set');
    elseif usebookname && ~usecounter
        livetrades = trades.filterby('BookName',obj.bookname_,'Status','set');
    elseif ~usebookname && usecounter
        livetrades = trades.filterby('CounterName',obj.counter_.char,'Status','set');
    elseif ~usebookname && ~usecounter
        livetrades = trades.filterby('Status','set');
    end
    
    positions = livetrades.convert2positions;
    if livetrades.count > 0, obj.positions_ = positions;end
    
    if isempty(obj.bookname_) && livetrades.count > 0
        obj.bookname_ = livetrades.node_(1).bookname_;
    end
    
    if isempty(obj.counter_) && livetrades.count > 0
        obj.counter_ = CounterCTP.(livetrades.node_(1).countername_);
    end
end