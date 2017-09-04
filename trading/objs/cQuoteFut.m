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
    end
    
    methods
        function obj = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_)
            codestr = regexp(codestr,',','split');
            nleg = length(codestr);
            code_ctp_ = cell(nleg,1);
            code_wind_ = cell(nleg,1);
            code_bbg_ = cell(nleg,1);
            
            for i = 1:nleg
                code_ctp_{i} = str2ctp(codestr{i});
                code_wind_{i} = ctp2wind(code_ctp_{i});
                code_bbg_{i} = ctp2bbg(code_ctp_{i});
            end
            
            if nleg == 1
                obj.code_ctp = code_ctp_{1};
                obj.code_wind = code_wind_{1};
                obj.code_bbg = code_bbg_{1};
            elseif nleg == 2
                obj.code_ctp = [code_ctp_{1},',',code_ctp_{2}];
                obj.code_wind = [code_wind_{1},',',code_wind_{2}];
                obj.code_bbg = [code_bbg_{1},',',code_bbg_{2}];
            else
                error('to be implemented')    
            end
            
            if isnumeric(date_)
                obj.update_date1 = date_;
                obj.update_date2 = datestr(date_,'yyyymmdd');
            else
                obj.update_date1 = datenum(date_);
                obj.update_date2 = datestr(date_,'yyyymmdd');
            end
            
            if iscell(time_), time_ = time_{1};end
            
            if ischar(time_)
                %note:a bit hard-coded here
                dstr = [obj.update_date2,' ',time_];
                obj.update_time2 = dstr; 
                obj.update_time1 = datenum(dstr,'yyyymmdd HH:MM:SS'); 
            elseif isnumeric(time_)
                obj.update_time1 = time_;
                obj.update_time2 = datestr(time_,'yyyymmdd HH:MM:SS');
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
   
    
        function print(obj)
            fprintf('%s code:%s;trade:%s;bid:%s;ask:%s\n',obj.update_time2,obj.code_ctp,...
                num2str(obj.last_trade),...
                num2str(obj.bid1),...
                num2str(obj.ask1));
        end
        
    end
end