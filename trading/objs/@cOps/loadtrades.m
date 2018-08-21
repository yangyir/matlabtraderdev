function [] = loadtrades(obj,varargin)
    if ~obj.fileioflag_, return; end
    
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.addParameter('BookName','',@ischar);
    p.addParameter('FileName','',@ischar);
    p.parse(varargin{:});
    t = p.Results.Time;
    bookname = p.Results.BookName;
    filename = p.Results.FileName;
    if isempty(bookname)
        try
            bookname = obj.book_.bookname_;
        catch
            bookname = '';
        end
    end
    
    if isempty(bookname) && isempty(filename), return; end
    
    if ~isempty(filename)
        trades = cTradeOpenArray;
        trades.fromtxt(filename);
        if ~isempty(bookname)
            trades.filterby('BookName',bookname);
        end
        
        positions = trades.convert2positions;
        book = cBook;
        book.bookname_ = bookname;
        book.positions_ = positions;
        obj.book_ = book;
        fprintf('ops:loadtrades on %s......\n',datestr(dtnum,'yyyy-mm-dd HH:MM:SS'));
    end
    
    
    dir_ = obj.loaddir_;
    if isempty(dir_), dir_ = 'C:\yangyiran\ops\load\';end
    try
        cd(dir_);
    catch
        mkdir(dir_);
    end
    
    dir_data_ = [dir_,bookname_,'\'];
    try
        cd(dir_data_)
    catch
        mkdir(dir_data_);
    end
    
    %not finished yet!!!!
    
    
end