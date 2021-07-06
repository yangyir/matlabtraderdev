classdef cQuoteStock < handle
    properties
        code_ctp
        code_wind
        code_bbg
        update_date1   %last update date in number
        update_date2   %last update date in string
        update_time1   %last update time in number
        update_time2   %last update time in string
        last_trade  %last trade
        bid1   %bid_1
        ask1   %ask_1
        bid_size1  %bid_size_1
        ask_size1  %ask_size_1
        
        init_flag = false
        
    end
    
    methods
        obj = init(obj,codestr)
        obj = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_)
        print(obj)
        
    end
end