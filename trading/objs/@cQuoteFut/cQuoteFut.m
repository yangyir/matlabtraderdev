classdef cQuoteFut < handle
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
        
        %properties relates to govtbond futures
        bond_flag = false
        yield_last_trade@double
        yield_bid1@double
        yield_ask1@double
        duration@double
        bond_tenor@char
        
    end
    
    methods
        obj = init(obj,codestr)
        obj = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_)
        print(obj)
        
    end
end