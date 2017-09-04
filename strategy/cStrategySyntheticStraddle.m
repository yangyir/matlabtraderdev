classdef cStrategySyntheticStraddle
    properties
        ParticipateRate
        Straddles       %a list of cStraddles
    end
    
    methods (Access = public)
        function obj = cStrategySyntheticStraddle(varargin)
            obj = init(obj,varargin{:});
        end    
        %end of constructor
    end
    
    methods
        function obj = clear(obj)
            obj.Straddles = {};
        end
        %end of clear
        
        function obj = addstraddle(obj,straddle)
            existingStraddles = obj.Straddles;
            if isempty(existingStraddles)
                obj.Straddles = {straddle};
            else
                %first to check whether this straddle exists in the list
                n = length(existingStraddles);
                flag = false;
                for i = 1:n
                    if existingStraddles{i}.isequal(straddle)
                        flag = true;
                        existingStraddles{i}.Notional = straddle.Notional + existingStraddles{i}.Notional;
                        obj.Straddles = existingStraddles;
                    end
                end
                
                if ~flag
                    newStraddles = cell(n+1,1);
                    newStraddles(1:end-1,1) = existingStraddles;
                    newStraddles(end,1) = straddle;
                    obj.Straddles = newStraddles;
                end
            end
            
        end
        %end of addstraddle
        
        function obj = removestraddle(obj,straddle)
            existingStraddles = obj.Straddles;
            if isempty(existingStraddles)
                error('cStrategySyntheticStraddle:removestraddle:invalid straddle input!')
            end
            
            n = length(existingStraddles);
            idx = 0;
            for i = 1:n
                if existingStraddles{i}.isequal(straddle)
                    idx = i;
                    if straddle.Notional > existingStraddles{i}.Notional
                        error('cStrategySyntheticStraddle:removestraddle:invalid straddle input!')
                    else
                        if straddle.Notional == existingStraddles{i}.Notional
                            removeType = 'all';
                        else
                            removeType = 'partial';
                        end
                    end
                    
                    break
                end
            end
            
            if idx == 0
                error('cStrategySyntheticStraddle:removestraddle:invalid straddle input!')
            end
            
            if n == 1
                if strcmpi(removeType, 'all')
                    obj.Straddles = {};
                else
                    newStraddle = obj.Straddles{1};
                    newStraddle.Notional = newStraddle.Notional - straddle.Notional;
                    obj.Straddles = {newStraddle};
                end
            else
                if strcmpi(removeType,'all')
                    straddles = cell(n-1,1);
                    if idx == 1
                        straddles = existingStraddles(2:end,:);
                    else
                        straddles(1:idx-1,:) = existingStraddles(1:idx-1,:);
                        straddles(idx:end,:) = existingStraddles(idx+1:end,:);
                    end
                    obj.Straddles = straddles;
                else
                    newStraddles = existingStraddles;
                    newStraddles{idx}.Notional = existingStraddles{idx}.Notional - straddle.Notional;
                    obj.Straddles = newStraddles;
                end
            end
        end
        %end of removestraddle
        
        function orders = genorder(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('UnderlierInfo',{},@(x)validateattributes(x,{'struct'},{},'UnderlierInfo'));
            p.addParameter('UnderlierVol',{},@(x)validateattributes(x,{'cMarketVol','struct'},{},'UnderlierVol'));
            p.addParameter('TradingPlatform',{},@(x)validateattributes(x,{'cTradingPlatform'},{},'TradingPlatform'));
            p.parse(varargin{:});
            underlierinfo = p.Results.UnderlierInfo;
            underliervol = p.Results.UnderlierVol;
            tp = p.Results.TradingPlatform;
            if isempty(tp)
                error('cStrategySyntheticStraddle:genorder:a tradingplatform is required!')
            end
            
            straddles = obj.Straddles;
            if isempty(straddles)
                orders = {};
                return
            end
            
            %find the corresponding straddles with the same underlier as of
            %the underlierinfo
            %note that we may have different straddles with the same
            %underlier but different strikes and expiries and we shall deal
            %with each straddle's stop/loss in the later code development
            n = length(straddles);
            deltaAll = 0;
            for i = 1:n
               underlier = straddles{i}.Underlier;
               bbgCode = underlier.BloombergCode;
               if strcmpi(underlierinfo.Instrument.BloombergCode,bbgCode)
                   time = underlierinfo.Time;
                   tradingIdx = find(floor(time)==straddles{i}.TradingDays);
                   t = (length(straddles{i}.TradingDays)-tradingIdx+1)/252;
                   price = underlierinfo.Price;
                   vol = underliervol.Vol;
                   strike = straddles{i}.Strike;
                   rate = 0;
                   yield = 0;
                   notional = straddles{i}.Notional;
                   [~,delta,~,~,~] = valstraddle(price,strike,rate,t,vol,yield,notional);
                   deltaAll = deltaAll+delta;    
               end
            end
            orders = optstrat_genorders(tp,underlierinfo,deltaAll,obj.ParticipateRate);
            
        end
        %end of genorder
        
    end
    
    
    
    
    
    methods (Access = private)
        function obj = init(obj,varargin)
            if isempty(varargin)
                obj.ParticipateRate = 0.8;
                obj.Straddles = {};
            end
            
        end
        
        
        
        
    end
    
    
end