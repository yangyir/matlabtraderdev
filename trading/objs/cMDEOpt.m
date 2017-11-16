classdef cMDEOpt < handle
    %Note: the class of Market Data Engine for listed options
    properties
        mode_@char = 'realtime'
        status_@char = 'sleep';
        
        timer_@timer
        timer_interval_@double = 0.5
        
        options_@cInstrumentArray
        underliers_@cInstrumentArray
        
        qms_@cQMS
        
        %real-time data
        %we only record the lastest ticks for the options 
        quotes_@cell
        

        
    end
    
    methods
        function obj = registerinstrument(obj,instrument)
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
        
        
        
    end
    
    methods (Access = public)
        function [] = savequotes2mem(obj)
            obj.quotes_ = obj.qms_.getquote;
        end
        %end of savequotes2mem
        
        function strikes = uniquestrikes(obj)
            opts = obj.qms_.instruments_.getinstrument;
            n = size(opts,1);
            strikes = zeros(n,1);
            for i = 1:n
                strikes(i) = opts{i}.opt_strike;
            end
            
            strikes = unique(strikes);
            strikes = sort(strikes);
            
        end
        %end of uniquestrikes
        
        function tbl = pivottable(obj)
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
                    if i == 1 && j == 1
                        count = count + 1;
                        tbl{count,1} = u.code_ctp;
                        tbl{count,2} = o.opt_strike;
                        if strcmpi(o.opt_type,'C'),tbl{count,3} = o.code_ctp;else tbl{count,4} = o.code_ctp;end
                    else
                        u_ = o.code_ctp_underlier;
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
            
            
            
        end
        %end of pivottable
        
        
    end
    
    
end