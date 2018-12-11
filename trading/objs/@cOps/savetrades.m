function [] = savetrades(obj,varargin)
    if ~obj.fileioflag_, return; end
    
    %note:trades are saved between 15:15pm and 15:25pm on each trading date
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    t = p.Results.Time;
    
    try
        ntrades = obj.trades_.latest_;
    catch
        ntrades = 0;
    end
    
    if ntrades == 0
    else
        dir_ = obj.savedir_;
        if isempty(dir_), dir_ = 'C:\yangyiran\ops\save\';end
        try
            cd(dir_);
        catch
            mkdir(dir_);
        end
        bookname_ = obj.book_.bookname_;
        dir_data_ = [dir_,bookname_,'\'];
        try
            cd(dir_data_)
        catch
            mkdir(dir_data_);
        end
        fn_ = [dir_data_,bookname_,'_trades_',datestr(t,'yyyymmdd'),'.txt'];
        obj.trades_.totxt(fn_);
        fprintf('cOps:savetrades on %s......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
        obj.entrusts_ = EntrustArray;
        obj.condentrustspending_ = EntrustArray;
        obj.entrustspending_ = EntrustArray;
        obj.entrustsfinished_ = EntrustArray;
        obj.trades_ = cTradeOpenArray;
        obj.book_.emptybook;
    end
    %
    %
    if strcmpi(obj.mode_,'replay'), return; end
    counter = obj.getcounter;
    if counter.is_Counter_Login
        counter.logout;
        fprintf('cOps:log off %s on %s......\n',counter.char,datestr(t,'yyyy-mm-dd HH:MM:SS'));
    end
    
end