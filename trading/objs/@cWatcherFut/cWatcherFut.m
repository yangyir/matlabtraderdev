classdef cWatcherFut < handle
    %base watcher class to watch the market data of specified instruments
    properties
        singles@cell    %single underliers to watch
        pairs@cell      %pairs underliers to watch (long/short pair)
        structs@cell    %structs underliers to watch (more than 2 underliers)
        
        conn@char       %data source connection, i.e. bloomberg,wind or CTP
        c
        %
        qs@cell         %quotes of single
        qp@cell         %quotes of pair
        qt@cell         %quotes of structs
        %
        ws@cell              %weights of structs
        
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
        
    end
    
    methods 
        function con = get.c(obj)
            if strcmpi(obj.conn,'wind')
                if ~isa(obj.c,'windmatlab')
                    con = windmatlab;
                    obj.c = con;
                else
                    con = obj.c;
                end
            elseif strcmpi(obj.conn,'bbg') || strcmpi(obj.conn,'bloomberg')
                if ~isa(obj.c,'blp')
                    con = bbgconnect;
                    obj.c = con;
                else
                    con = obj.c;
                end
            elseif strcmpi(obj.conn,'ctp')
                %t0do
            else
                con = {};
            end
        end
               
    end
    
    methods
        function obj = addsingle(obj,singlestr)
            if ~ischar(singlestr)
                error('cWatcher:addsingle:invalid single string input')
            end
            if ~obj.hassingle(singlestr)
                n = length(obj.singles);
                n = n + 1;
                s = cell(n,1);
                s_w = cell(n,1);
                s_b = cell(n,1);
                s_ctp = cell(n,1);
                s{n} = singlestr;
                s_ctp{n} = str2ctp(singlestr);
                s_w{n} = ctp2wind(s_ctp{n});
                s_b{n} = ctp2bbg(s_ctp{n});
                if n > 1
                    for i = 1:n-1
                        s{i} = obj.singles{i};
                        s_ctp{i} = obj.singles_ctp{i};
                        s_w{i} = obj.singles_w{i};
                        s_b{i} = obj.singles_b{i};
                    end
                end
                obj.singles = s;
                obj.singles_ctp = s_ctp;
                obj.singles_w = s_w;
                obj.singles_b = s_b;
            end
        end
        %end of addsingle
        
        function obj = addsingles(obj,singlearray)
            if iscell(singlearray)
                for i = 1:length(singlearray)
                    obj = addsingle(obj,singlearray{i});
                end
            elseif ischar(singlearray)
                singlearray = regexp(singlearray,',','split');
                for i = 1:length(singlearray)
                    obj = addsingle(obj,singlearray{i});
                end
            end
        end
        %end of addsingles
        
        function n = countsingles(obj)
            n = length(obj.singles);
        end
        %end of countsingles
        
        function obj = addpair(obj,pairstr)
            if ~ischar(pairstr)
                error('cWatcher:addpairs:invalid pair string input')
            end
            if ~obj.haspair(pairstr)
                legs = regexp(pairstr,',','split');
                if length(legs) ~= 2
                    error('cWatcher:addpair:invalid pairstr input')
                end
                
                %we add the legs to singles container
                obj.addsingle(legs{1});
                obj.addsingle(legs{2});
                
                n = length(obj.pairs);
                n = n + 1;
                p = cell(n,1);
                p_ctp = cell(n,2);
                p_w = cell(n,2);
                p_b = cell(n,2);
                p{n} = pairstr;
                                
                p_ctp{n,1} = str2ctp(legs{1});
                p_ctp{n,2} = str2ctp(legs{2});
                p_w{n,1} = ctp2wind(p_ctp{n,1});
                p_w{n,2} = ctp2wind(p_ctp{n,2});
                p_b{n,1} = ctp2bbg(p_ctp{n,1});
                p_b{n,2} = ctp2bbg(p_ctp{n,2});
                                
                if n > 1
                    for i = 1:n-1
                        p{i} = obj.pairs{i};
                        p_ctp{i,1} = obj.pairs_ctp{i,1};
                        p_ctp{i,2} = obj.pairs_ctp{i,2};
                        p_w{i,1} = obj.pairs_w{i,1};
                        p_w{i,2} = obj.pairs_w{i,2};
                        p_b{i,1} = obj.pairs_b{i,1};
                        p_b{i,2} = obj.pairs_b{i,2};
                    end
                end
                obj.pairs = p;
                obj.pairs_ctp = p_ctp;
                obj.pairs_w = p_w;
                obj.pairs_b = p_b;
            end
        end
        %end of addpairs
        
        function obj = addpairs(obj,pairarray)
            if ischar(pairarray)
                pairarray = regexp(pairarray,';','split');
            end
            for i = 1:length(pairarray)
                obj = addpair(obj,pairarray{i});
            end
        end
        %end of addpairs
        
        function n = countpairs(obj)
            n = length(obj.pairs);
        end
        %end of countpairs
        
        function obj = addstruct(obj,structstr,weights)
            if ~ischar(structstr)
                error('cWatcher:addstruct:invalid strcut string input')
            end
            if ~obj.hasstruct(structstr)
                legs = regexp(structstr,',','split');
                
                %we add the legs to singles container
                for i = 1:length(legs), obj.addsingle(legs{i}); end
                
                n = length(obj.structs);
                n = n + 1;
                ss = cell(n,1);
                ss_ctp = cell(n,1);
                ss_w = cell(n,1);
                ss_b = cell(n,1);
                ss{n} = structstr;
                %weights
                ws_ = cell(n,1);
                
                ss_ctp_new = cell(1,length(legs));
                ss_w_new = ss_ctp_new;
                ss_b_new = ss_ctp_new;
                
                for i = 1:length(legs)
                    ss_ctp_new{i} = str2ctp(legs{i});
                    ss_w_new{i} = ctp2wind(ss_ctp_new{i});
                    ss_b_new{i} = ctp2bbg(ss_ctp_new{i});
                end
                
                ss_ctp{n,1} = ss_ctp_new;
                ss_w{n,1} = ss_w_new;
                ss_b{n,1} = ss_b_new;
                ws_{n} = weights;
                                
                if n > 1
                    for i = 1:n-1
                        ss{i} = obj.structs{i};
                        ss_ctp{i} = obj.structs_ctp{i};
                        ss_w{i,1} = obj.structs_w{i};
                        ss_b{i} = obj.structs_b{i};
                        ws_{i} = obj.ws{i};
                    end
                end
                obj.structs = ss;
                obj.structs_ctp = ss_ctp;
                obj.structs_w = ss_w;
                obj.structs_b = ss_b;
                obj.ws = ws_;
            end
        end
        %end of addstruct
        
        function obj = addstructs(obj,structarray)
            if ischar(structarray)
                structarray = regexp(structarray,';','split');
            end
            for i = 1:length(structarray)
                obj = addstruct(obj,structarray{i});
            end
        end
        %end of addstructs
        
        function n = countstructs(obj)
            n = length(obj.structs);
        end
        %end of countstructs
        
        function obj = removesingle(obj,singlestr)
            if ~ischar(singlestr)
                error('cWatcher:removesingle:invalid single string input')
            end
            [flag,idx] = obj.hassingle(singlestr);
            if flag
                n = length(obj.singles);
                if n == 1
                    obj.singles = {};
                    obj.singles_ctp = {};
                    obj.singles_w = {};
                    obj.singles_b = {};
                else
                    s = cell(n-1,1);
                    s_ctp = cell(n-1,1);
                    s_w = cell(n-1,1);
                    s_b = cell(n-1,1);
                    count = 1;
                    for i = 1:n
                        if i == idx
                            continue;
                        else
                            s{count} = obj.singles{i};
                            s_ctp{count} = obj.singles_ctp{i};
                            s_w{count} = obj.singles_w{i};
                            s_b{count} = obj.singles_b{i};
                            count = count + 1;
                        end
                    end
                    obj.singles = s;
                    obj.singles_ctp = s_ctp;
                    obj.singles_w = s_w;
                    obj.singles_b = s_b;
                end
            else
                warning(['cWatcher:removesingle:single ',singlestr,' not found']);
            end
        end
        %end of removesingle
        
        function obj = removepair(obj,pairstr,keepsingle)
            if nargin < 3
                keepsingle = false;
            end
            
            if ~ischar(pairstr)
                error('cWatcher:removepair:invalid pair string input')
            end
            [flag,idx] = obj.haspair(pairstr);
            if flag
                %here we also remove the pair legs from the singles
                %container
                if ~keepsingle
                    legs = regexp(pairstr,',','split');
                    if obj.hassingle(legs{1}), obj.removesingle(legs{1});end
                    if obj.hassingle(legs{2}), obj.removesingle(legs{2});end
                end
                n = length(obj.pairs);
                if n == 1
                    obj.pairs = {};
                    obj.pairs_ctp = {};
                    obj.pairs_w = {};
                    obj.pairs_b = {};
                else
                    p = cell(n-1,1);
                    p_ctp = cell(n-1,1);
                    p_w = cell(n-1,1);
                    p_b = cell(n-1,1);
                    count = 1;
                    for i = 1:n
                        if i == idx
                            continue;
                        else
                            p{count} = obj.pairs{i};
                            p_ctp{count,1} = obj.pairs_ctp{i,1};
                            p_ctp{count,2} = obj.pairs_ctp{i,2};
                            p_w{count,1} = obj.pairs_w{i,1};
                            p_w{count,2} = obj.pairs_w{i,2};
                            p_b{count,1} = obj.pairs_b{i,1};
                            p_b{count,2} = obj.pairs_b{i,2};
                            count = count + 1;
                        end
                    end
                    obj.pairs = p;
                    obj.pairs_ctp = p_ctp;
                    obj.pairs_w = p_w;
                    obj.pairs_b = p_b;
                end
            else
                warning(['cWatcher:removepair:pair ',pairstr,' not found']);
            end
        end
        %end of removepair
        
        function obj = removestruct(obj,structstr,keepsingle)
            if nargin < 3
                keepsingle = false;
            end
            
            if ~ischar(structstr)
                error('cWatcherFut:removestruct:invalid pair string input')
            end
            [flag,idx] = obj.hasstruct(structstr);
            if flag
                %here we also remove the pair legs from the singles
                %container
                if ~keepsingle
                    legs = regexp(structstr,',','split');
                    for i = 1:length(legs)
                        if obj.hassingle(legs{i}), obj.removesingle(legs{i});end
                    end
                end
                n = length(obj.structs);
                if n == 1
                    obj.structs = {};
                    obj.structs_ctp = {};
                    obj.structs_w = {};
                    obj.structs_b = {};
                else
                    ss = cell(n-1,1);
                    ss_ctp = cell(n-1,1);
                    ss_w = cell(n-1,1);
                    ss_b = cell(n-1,1);
                    ws_ = cell(n-1,1);
                    count = 1;
                    for i = 1:n
                        if i == idx
                            continue;
                        else
                            ss{count} = obj.structs{i};
                            ss_ctp{count} = obj.structs_ctp{i};
                            ss_w{count} = obj.structs_w{i};
                            ss_b{count} = obj.structs_b{i};
                            ws_{count} = obj.ws{i};
                            count = count + 1;
                        end
                    end
                    obj.structs = ss;
                    obj.structs_ctp = ss_ctp;
                    obj.structs_w = ss_w;
                    obj.structs_b = ss_b;
                    obj.ws = ws_;
                end
            else
                warning(['cWatcherFut:removestruct:struct ',structstr,' not found']);
            end
        end
        %end of removstruct
        
        function obj = removeall(obj)
            obj.removesingles;
            obj.removepairs;
            obj.removestructs;
        end
        %end of removeall
        
        function obj = removesingles(obj,singlearray)
            if nargin == 1
                obj.singles = {};
                obj.singles_ctp = {};
                obj.singles_w = {};
                obj.singles_b = {};
            else
                if ischar(singlearray)
                    singlearray = regexp(singlearray,',','split');
                end
                for i = 1:length(singlearray)
                    obj.removesingle(singlearray{i});
                end
            end
                    
        end
        %end of removesingles
        
        function obj = removepairs(obj,pairarray)
            if nargin == 1
                obj.pairs = {};
                obj.pairs_ctp = {};
                obj.pairs_w = {};
                obj.pairs_b = {};
            else
                if ischar(pairarray)
                    pairarray = regexp(pairarray,';','split');
                end
                for i = 1:length(pairarray)
                    obj = obj.removepair(pairarray{i});
                end
            end
        end
        %end of removepairs
        
        function obj = removestructs(obj,structarray)
            if nargin == 1
                obj.structs = {};
                obj.structs_ctp = {};
                obj.structs_w = {};
                obj.structs_b = {};
            else
                if ischar(structarray)
                    structarray = regexp(structarray,';','split');
                end
                for i = 1:length(structarray)
                    obj = obj.removestruct(structarray{i});
                end
            end
        end
        %end of removestructs
        
        function [flag,idx] = hassingle(obj,singlestr)
            if ~ischar(singlestr)
                error('cWatcher:hassingle:invalid single string input')
            end
            for i = 1:length(obj.singles)
                if strcmpi(singlestr,obj.singles{i})
                    flag = true;
                    idx = i;
                    return
                end
            end
            flag = false;
            idx = 0;
        end
        %end of hassingle
        
        function [flag,idx] = haspair(obj,pairstr)
            if ~ischar(pairstr)
                error('cWatcher:haspair:invalid pair string input')
            end
            for i = 1:length(obj.pairs)
                if strcmpi(pairstr,obj.pairs{i})
                    flag = true;
                    idx = i;
                    return
                end
            end
            flag = false;
            idx = 0;
        end
        %end of haspairs
        
        function [flag,idx] = hasstruct(obj,structstr)
            if ~ischar(structstr)
                error('cWatcher:hasstruct:invalid struct string input')
            end
            for i = 1:length(obj.structs)
                if strcmpi(structstr,obj.structs{i})
                    flag = true;
                    idx = i;
                    return
                end
            end
            flag = false;
            idx = 0;
        end
        %end of hasstruct
        
        function obj = refresh(obj)
            data = obj.getquotes;
            ns = size(obj.singles,1);
            quotes = cell(ns,1);
            for i = 1:ns
                q = cQuoteFut;
                q.update(obj.singles_ctp{i},data(i,1),data(i,2),data(i,3),...
                    data(i,4),data(i,5),data(i,6),data(i,7));
                quotes{i} = q;
            end
            obj.qs = quotes;
            obj.quotessingle2pair;
            
        end
        %end pf refresh
        
        function quotes = getquotes(obj)
            if strcmpi(obj.conn,'wind')
                quotes = getquotes_wind(obj);
            elseif strcmpi(obj.conn,'bbg') || strcmpi(obj.conn,'bloomberg')
                quotes = getquotes_bbg(obj);
            elseif strcmpi(obj.conn,'ctp')
                quotes = getquotes_ctp(obj);
            else
                quotes = [];
            end 
        end
        %end of getquotes
        
        function close(obj)
            try
                obj.c.close;
                obj.c = {};
            catch
                obj.c = {};
            end
            obj.conn = '';
            obj.removeall;
            obj.qs = {};
            obj.qp = {};
            obj.qt = {};
            obj.ws = {};
        end
        
    end
    
    methods (Access = private)
        % private function to get quotes from WIND datasource
        function quotes = getquotes_wind(obj)
            ns = size(obj.singles,1);
            
            list_ctp = cell(ns,1);
            for i = 1:ns
                list_ctp{i} = obj.singles_ctp{i};
            end
            
            if ns > 0
                list_wind = obj.singles_w{1};
            end
            
            for i = 2:ns
                temp = [list_wind,',',obj.singles_w{i}];
                list_wind = temp;
            end
            
            quotes = zeros(ns,7);
            
            data = obj.c.wsq(list_wind,'rt_date,rt_time,rt_latest,rt_bid1,rt_ask1,rt_bsize1,rt_asize1');
            %rt_date is in the format of yyyymmdd
            %rt_time is in the format of hhmmss
            for i = 1:ns
                tstr = num2str(data(i,2));
                if length(tstr) == 5
                    hhstr = ['0',tstr(1)];
                else
                    hhstr = tstr(1:2);
                end
                mmstr = tstr(end-3:end-2);
                ddstr = tstr(end-1:end);
                tstr = [hhstr,':',mmstr,':',ddstr];
                quotes(i,1) = datenum(num2str(data(i,1)),'yyyymmdd');
                quotes(i,2) = datenum([datestr(quotes(i,1)),' ',tstr]);
                quotes(i,3:end) = data(i,3:end);
            end
            
        end
        
        %private function to get quotes from BLOOMBERG datasource
        function quotes = getquotes_bbg(obj)
            ns = size(obj.singles,1);
            list_ctp = cell(ns,1);
            list_bbg = cell(ns,1);
            for i = 1:ns
                list_ctp{i} = obj.singles_ctp{i};
                list_bbg{i} = obj.singles_b{i};
            end

            quotes = zeros(ns,7);
            
            data = getdata(obj.c,list_bbg,{'last_update_dt','time','last_trade','bid','ask','bid_size','ask_size'});
            for i = 1:ns
                quotes(i,1) = data.last_update_dt(i);     %date
                %time field may not pop-up as HH:MM:SS but as mm/dd/yyyy
                try
                    quotes(i,2) = datenum([datestr(quotes(i,1)),' ',data.time{i}]);
                catch
                    if isempty(strfind(data.time{i},':'))
                        quotes(i,2) = datenum([datestr(quotes(i,1)),' 15:15:00']);
                    else
                        quotes(i,2) = NaN;
                    end
                end
                
                quotes(i,3) = data.last_trade(i);
                quotes(i,4) = data.bid(i);
                quotes(i,5) = data.ask(i);
                quotes(i,6) = data.bid_size(i);
                quotes(i,7) = data.ask_size(i);
            end
        end
        
        %private function to get quotes from CTP datasource
        function quotes = getquotes_ctp(obj)
             %TODO
            
            quotes = [];
            obj.quotessingle2pair;
           
        end
        
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
    end
    
    
    
    
    
    
end