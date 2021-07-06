function [] = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_)
%cQuoteStock
    if ~obj.init_flag
        obj.init(codestr);
    end

    if isnumeric(date_)
        obj.update_date1 = date_;
        obj.update_date2 = datestr(date_,'yyyy-mm-dd');
    else
        obj.update_date1 = datenum(date_);
        obj.update_date2 = datestr(date_,'yyyy-mm-dd');
    end

    if iscell(time_), time_ = time_{1};end

    if ischar(time_)
        %note:a bit hard-coded here
        dstr = [obj.update_date2,' ',time_];
        obj.update_time2 = dstr; 
        obj.update_time1 = datenum(dstr,'yyyy-mm-dd HH:MM:SS'); 
    elseif isnumeric(time_)
        obj.update_time1 = time_;
        obj.update_time2 = datestr(time_,'yyyy-mm-dd HH:MM:SS');
    else
        obj.update_time1 = NaN;
        obj.update_time2 = '';
    end

    obj.last_trade = trade_;
    obj.bid1 = bid_;
    obj.ask1 = ask_;
    obj.bid_size1 = bidsize_;
    obj.ask_size1 = asksize_;

end