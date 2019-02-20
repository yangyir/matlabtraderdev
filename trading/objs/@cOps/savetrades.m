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
    
    %note 20190220
    %bug fix:we shall save any pending conditional entrust
    try
        npending = obj.condentrustspending_.latest;
    catch
        npending = 0;
    end
    
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
    
    if npending > 0
        eval('condentrustspending = obj.condentrustspending_;');
        fn_ = [dir_data_,bookname_,'_condentrustspending_',datestr(t,'yyyymmdd')];
        save(fn_,'condentrustspending');
    end
    
    if ntrades > 0
        fn_ = [dir_data_,bookname_,'_trades_',datestr(t,'yyyymmdd'),'.txt'];
%         obj.trades_.totxt(fn_);
        %note 20190218
        %from 20190218 onwards, we will save/load trades in the new format
        obj.trades_.totxt2(fn_);
        fprintf('cOps:savetrades on %s......\n',datestr(t,'yyyy-mm-dd HH:MM:SS'));
    end
    %
    obj.entrusts_ = EntrustArray;
    obj.condentrustspending_ = EntrustArray;
    obj.entrustspending_ = EntrustArray;
    obj.entrustsfinished_ = EntrustArray;
    obj.trades_ = cTradeOpenArray;
    obj.book_.emptybook;
    %
    %
    if strcmpi(obj.mode_,'replay'), return; end
    counter = obj.getcounter;
    if counter.is_Counter_Login
        counter.logout;
        fprintf('cOps:log off %s on %s......\n',counter.char,datestr(t,'yyyy-mm-dd HH:MM:SS'));
    end
    
end