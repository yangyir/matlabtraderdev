classdef cWatcher < handle
    %watcher class to monitor the futures.options traded in exchange in
    %China
    properties
        singles@cell    %single underliers to watch
        types@cell      %single underlier types, i.e. futures,option and etc
        pairs@cell      %pairs underliers to watch (long/short pair)
        structs@cell    %structs underliers to watch (more than 2 underliers)
        
        conn@char       %data source connection, i.e. bloomberg,wind or CTP
        ds@cDataSource
        %
        qs@cell         %quotes of single
        qp@cell         %quotes of pair
        qt@cell         %quotes of structs
        %
        ws@cell         %weights of structs
        
        underliers@cell %option underliers
        
        calcgreeks@logical = true
        
    end
    
    properties (Hidden = true)
        singles_w@cell
        singles_b@cell
        singles_ctp@cell
        %
        pairs_w@cell
        pairs_b@cell
        pairs_ctp@cell
        %
        structs_w@cell
        structs_b@cell
        structs_ctp@cell
        %
        underliers_w@cell
        underliers_b@cell
        underliers_ctp@cell
        
    end
    
    methods 
        function ds_ = get.ds(obj)
            if strcmpi(obj.conn,'wind')
                if ~isa(obj.ds,'cWind')
                    ds_ = cWind;
                    obj.ds = ds_;
                else
                    ds_ = obj.ds;
                end
            elseif strcmpi(obj.conn,'bloomberg')
                if ~isa(obj.ds,'cBloomberg')
                    ds_ = cBloomberg;
                    obj.ds = ds_;
                else
                    ds_ = obj.ds;
                end
            elseif strcmpi(obj.conn,'ctp')
                if ~isa(obj.ds,'cCTP')
                    ds_ = cCTP.citic_kim_fut;
                    if ~ds_.isconnect
                        ds_.login;
                    end
                    obj.ds = ds_;
                else
                    ds_ = obj.ds;
                end
            elseif strcmpi(obj.conn,'local')
                if ~isa(obj.ds,'cLocal')
                    ds_ = cLocal;
                    obj.ds = ds_;
                else
                    if isempty(obj.ds.ds_)
                        obj.ds.ds_ = getenv('DATAPATH');
                    end
                    ds_ = obj.ds;
                end
            else
                ds_ = {};
            end
        end
        %end of get.ds
               
    end
    
    methods
        [] = addsingle(obj,singlestr)
        [] = addsingles(obj,singlearray)
        n = countsingles(obj)
        %
        [] = addpair(obj,pairstr)
        [] = addpairs(obj,pairarray)
        n = countpairs(obj)
        %
        [] = addstruct(obj,structstr,weights)
        [] = addstructs(obj,structarray)
        n = countstructs(obj)
        %
        [] = removesingle(obj,singlestr)
        [] = removepair(obj,pairstr,keepsingle)
        [] = removestruct(obj,structstr,keepsingle)
        [] = removeall(obj)
        [] = removesingles(obj,singlearray)
        [] = removepairs(obj,pairarray)
        [] = removestructs(obj,structarray)
        %
        [flag,idx] = hassingle(obj,singlestr)
        [flag,idx] = haspair(obj,pairstr)
        [flag,idx] = hasstruct(obj,structstr)
        %
        [] = refresh(obj,timestr)
        quotes = getquotes(obj,timestr)
        quote = getquote(obj,codestr)
        %
        [] = close(obj)
        flag = isconnect(obj)
        [] = printquotes(obj)
        
    end
    
    methods (Access = private)
        % private function to init quotes
        function obj = init_quotes(obj)
            nq = size(obj.qs,1);
            ns = obj.countsingles;
            if nq ~= ns
                nu = obj.countunderliers;
                obj.qs = cell(ns+nu,1);
                %here we only initiate the quotes for option legs but not
                %the underlier
                for i = 1:ns
                    if strcmpi(obj.types{i},'option')
                        q = cQuoteOpt;
                        q.init(obj.singles{i});
                        %set interest rate level once a day
                        %note:this now only works with Bloomberg
                        if isempty(q.riskless_rate)
                            if isa(obj.ds,'cBloomberg')
                                data = obj.ds.realtime('CCSWOC CMPN Curncy','px_last');
                                q.riskless_rate = data.px_last/100;
                            else
                                q.riskless_rate = 0.035;
                            end
                        end
                    else
                        q = cQuoteFut;
                        q.init(obj.singles{i});
                    end
                    obj.qs{i} = q;
                end
                
                for i = 1:nu
                    q = cQuoteFut;
                    q.init(obj.underliers{i});
                    obj.qs{ns+i} = q;
                end
            end
        end
        

        quotes = getquotes_wind(obj)
        quotes = getquotes_bbg(obj)
        quotes = getquotes_ctp(obj)
        quotes = getquotes_local(obj,timestr)
         
        
        
        %private function to get pair quotes from single quotes
        function quotes_pair = quotessingle2pair(obj)
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
                    last_trade = obj.qs{idx1}.last_trade-obj.qs{idx2}.last_trade;
                    %bid price is the price which to sell the pair, i.e.
                    %sell the first leg and buy the second leg.
                    bid = obj.qs{idx1}.bid1 - obj.qs{idx2}.ask1;
                    %ask price is the price which to buy the pair, i.e.buy
                    %the first leg and sell the seond leg
                    ask = obj.qs{idx1}.ask1 - obj.qs{idx2}.bid1;
                    q.update(code,update_date,update_time,last_trade,...
                        bid,ask,NaN,NaN);
                    quotes_pair{i} = q;
                end
                obj.qp = quotes_pair;    
            end
        end
        
        [] = addunderlier(obj,underlierstr)
        
        %private function to check whether underlier exist
        function [flag,idx] = hasunderlier(obj, underlierstr)
            if ~ischar(underlierstr)
                error('cWatcherOpt:hasunderlier:invalid underlier string input')
            end
            for i = 1:length(obj.underliers)
                if strcmpi(underlierstr,obj.underliers{i})
                    flag = true;
                    idx = i;
                    return
                end 
            end
            flag = false;
            idx = 0; 
        end
        
        %private function to count underliers
        function n = countunderliers(obj)
            n = length(obj.underliers);
        end
        
        %private function to remove underliers
        function obj = removeunderlier(obj,underlierstr)
            if ~ischar(underlierstr)
                error('cWatcherOpt:removeunderlier:invalid underlier string input')
            end
            [flag,idx] = obj.hasunderlier(underlierstr);
            if flag
                n = obj.countunderliers;
                if n == 1
                    obj.underliers = {};
                    obj.underliers_ctp = {};
                    obj.underliers_w = {};
                    obj.underliers_b = {};
                else
                    u = cell(n-1,1);
                    u_ctp = cell(n-1,1);
                    u_w = cell(n-1,1);
                    u_b = cell(n-1,1);
                    count = 1;
                    for i = 1:n
                        if i == idx
                            continue;
                        else
                            u{count} = obj.underliers{i};
                            u_ctp{count} = obj.underliers_ctp{i};
                            u_w{count} = obj.underliers_w{i};
                            u_b{count} = obj.underliers_b{i};
                            count = count + 1;
                        end
                    end
                    obj.underliers = u;
                    obj.underliers_ctp = u_ctp;
                    obj.underliers_w = u_w;
                    obj.underliers_b = u_b;
                end
            else
                warning(['cWatcher:removeunderlier:underlier ',underlierstr,' not found']);
            end
        end
        
    end
    
end