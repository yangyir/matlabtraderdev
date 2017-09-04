classdef cQuoteGovtBondFut < cQuoteFut
    properties
        yield_last_trade@double
        yield_bid1@double
        yield_ask1@double
        %
        duration_last_trade@double
        duration_bid1@double
        duration_ask1@double
        %
        tenor@char
    end
    
    methods
        function obj = update(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_)
            update@cQuoteFut(obj,codestr,date_,time_,trade_,bid_,ask_,bidsize_,asksize_);
            %calculate yields
            if strcmpi(obj.code_bbg(1:3),'TFT') && isempty(strfind(obj.code_bbg,','))
                obj.tenor = '10y';
            elseif strcmpi(obj.code_bbg(1:3),'TFC') && isempty(strfind(obj.code_bbg,','))
                obj.tenor = '5y';
            end
            %
            ylds = bndyield([obj.last_trade,obj.bid1,obj.ask1],0.03,...
                obj.update_date1,dateadd(obj.update_date1,obj.tenor));
            obj.yield_last_trade = ylds(1)*1e2;
            obj.yield_bid1 = ylds(2)*1e2;
            obj.yield_ask1 = ylds(3)*1e2;
            %
            mds = bnddurp([obj.last_trade,obj.bid1,obj.ask1],0.03,...
                obj.update_date1,dateadd(obj.update_date1,obj.tenor));
            obj.duration_last_trade = mds(1);
            obj.duration_bid1 = mds(2);
            obj.duration_ask1 = mds(3);
            
        end
        %end of 'update'
        
        function print(obj)
            if strcmpi(obj.code_ctp(1:2),'TF')
                printmsg = '%s code:%s;trade:%4.3f;bid:%4.3f;ask:%4.3f;yield:%4.3f;duration:%4.2f\n';
            else
                printmsg = '%s code: %s;trade:%4.3f;bid:%4.3f;ask:%4.3f;yield:%4.3f;duration:%4.2f\n';
            end
                        
            fprintf(printmsg,...
                obj.update_time2,obj.code_ctp,...
                obj.last_trade,...
                obj.bid1,...
                obj.ask1,...
                obj.yield_last_trade,...
                obj.duration_last_trade);
        end
        
    end
    
end