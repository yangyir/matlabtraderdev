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
    
    %note:as we try to load the trades either 1)between 08:50am and
    %09:00am or 2)between 20:50pm and 21:00pm. However, if we haven't
    %traded any instrument not traded in the evening, we shall by-pass the
    %the loadtrades process during the evening.
    iseveningrequired = obj.iseveningrequired;
    if ~iseveningrequired && hour(t) > 16
        return
    end
        
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
            countername = obj.book_.countername_;
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
    
    newBook = cBook;
    if ~isempty(bookname), newBook.setbookname(bookname);end
    if ~isempty(countername), newBook.setcountername(countername);end
    
    try
        trades = cTradeOpenArray;
        trades.fromtxt(filename);
        livetrades = trades.filterby('CounterName',countername,'BookName',bookname,'Status','live');
        positions = livetrades.convert2positions;
        if ~isempty(positions), newBook.setpositions(positions);end

        obj.trades_ = livetrades;
        fprintf('cOps:loadtrades on %s......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
    catch
        %in case the filename doens't exist    
    end
    obj.book_ = newBook;
    obj.entrusts_ = EntrustArray;
    obj.entrustspending_ = EntrustArray;
    obj.entrustsfinished_ = EntrustArray;
    obj.condentrustspending_ = EntrustArray;
    %
    if strcmpi(obj.mode_,'replay'), return; end
    %
    counter = obj.getcounter;
    if ~counter.is_Counter_Login
        counter.login;
        fprintf('cOps:login to % on %s......\n',counter.char,datestr(t,'yyyy-mm-dd HH:MM:SS'));
    end
    
    
    
end