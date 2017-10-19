classdef cMDE < handle
    %class of market data engine
    properties
        timer_@timer
        timer_interval_@double = 60;
        qms_@cQMS
        
        %option related
        underliers_@cInstrumentArray
        
        %live market data
        livedataarray_@cell
    end
    
    properties (Access = private)
        opt_pivottable_@cell
        
        refreshcount_ = 0
    end
    
    methods
        function [] = autorun(obj)
            obj.timer_ = timer('Period', obj.timer_interval_,...
                'StartFcn',@obj.start_timer_function,...
                'TimerFcn', @obj.replay_timer_function,...
                'StopFcn',@obj.stop_timer_function,...
                'BusyMode', 'drop',...
                'ExecutionMode', 'fixedSpacing',...
                'StartDelay', min(obj.timer_interval_,10));
            start(obj.timer_); 
        end
        
        function obj = initdataarray(obj)
            if isempty(obj.qms_)
                return;
            end
                
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            n = 24*60*60;
            da = cell(ns,1);
            for i = 1:ns
                da{i} = zeros(n,4);
            end
            
            obj.livedataarray_ = da;
            
        end
        %end of initdataarray
        
        function obj = registerinstrument(obj,instrument)
            obj.qms_.registerinstrument(instrument);
            
            %check whether the instrument is an option or not
            %if it is an option, we need to add its underlier to the
            %underlier container
            codestr = instrument.code_ctp;
            [flag,~,~,underlierstr,~] = isoptchar(codestr);
            if flag
                if isempty(obj.underliers_), obj.underliers_ = cInstrumentArray;end
                u = cFutures(underlierstr);
                u.loadinfo([underlierstr,'_info.txt']);
                obj.underliers_.addinstrument(u);
            end
            
        end
        %end of 'registerinstrument'
        
        function [] = refresh(obj)
            obj.qms_.refresh;
            displaypivottable_opt(obj);
        end
        
    end
    
    methods (Access = private)
        function tbls = pivottable_opt(obj)
            %note:currently only for one expiry per underlying
            %note:one underlier per table
            %column order:ticker(c) bid(c) ask(c) ivm(c)
            %colume order:ticker(p) bid(p) ask(p) ivm(p)
            if isempty(obj.underliers_), return; end
            nu = obj.underliers_.count;
            if nu == 0, return; end
            tbls = cell(nu,1);
            underliers = obj.underliers_.getinstrument;
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            strikes = cell(nu,1);
            for i = 1:nu
                code_u = underliers{i}.code_ctp;
                strike = zeros(ns,1);
                count = 0;
                for j = 1:ns
                    if isa(instruments{j},'cOption')
                        if strcmpi(instruments{j}.code_ctp_underlier,code_u)
                            count = count + 1;
                            strike(count) = instruments{j}.opt_strike;
                        end
                    end    
                end
                strike = strike(1:count,:);
                strike = unique(strike);
                strike = sort(strike);
                strikes{i} = strike;
            end
            
            %check and make sure both call/put with the same strike and
            %expiry are added in the qms
            for i = 1:nu
                issoymeal = strcmpi(underliers{i}.code_ctp(1),'m');
                issugar = strcmpi(underliers{i}.code_ctp(1:2),'SR');
                strike = strikes{i};
                
                tbl = cell(size(strike,1),4);
                
                for j = 1:size(strike,1)
                    if issoymeal
                        code_c = [underliers{i}.code_ctp,'-C-',num2str(strike(j))];
                        code_p = [underliers{i}.code_ctp,'-P-',num2str(strike(j))];
                    elseif issugar
                        code_c = [underliers{i}.code_ctp,'C',num2str(strike(j))];
                        code_p = [underliers{i}.code_ctp,'P',num2str(strike(j))];
                    else
                        error('unknown underlier')
                    end
                    
                    tbl{j,1} = underliers{i}.code_ctp;
                    tbl{j,2} = strike(j);
                    tbl{j,3} = code_c;
                    tbl{j,4} = code_p;
                    
                    if ~obj.qms_.watcher_.hassingle(code_c)
                        opt_c = cOption(code_c);
                        opt_c.loadinfo([code_c,'_info.txt']);
                        obj.qms_.registerinstrument(opt_c);
                    end
                    
                    if ~obj.qms_.watcher_.hassingle(code_p)
                        opt_p = cOption(code_p);
                        opt_p.loadinfo([code_p,'_info.txt']);
                        obj.qms_.registerinstrument(opt_p);
                    end
                                
                end
                tbls{i} = tbl;
            end
            %finish check options
            
            instruments_ = obj.qms_.instruments_.getinstrument;
            ns_ = size(instruments_,1);
            if ns_ ~= ns
                livedataarray = cell(ns_,1);
                obj.livedataarray_ = livedataarray;
            end
            
            if nu > 0,obj.opt_pivottable_ = tbls;end
            
        end
        %end of pivottable_opt
        
        function [] = displaypivottable_opt(obj)
            if isempty(obj.opt_pivottable_) || size(obj.opt_pivottable_,1) == 0
                obj.pivottable_opt;
            end
           
            qs = obj.qms_.getquote;
            
            for i = 1:size(obj.opt_pivottable_,1)
                tbl = obj.opt_pivottable_{i};
                
                if size(tbl,1) == 0, continue; end
                
                fprintf('\n');
                
            
                for j = 1:size(tbl,1)
                    strike = tbl{j,2};
                    c = tbl{j,3};
                    p = tbl{j,4};
                
                    idxc = 0;
                    for k = 1:size(qs,1)
                        if strcmpi(c,qs{k}.code_ctp),idxc = k;break; end
                    end
                
                    idxp = 0;
                    for k = 1:size(qs,1)
                        if strcmpi(p,qs{k}.code_ctp),idxp = k;break; end
                    end
                
                    ivc = qs{idxc}.impvol;
                    bc = qs{idxc}.bid1;
                    ac = qs{idxc}.ask1;
                    ivp = qs{idxp}.impvol;
                    bp = qs{idxp}.bid1;
                    ap = qs{idxp}.ask1;
                
                    if j == 1
                        fprintf('\t%s','ticker');
                        fprintf('\t%8s','bid(c)');fprintf('%7s','ask(c)');fprintf('%8s','ivm(c)');
                        fprintf('\t%s','strike');
                        fprintf('\t%9s','ticker');
                        fprintf('\t%8s','bid(p)');fprintf('%7s','ask(p)');fprintf('%8s','ivm(p)');
                        fprintf('\n');
                    end
                    
                    if j > 1 && ~strcmpi(tbl{j,1},tbl{j-1,1}) ,fprintf('\n'); end
                
                    fprintf('%12s ', tbl{j,3});
                    fprintf('%6.1f ',bc);
                    fprintf('%6.1f ',ac);
                    fprintf('%6.1f%% ',ivc*100);
                    fprintf('%6.0f ',strike);
                    fprintf('%14s ', tbl{j,4});
                    fprintf('%6.1f ',bp);
                    fprintf('%6.1f ',ap);
                    fprintf('%6.1f%% ',ivp*100);
                    fprintf('\n');
                    
                    if j == size(tbl,1)
                        fprintf('%12s ', tbl{j,1});
                        fprintf('%6.0f ',qs{idxc}.bid_underlier);
                        fprintf('%6.0f ',qs{idxc}.ask_underlier);
                        fprintf('\n');
                    end
                end
                
            end
        end
        %end of displaypivottable_opt
        
        function [] = filldataarray(obj)
            count = obj.refreshcount_ + 1;
            instruments = obj.qms_.instruments_.getinstrument;
            ns = size(instruments,1);
            qs = obj.qms_.getquote;
            
            for i = 1:ns
                obj.livedataarray_{i}(count,1) = qs{1}.update_time1;
                obj.livedataarray_{i}(count,2) = qs{1}.bid1;
                obj.livedataarray_{i}(count,3) = qs{1}.ask1;
                obj.livedataarray_{i}(count,4) = qs{1}.last_trade;
            end
            
            obj.refreshcount_ = count;
            
            
        end
        %end of filldataarray
        
        function [] = replay_timer_function(obj,~,event)
            disp([datestr(event.Data.time),' mde run...']);
            obj.refresh;
            obj.filldataarray
        end
        %end of replay_timer_function
        
        function [] = start_timer_function(~,~,event)
            disp([datestr(event.Data.time),' mde starts...']);
        end
        %end of start_timer_function
        
        function [] = stop_timer_function(~,~,event)
            disp([datestr(event.Data.time),' mde stops...']);
        end
        %end of stop_timer_function
        
    end
end