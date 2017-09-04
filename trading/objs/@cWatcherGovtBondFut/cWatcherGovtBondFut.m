classdef cWatcherGovtBondFut < cWatcherFut
    properties

    end
    
    methods
        function obj = addsingle(obj,singlestr)
            %need sanity check for instruments
            %the single name string must start with either TF or T
            if isempty(strfind(upper(singlestr),'TF')) && ...
                    isempty(strfind(upper(singlestr),'T'))
%                 error('cWatcherGovtBondFut:addsingle:invalid single input')
                %here we might give a warning message instead
                warning(['cWatcherGovtBondFut:addsingle:',singlestr,' is not a govtbond fut!']);
                return
            end
            
            %call the base class method then after the sanity check
            addsingle@cWatcherFut(obj,singlestr);
            
        end
        %end of member function addsingle
        
        function obj = addpair(obj,pairstr)
            %need sanity check for instruments
            pairint = regexp(pairstr,',','split');
            for i = 1:length(pairint)
                if isempty(strfind(upper(pairint{i}),'TF')) && ...
                        isempty(strfind(upper(pairint{i}),'T'))
%                     error('cWatchGovtBondFut:addpair:invalid pair input')
                    %here we might give a warning message instead
                    warning(['cWatcherGovtBondFut:addpair:',pairstr,' is not valid!']);
                    return
                end
            end
            
            %call the base class method then after the sanity check
            addpair@cWatcherFut(obj,pairstr);
        end
        %end of member function addpair
        
        function obj = refresh(obj)
            data = obj.getquotes;
            ns = size(obj.singles,1);
            quotes = cell(ns,1);
            for i = 1:ns
                q = cQuoteGovtBondFut;
                q.update(obj.singles_ctp{i},data(i,1),data(i,2),data(i,3),...
                    data(i,4),data(i,5),data(i,6),data(i,7));
                quotes{i} = q;
            end
            obj.qs = quotes;
            obj.quotessingle2pair;
            
        end
        
    end
    
    
    methods (Access = private)
        %private function to get pair quotes from single quotes
        function quotes_pair = quotessingle2pair(obj)
            %note:for the govtbond pair, we trade the spread bettween the
            %implied yield rather then the price
            if isempty(obj.qs)
                obj.qp = {};
                quotes_pair = {};
                return
            end
            np = size(obj.pairs,1);
            
            if np > 0
                quotes_pair = cell(np,1);
                for i = 1:np
                    q = cQuoteFut;
                    code = obj.pairs{i};
                    legs = regexp(code,',','split');
                    [~,idx1] = obj.hassingle(legs{1});
                    [~,idx2] = obj.hassingle(legs{2});
                    
                    update_date = obj.qs{idx1}.update_date1;
                    %we choose the latest update time as of the update of
                    %the pair
                    update_time = max(obj.qs{idx1}.update_time1,obj.qs{idx2}.update_time1);
                    %we always take the difference of the first leg and the
                    %seond leg as of the last trade of the pair
                    last_trade = obj.qs{idx1}.yield_last_trade-obj.qs{idx2}.yield_last_trade;
                    %quote in bps
                    last_trade = round(last_trade*100,1);
                    %bid price is the price which to sell the pair, i.e.
                    %sell the first leg and buy the second leg.
                    bid = obj.qs{idx1}.yield_bid1 - obj.qs{idx2}.yield_ask1;
                    %quote in bps
                    bid = round(bid*100,1);
                    %ask price is the price which to buy the pair, i.e.buy
                    %the first leg and sell the seond leg
                    %quote in bps
                    ask = obj.qs{idx1}.yield_ask1 - obj.qs{idx2}.yield_bid1;
                    ask = round(ask*100,1);
                    q.update(code,update_date,update_time,last_trade,...
                        bid,ask,NaN,NaN);
                    quotes_pair{i} = q;
                end
                obj.qp = quotes_pair;    
            end
        end
        %end of quotessingle2pair
    end
    
    
end