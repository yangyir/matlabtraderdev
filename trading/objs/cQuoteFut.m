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
        function obj = init(obj,codestr)
            if obj.init_flag && strcmpi(obj.code_ctp,codestr)
                return
            end
            
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
            obj.init_flag = true;
            
        end
        
        
        function obj = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_)
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
            
            if strcmpi(obj.code_bbg(1:3),'TFT') && isempty(strfind(obj.code_bbg,','))
                obj.bond_flag = true;
                obj.bond_tenor = '10y';
            elseif strcmpi(obj.code_bbg(1:3),'TFC') && isempty(strfind(obj.code_bbg,','))
                obj.bond_flag = true;
                obj.bond_tenor = '5y';
            end
            
            if obj.bond_flag
                warning('off','finance:bndyield:solutionConvergenceFailure');
                ylds = bndyield([obj.last_trade,obj.bid1,obj.ask1],0.03,...
                    obj.update_date1,dateadd(obj.update_date1,obj.bond_tenor));
                obj.yield_last_trade = ylds(1)*1e2;
                obj.yield_bid1 = ylds(2)*1e2;
                obj.yield_ask1 = ylds(3)*1e2;
                
                obj.duration = bnddurp(obj.last_trade,0.03,obj.update_date1,...
                    dateadd(obj.update_date1,obj.bond_tenor));
            end
            
        end
   
    
        function print(obj)
            if ~obj.bond_flag
                fprintf('%s trade:%s;bid:%s;ask:%s;instrument:%s;\n',obj.update_time2,...
                    num2str(obj.last_trade),...
                    num2str(obj.bid1),...
                    num2str(obj.ask1),...
                    obj.code_ctp);
            else
                fprintf('%s trade:%4.3f;bid:%4.3f;ask:%4.3f;yield:%4.2f;duration:%2.1f;instrument:%s;\n',obj.update_time2,...
                    obj.last_trade,...
                    obj.bid1,...
                    obj.ask1,...
                    obj.yield_last_trade,...
                    obj.duration,...
                    obj.code_ctp);
            end
        end
        
    end
end