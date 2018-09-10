function [] = loadtrades(obj,varargin)
    if ~obj.fileioflag_, return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.addParameter('FileName','',@ischar);
    p.addParameter('CounterName','',@ischar);
    p.addParameter('BookName','',@ischar);
    p.addParameter('Override',false,@islogical);
    p.parse(varargin{:});
    t = p.Results.Time;
    filename = p.Results.FileName;
    countername = p.Results.CounterName;
    bookname = p.Results.BookName;
    overrideflag = p.Results.Override;
    
    if ~overrideflag
        try
            ntrades = obj.trades_.latest_;
        catch
            ntrades = 0;
        end
        if ntrades > 0, return; end
    end
    
    if isempty(countername)
        try
            countername = obj.book_.counter_.char;
        catch
            countername = '';
        end
    end
    
    if isempty(bookname)
        try
            bookname = obj.book_.bookname_;
        catch
            bookname = '';
        end
    end
    
    
    if isempty(filename) && isempty(bookname)
        fprintf('cOps:loadtrades:filename missing!\n');
        return
    end
    
    if isempty(filename)
        dir_ = obj.loaddir_;
        if isempty(dir_), dir_ = 'C:\yangyiran\ops\save\';end
        dir_data_ = [dir_,bookname,'\'];
        lastbd = getlastbusinessdate(t);
        filename = [dir_data_,bookname,'_trades_',datestr(lastbd,'yyyymmdd'),'.txt'];
    end
    

    
    trades = cTradeOpenArray;
    trades.fromtxt(filename);
    trades.filterby('CounterName',countername,'BookName',bookname);
    positions = trades.convert2positions;
    
    newBook = cBook;
    if ~isempty(bookname), newBook.setbookname(bookname);end
    if ~isempty(countername), newBook.setcountername(countername);end
    
    newBook.positions_ = positions;
    obj.book_ = newBook;
    obj.entrusts_ = EntrustArray;
    obj.entrustspending_ = EntrustArray;
    obj.entrustsfinished_ = EntrustArray;
    obj.trades_ = trades;
   
    fprintf('cOps:loadtrades on %s......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
    
    
end