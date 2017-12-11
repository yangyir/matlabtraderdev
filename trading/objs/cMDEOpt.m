classdef cMDEOpt < handle
    %Note: the class of Market Data Engine for listed options
    properties
        mode_@char = 'realtime'
        status_@char = 'sleep';
        
        timer_@timer
        %refresh the mde every minute
        timer_interval_@double = 60
        
        options_@cInstrumentArray
        underliers_@cInstrumentArray
        
        qms_@cQMS
        
        display_@double = 1

    end
    
    properties (Access = private)
        quotes_@cell
        pivottable_@cell
    end
    
    methods
        function [] = loadoptions(obj,code_ctp_underlier,numstrikes)
            if nargin < 3
                [calls,puts] = getlistedoptions(code_ctp_underlier);
            else
                [calls,puts] = getlistedoptions(code_ctp_underlier,numstrikes);
            end
            for i = 1:size(calls,1)
                obj.registerinstrument(calls{i});
                obj.registerinstrument(puts{i});
            end
        end
        %end of loadoptions
        
        function [] = registerinstrument(obj,instrument)
            if ~isa(instrument,'cInstrument'),error('cMDEOpt:registerinstrument:invalid instrument input');end
            codestr = instrument.code_ctp;
            [isopt,~,~,underlierstr] = isoptchar(codestr);
            if ~isopt, return; end
            
            obj.qms_.registerinstrument(instrument);
            if isempty(obj.options_)
                obj.options_ = cInstrumentArray;
            end
            obj.options_.addinstrument(instrument);
            
            if isempty(obj.underliers_)
                obj.underliers_ = cInstrumentArray;
            end
            
            underlier = cFutures(underlierstr);
            underlier.loadinfo([underlierstr,'_info.txt']);
            obj.underliers_.addinstrument(underlier);
            
        end
        %end of registerinstrument
        
        function [] = refresh(obj)
            if ~isempty(obj.qms_)
                if strcmpi(obj.mode_,'realtime')
                    obj.qms_.refresh;
                else
                    return
