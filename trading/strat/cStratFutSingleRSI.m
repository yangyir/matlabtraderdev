classdef cStratFutSingleRSI < cStrat
    
    properties
        lowerboundaryopen_@double = 10
        lowerboundaryclose_@double = 50
        upperboundaryopen_@double = 90
        upperboundaryclose_@double = 50
        nperiod_@double = 14
        unit_@double = 1;
    end
    
    properties
        data_@double
    end
    
    methods
        function obj = cStratFutSingleRSI
            obj.name_ = 'singlersi';
        end
    end
    
    methods
        function signals = gensignal(obj,portfolio,quotes)
            %note:this is a single futures strategy
            list = obj.instruments_.getinstrument;
            instrument = list{1};
            
            qidx = 0;
            for j = 1:size(quotes)
                if strcmpi(instrument.code_ctp,quotes{j}.code_ctp)
                    qidx = j;
                    break
                end
            end
            if qidx == 0, error('cStratFutSingleRSI:gensignal:invalid quotes'); end
            
            px_last = quotes{qidx}.last_trade;
            [flag,idx] = portfolio.hasinstrument(instrument);
            if ~flag, error('cStratFutSingleRSI:gensignal:invalid input portfolio');  end
            volume_ = portfolio.instrument_volume(idx);
            
            n = size(obj.data_,1);
            
            if n <= obj.nperiod_
                data = zeros(n+1,1);
                data(1:n) = obj.data_(1:n);
            else
                data = zeros(obj.nperiod_+1,1);
                data(1:obj.nperiod_) = obj.data_(end-obj.nperiod_+1:end,1);
            end
            data(end) = px_last;
            obj.data_ = data;
            
            signals = cell(1);
            
            try
                indicate = rsindex(data,obj.nperiod_);
                indicate = indicate(end);
                if ~isnan(indicate)
                    fprintf('%s:spot:%4.2f; rsi:%4.1f\n',quotes{qidx}.update_time2,quotes{qidx}.last_trade,indicate);
                end
            catch
                signals{1} = struct('time',quotes{qidx}.update_time2,...
                'instrument',instrument,...
                'volume',0);
                return
            end
            
            
            if volume_ == 0 
                if indicate > obj.upperboundaryopen_
                    volume = -obj.unit_;
                elseif indicate < obj.lowerboundaryopen_
                    volume = obj.unit_;
                else
                    volume = 0;
                end
            elseif volume_ > 0
                %we have open long position already
                if indicate > obj.lowerboundaryclose_
                    volume = -obj.unit_;
                else
                    volume = 0;
                end
            else
                if indicate < obj.upperboundaryclose_
                    volume = obj.unit_;
                else
                    volume = 0;
                end
            end
                     
            signals{1} = struct('time',quotes{qidx}.update_time2,...
                'instrument',instrument,...
                'volume',volume);
                 
        end
    end
    
end

