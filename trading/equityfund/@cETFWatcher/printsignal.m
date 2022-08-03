function [] = printsignal(obj,varargin)
%cETFWatcher
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('Code','all',@ischar);
    p.addParameter('Time',now,@isnumeric);
    p.parse(varargin{:});
    code2print = p.Results.Code;
    timet = p.Results.Time;
    
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    
    ticksize = 0.001;
    candlebucket = 1/48;%intraday 30m bucket
    nfractal = 4;
    
    fprintf('\n');
    if strcmpi(code2print,'all')
        for i = 1:n_index
            if strcmpi(obj.codes_index_{i}(1:6),'159781') || ...
                    strcmpi(obj.codes_index_{i}(1:6),'159782')
                %省略双创50ETF和双创50ETF基金
                continue;
            end
            extrainfo_i = obj.intradaybarstruct_index_{i};
            [ret,direction,breachtime,breachidx] = fractal_hasintradaybreach(timet,extrainfo_i,ticksize);
            
            if ret
                ei_breach = fractal_truncate(extrainfo_i,breachidx);
                [signal,op] = fractal_signal_unconditional(ei_breach,ticksize,nfractal);
                if direction == 1
                    fprintf('%s:intraday breachUP:%s:\t',datestr(breachtime+candlebucket,'yyyy-mm-dd HH:MM'),obj.codes_index_{i}(1:6));
                    fprintf('%2d\t%s(%s)\n',signal(1),op.comment,obj.names_index_{i});
                else
                    fprintf('%s:intraday breachDN:%s:\t',datestr(breachtime+candlebucket,'yyyy-mm-dd HH:MM'),obj.codes_index_{i}(1:6));
                    fprintf('%2d\t%s(%s)\n',signal(1),op.comment,obj.names_index_{i});
                end
                obj.intradaybarriers_conditional_index_(i,1) = NaN;
                obj.intradaybarriers_conditional_index_(i,2) = NaN;
            end
            
            if timet - extrainfo_i.px(end,1) >= candlebucket
                [signal2,op2] = fractal_signal_conditional(extrainfo_i,ticksize,nfractal,'uselastcandle',true);
            else
                [signal2,op2] = fractal_signal_conditional(extrainfo_i,ticksize,nfractal,'uselastcandle',false);
            end
            if ~isempty(signal2)
                if ~isempty(signal2{1})
                    %                         fprintf('%s:BreachUP:%s:\t%2d\t%s-up:%4.3f(%s)\n',datestr(timet,'yyyy-mm-dd HH:MM'),...
                    %                             obj.codes_index_{i}(1:6),signal2{1}(1),op2{1},signal2{1}(2),obj.names_index_{i});
                    obj.intradaybarriers_conditional_index_(i,1) = signal2{1}(1,2);
                end
                if ~isempty(signal2{2})
                    %                         fprintf('%s:BreachDN:%s:\t%2d\t%s-dn:%4.3f(%s)\n',datestr(timet,'yyyy-mm-dd HH:MM'),...
                    %                             obj.codes_index_{i}(1:6),signal2{2}(1),op2{2},signal2{2}(3),obj.names_index_{i});
                    obj.intradaybarriers_conditional_index_(i,2) = signal2{2}(1,3);
                end
            else
                obj.intradaybarriers_conditional_index_(i,1) = NaN;
                obj.intradaybarriers_conditional_index_(i,2) = NaN;
            end
            
        end
        %
        fprintf('\n');
        for i = 1:n_sector
            if strcmpi(obj.codes_sector_{i}(1:6),'512800') || ...
                    strcmpi(obj.codes_sector_{i}(1:6),'512880')
                %省略证券ETF和银行ETF基金
                continue;
            end
            extrainfo_i = obj.intradaybarstruct_sector_{i};
            [ret,direction,breachtime,breachidx] = fractal_hasintradaybreach(timet,extrainfo_i,ticksize);           
            if ret
                ei_breach = fractal_truncate(extrainfo_i,breachidx);
                [signal,op] = fractal_signal_unconditional(ei_breach,ticksize,nfractal);
                if direction == 1
                    fprintf('%s:intraday breachUP:%s:\t',datestr(breachtime+candlebucket,'yyyy-mm-dd HH:MM'),obj.codes_sector_{i}(1:6));
                    fprintf('%2d\t%s(%s)\n',signal(1),op.comment,obj.names_sector_{i});
                else
                    fprintf('%s:intraday breachDN:%s:\t',datestr(breachtime+candlebucket,'yyyy-mm-dd HH:MM'),obj.codes_sector_{i}(1:6));
                    fprintf('%2d\t%s(%s)\n',signal(1),op.comment,obj.names_sector_{i});
                end
                obj.intradaybarriers_conditional_sector_(i,1) = NaN;
                obj.intradaybarriers_conditional_sector_(i,2) = NaN;
            end
            if timet - extrainfo_i.px(end,1) >= candlebucket
                [signal2,op2] = fractal_signal_conditional(extrainfo_i,ticksize,nfractal,'uselastcandle',true);
            else
                [signal2,op2] = fractal_signal_conditional(extrainfo_i,ticksize,nfractal,'uselastcandle',false);
            end
            if ~isempty(signal2)
                if ~isempty(signal2{1})
                    %                         fprintf('%s:BreachUP:%s:\t%2d\t%s-up:%4.3f(%s)\n',datestr(timet,'yyyy-mm-dd HH:MM'),...
                    %                             obj.codes_sector_{i}(1:6),signal2{1}(1),op2{1},signal2{1}(2),obj.names_sector_{i});
                    obj.intradaybarriers_conditional_sector_(i,1) = signal2{1}(1,2);
                end
                if ~isempty(signal2{2})
                    %                         fprintf('%s:BreachDN:%s:\t%2d\t%s-dn:%4.3f(%s)\n',datestr(timet,'yyyy-mm-dd HH:MM'),...
                    %                             obj.codes_sector_{i}(1:6),signal2{2}(1),op2{2},signal2{2}(3),obj.names_sector_{i});
                    obj.intradaybarriers_conditional_sector_(i,2) = signal2{2}(1,3);
                end
            else
                obj.intradaybarriers_conditional_sector_(i,1) = NaN;
                obj.intradaybarriers_conditional_sector_(i,2) = NaN;
            end
        end
        %
        return
    end
    %
    
end