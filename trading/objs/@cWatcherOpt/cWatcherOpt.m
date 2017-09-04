classdef cWatcherOpt < cWatcherFut
    
    properties
        underliers@cell
    end
    
    properties (Hidden = true)
        underliers_w@cell
        underliers_b@cell
        underliers_ctp@cell
    end
       
    methods
        function obj = addsingle(obj,singlestr)
            %need sanity check for the instrument
            [flag,~,~,underlierstr] = isoptchar(singlestr);
            
            if ~flag
                warning(['cWatcherOpt:addsingle:',singlestr,' is not an option']);
                return
            end
                       
            %call the base class method then after the sanity check
            addsingle@cWatcherFut(obj,singlestr);
            
            %we need to add underlier for options
            obj.addunderlier(underlierstr);
            
        end
        %end of member function addsingle
        
        function obj = removesingle(obj,singlestr)
            %in case we need to remove a single option leg, we need to
            %check whether we need to remove its underlier from the
            %container or not, i.e. in case the underlier is not shared by
            %other legs, we would remove it with the single leg at the same
            %time
            [flag,~,~,underlierstr] = isoptchar(singlestr);
            
            if ~flag
                warning(['cWatcherOpt:removesingle:',singlestr,' is not an option']);
                return
            end
            
            [flag,idx] = obj.hassingle(singlestr);
            if ~flag
                warning(['cWatcherOpt:removesingle:',singlestr,' not found']);
            end
            
            flag_removeunderlier = true;
            ns = obj.countsingles;
            for i = 1:ns
                if i ~= idx
                    [~,~,~,underlierstr_i] = isoptchar(obj.singles{i});
                    if strcmpi(underlierstr,underlierstr_i)
                        %the underlier is shared by other legs
                        flag_removeunderlier = false;
                        break
                    end         
                end
            end
            
            if ~flag_removeunderlier
                removesingle@cWatcherFut(obj,singlestr);
            else
                obj.removeunderlier(underlierstr);
                removesingle@cWatcherFut(obj,singlestr);
            end
            
        end
        %end of member function removesingle
        
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
        %end of member function removeunderlier
        
        function obj = addpair(obj,pairstr)
            %need sanity check for instruments
            pairint = regexp(pairstr,',','split');
            for i = 1:length(pairint)
                if ~isoptchar(pairint{i})
                    warning(['cWatcherOpt:addpair:',pairstr,' is not valid!']);
                    return
                end
            end
            
            %call the base class method then after the sanity check
            addpair@cWatcherFut(obj,pairstr);
   
        end
        %end of member function addpair
        
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
        %end of member function getquotes
        
        function obj = refresh(obj)
            data = obj.getquotes;
            ns = obj.countsingles;
            nu = obj.countunderliers;
            obj.init_singlequotes;
            
            for i = ns+1:ns+nu
                if isempty(obj.qs{i})
                    obj.qs{i} = cQuoteFut;
                end
                obj.qs{i}.update(obj.underliers_ctp{i-ns},data(i,1),data(i,2),...
                    data(i,3),data(i,4),data(i,5),data(i,6),data(i,7));
            end
            for i = 1:ns
                [~,~,~,underlierstr] = isoptchar(obj.singles{i});
                [~,idx ] = obj.hasunderlier(underlierstr);
                obj.qs{i}.update(obj.singles_ctp{i},data(i,1),data(i,2),...
                    data(i,3),data(i,4),data(i,5),data(i,6),data(i,7),...
                    obj.qs{ns+idx});
            end
            
        end
        %end of member function refresh
        
        function close(obj)
            obj.underliers = {};
            obj.underliers_b = {};
            obj.underliers_w = {};
            obj.underliers_ctp = {};
            close@cWatcherFut(obj);
        end
        %end of member function close
        
    end
    
    
    methods (Access = private)
        %private function to get quotes from WIND datasource
        function quotes = getquotes_wind(obj)
            obj.init_singlequotes;
            ns = obj.countsingles;
            nu = obj.countunderliers;
            list_ctp = cell(ns+nu,1);
            for i = 1:ns
                list_ctp{i} = obj.singles_ctp{i};
            end
            for i = ns+1:ns+nu
                list_ctp{i} = obj.underliers_ctp{i-ns};
            end
            
            if ns > 0
                list_wind = obj.singles_w{1};
            end
            
            for i = 2:ns
                temp = [list_wind,',',obj.singles_w{i}];
                list_wind = temp;
            end
            
            for i = 1:nu
                temp = [list_wind,',',obj.underliers_w{i}];
                list_wind = temp;
            end
            
            quotes = zeros(ns+nu,7);
            data = obj.c.wsq(list_wind,'rt_date,rt_time,rt_latest,rt_bid1,rt_ask1,rt_bsize1,rt_asize1');
            %rt_date is in the format of yyyymmdd
            %rt_time is in the format of hhmmss
            for i = 1:ns+nu
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
        %end of member function getquotes_wind
        
        %private function to get quotes from BLOOMBERG datasource
        function quotes = getquotes_bbg(obj)
            obj.init_singlequotes;
            ns = obj.countsingles;
            nu = obj.countunderliers;
            list_ctp = cell(ns+nu,1);
            list_bbg = cell(ns+nu,1);
            for i = 1:ns
                list_ctp{i} = obj.singles_ctp{i};
                list_bbg{i} = obj.singles_b{i};
            end
            for i = ns+1:ns+nu
                list_ctp{i} = obj.underliers_ctp{i-ns};
                list_bbg{i} = obj.underliers_b{i-ns};
            end
            
            quotes = zeros(ns+nu,7);
            data = getdata(obj.c,list_bbg,{'last_update_dt','time','last_trade','bid','ask','bid_size','ask_size'});
            
            for i = 1:ns+nu
                quotes(i,1) = data.last_update_dt(i);     %date
                %time field may not pop-up as HH:MM:SS but as mm/dd/yyyy
                try
                    quotes(i,2) = datenum([datestr(quotes(i,1)),' ',data.time{i}]);
                catch
                    if isempty(strfind(data.time{i},':'))
                        quotes(i,2) = datenum([datestr(quotes(i,1)),' 15:00:00']);
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
        %end of member function 'getquotes_bbg'
        
        %private function to get quotes from CTP datasource
        function quotes = getquotes_ctp(obj)
            obj.close;
            quotes = [];
        end
        %end of member function getquotes_ctp
            
        function obj = init_singlequotes(obj)
            if isempty(obj.qs)
                ns = obj.countsingles;
                nu = obj.countunderliers;
                obj.qs = cell(ns+nu,1);
                %here we only initiate the quotes for option legs but not
                %the underlier
                for i = 1:ns
                    q = cQuoteOpt;
                    q.init(obj.singles{i});
                    %set interest rate level once a day
                    %note:this now only works with Bloomberg
                    if isempty(q.riskless_rate)
                        if isa(obj.c,'blp')
                            data = getdata(obj.c,'CCSWOC CMPN Curncy','px_last');
                            q.riskless_rate = data.px_last/100;
                        else
                            q.riskless_rate = 0.035;
                        end
                    end
                    
                    obj.qs{i} = q;
                end
            end
        end
        %end of member function 'init_singlequotes
        
        function obj = addunderlier(obj,underlierstr)
            if ~ischar(underlierstr)
                error('cWatcherOpt:addunderlier:invalid underlier string input')
            end
            if ~obj.hasunderlier(underlierstr)
                n = length(obj.underliers);
                n = n + 1;
                u = cell(n,1);
                u_w = cell(n,1);
                u_b = cell(n,1);
                u_ctp = cell(n,1);
                u{n} = underlierstr;
                u_ctp{n} = str2ctp(underlierstr);
                u_w{n} = ctp2wind(u_ctp{n});
                u_b{n} = ctp2bbg(u_ctp{n});
                if n > 1
                    for i = 1:n-1
                        u{i} = obj.underliers{i};
                        u_ctp{i} = obj.underliers_ctp{i};
                        u_w{i} = obj.underliers_w{i};
                        u_b{i} = obj.underliers_b{i};
                    end
                end
                obj.underliers = u;
                obj.underliers_ctp = u_ctp;
                obj.underliers_w = u_w;
                obj.underliers_b = u_b;
            end
        end
        %end of member function 'addunderlier'
        
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
        %end of member function hasunderlier
        
        function n = countunderliers(obj)
            n = length(obj.underliers);
        end
        %end of member function countunderliers
        
    end
end
    