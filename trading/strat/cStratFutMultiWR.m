classdef cStratFutMultiWR < cStrat
    
    properties
        numofperiods_@double
        tradingfreq_@double
        overbought_@double
        oversold_@double
    end
    
    methods
        function obj = cStratFutMultiWR
            obj.name_ = 'multiplewr';
        end
        %end of cStratFutMultiWR
    end
    
    methods
        function [] = setparameters(obj,instrument,params)
            if isempty(obj.numofperiods_), obj.numofperiods_ = zeros(obj.count,1); end
            
            if ~isa(instrument,'cInstrument')
                error('cStratFutMultiWR:setparameters:invalid instrument input')
            end
            
            if ~isstruct(params)
                error('cStratFutMultiWR:setparameters:invalid params input')
            end
            
            instruments = obj.instruments_.getinstrument;
            flag = false;
            for i = 1:obj.count
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    break
                end
            end
            if ~flag
                error('cStratFutMultiWR:setparameters:instrument not found')
            end
            
            propnames = fields(params);
            %default value
            wlpr = 144;
            for j = 1:size(propnames,1)
                if strcmpi(propnames{j},'numofperiods')
                    wlpr = params.(propnames{j});
                    break
                end
            end
            
            obj.numofperiods_(i) = wlpr;
            
            params_ = struct('name','WilliamR','values',{{propnames{j},wlpr}});
            obj.mde_fut_.settechnicalindicator(instrument,params_);
            
        end
        %end of setparameters
        
        function [] = settradingfreq(obj,instrument,freq)
            if isempty(obj.tradingfreq_), obj.tradingfreq_ = ones(obj.count,1);end
            
            if ~isa(instrument,'cInstrument')
                error('cStratFutMultiWR:settradingfreq:invalid instrument input')
            end
            
            instruments = obj.instruments_.getinstrument;
            flag = false;
            for i = 1:obj.count
                if strcmpi(instrument.code_ctp,instruments{i}.code_ctp)
                    flag = true;
                    obj.tradingfreq_(i) = freq;
                    break
                end
            end
            
            if ~flag
                error('cStratFutMultiWR:settradingfreq:instrument not found')
            end
            
            obj.mde_fut_.setcandlefreq(freq,instrument);
                
        end
        %end ofsettradingfreq
        
        function [] = 
            
        
        function signals = gensignal(obj,portfolio,quotes)
        end
        %end of gensignal
        
        
    end
    
end