%                     error('to be finished')
                end
                
                obj.savequotes2mem;
                
                if obj.display_, obj.displaypivottable; end
                
            end
        end
        %end of refresh
        
        function tbl = voltable(obj)
            tbl = obj.displaypivottable;
        end
        %end of voltable
        
        function start(obj)
            obj.status_ = 'working';
            obj.settimer;
            start(obj.timer_);
        end
        %end of start
        
        function stop(obj)
            stop(obj.timer_);
        end
        %end of stop
        
        
    end
    
    methods (Access = private)
        function [] = savequotes2mem(obj)
            obj.quotes_ = obj.qms_.getquote;
        end
        %end of savequotes2mem
        
        function tbl = genpivottable(obj)
            underliers = obj.underliers_.getinstrument;
            options = obj.options_.getinstrument;
            
            nu = size(underliers,1);
            no = size(options,1);
            if mod(no,2) ~= 0, error('cMDEOpt:pivottable:number of options shall be even'); end
            
            tbl = cell(no/2,4);
            
            count = 0;
            for i = 1:nu
                u = underliers{i};
                for j = 1:no
                    o = options{j};
                    u_ = o.code_ctp_underlier;
                    if ~strcmpi(u.code_ctp,u_), continue; end
                    if i == 1 && j == 1
                        count = count + 1;
                        tbl{count,1} = u.code_ctp;
                        tbl{count,2} = o.opt_strike;
                        if strcmpi(o.opt_type,'C'),tbl{count,3} = o.code_ctp;else tbl{count,4} = o.code_ctp;end
                    else
                        strike = o.opt_strike;
                        flag = false;
                        for k = 1:count
                                if strcmpi(tbl{k,1},u_) && tbl{k,2} == strike
                                    flag = true;
                                    if strcmpi(o.opt_type,'C'),tbl{k,3} = o.code_ctp;else tbl{k,4} = o.code_ctp;end
                                    break
                                end
                            
                        end
                        if ~flag
                            count = count + 1;
                            tbl{count,1} = u_;
                            tbl{count,2} = strike;
                            if strcmpi(o.opt_type,'C'), tbl{count,3} = o.code_ctp;else tbl{count,4} = o.code_ctp;end
                        end
                    end  
                end 
            end
            
            obj.pivottable_ = tbl;
        end
        %end of genpivottable
        
        function tbl = displaypivottable(obj)
            tbl = {};
            if isempty(obj.options_), return; end
            if isempty(obj.pivottable_), obj.genpivottable; end
            
            fprintf('\t%s','ticker');
            fprintf('\t%8s','bid(c)');fprintf('%7s','ask(c)');fprintf('%8s','ivm(c)');
            fprintf('\t%s','strike');
            fprintf('\t%9s','ticker');
            fprintf('\t%8s','bid(p)');fprintf('%7s','ask(p)');fprintf('%8s','ivm(p)');
            fprintf('\t%8s','mid(u)');
            fprintf('\n');
            
            tbl = cell(size(obj.pivottable_,1),10);
            
            for i = 1:size(obj.pivottable_,1)
                strike = obj.pivottable_{i,2};
                c = obj.pivottable_{i,3};
                p = obj.pivottable_{i,4};
                
                idxc = 0;
                for j = 1:size(obj.quotes_,1)
                    if strcmpi(c,obj.quotes_{j}.code_ctp),idxc = j;break; end
                end
                
                idxp = 0;
                for j = 1:size(obj.quotes_,1)
                    if strcmpi(p,obj.quotes_{j}.code_ctp),idxp = j;break; end
                end
                
                if idxc ~= 0 
                    ivc = obj.quotes_{idxc}.impvol;
                    bc = obj.quotes_{idxc}.bid1;
                    ac = obj.quotes_{idxc}.ask1;
                    um = 0.5*(obj.quotes_{idxc}.bid_underlier + obj.quotes_{idxc}.ask_underlier);
                else
                    ivc = NaN;
                    bc = NaN;
                    ac = NaN;
                    um = NaN;
                end
                
                if idxp ~= 0    
                    ivp = obj.quotes_{idxp}.impvol;
                    bp = obj.quotes_{idxp}.bid1;
                    ap = obj.quotes_{idxp}.ask1;
                else
                    ivp = NaN;
                    bp = NaN;
                    ap = NaN;
                end
                
                tbl{i,1} = obj.pivottable_{i,3};
                tbl{i,2} = bc;
                tbl{i,3} = ac;
                tbl{i,4} = ivc;
                tbl{i,5} = strike;
                tbl{i,6} = obj.pivottable_{i,4};
                tbl{i,7} = bp;
                tbl{i,8} = ap;
                tbl{i,9} = ivp;
                tbl{i,10} = um;
                
                %add a blank line when underlying changed
                if i > 1 && ~strcmpi(obj.pivottable_{i,1},obj.pivottable_{i-1,1}) ,fprintf('\n'); end
                
                fprintf('%12s ', obj.pivottable_{i,3});
                fprintf('%6.1f ',bc);
                fprintf('%6.1f ',ac);
                fprintf('%6.1f%% ',ivc*100);
                fprintf('%6.0f ',strike);
                fprintf('%14s ', obj.pivottable_{i,4});
                fprintf('%6.1f ',bp);
                fprintf('%6.1f ',ap);
                fprintf('%6.1f%% ',ivp*100);
                fprintf('%9.1f ',um);
                fprintf('\n');

            end
            fprintf('\n');
            
        end
        %end of displaypivottable
        
        
    end
    
   %% timer functions
    methods (Access = private)
        function [] = settimer(obj)
            obj.timer_ = timer('Period', obj.timer_interval_,...
                'StartFcn',@obj.start_timer_fcn,...
                'TimerFcn', @obj.replay_timer_fcn,...
                'StopFcn',@obj.stop_timer_fcn,...
                'BusyMode', 'drop',...
                'ExecutionMode', 'fixedSpacing',...
                'StartDelay', min(obj.timer_interval_,5));
        end
        %end of settimer
        
        function [] = replay_timer_fcn(obj,~,event)
            if strcmpi(obj.mode_,'realtime')
                dtnum = datenum(event.Data.time);
            else
                error('cMDEOpt:replay_timer_fcn:invalid mode')
            end
            
            hh = hour(dtnum);
            mm = minute(dtnum) + hh*60;
            
            %for friday evening market
            if isholiday(floor(dtnum))
                if weekday(dtnum) == 7 && mm >= 180
                    obj.status_ = 'sleep';
                    return
                elseif weekday(dtnum) == 7 && mm < 180
                    %do nothing
                else
                    obj.status_ = 'sleep';
                    return
                end
            end
            
            if (mm >= 0 && mm < 540) || ...
                    (mm > 690 && mm < 810) || ...
                    (mm > 915 && mm < 1260) || ...
                    (mm > 1410 && mm < 1440)
                %market closed for sure
                obj.status_ = 'sleep';          
                return
            end
            obj.status_ = 'working';
            
            obj.refresh;
            
        end
        %end of replay_timer_function
        
        function [] = start_timer_fcn(~,~,event)
            disp([datestr(event.Data.time),' mdeopt starts......']);
        end
        %end of start_timer_function
        
        function [] = stop_timer_fcn(~,~,event)
            disp([datestr(event.Data.time),' mdeopt stops......']);
        end
        %end of stop_timer_function
        
    end
    
    
end