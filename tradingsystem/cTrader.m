classdef cTrader
    %class of trader
    properties
        TraderID = 'unknown'
        Strategies = {}
        
    end
    
    methods
        function obj = cTrader(varargin)
        end
        %end of constructor
    end
    
    methods (Access = public)
        function obj = registerstrategies(obj,strats)
            if iscell(strats)
                for i = 1:length(strats)
                    obj = registerstrategy(obj,strats{i});
                end
            elseif isa(strats,'cStrategy')
                obj = registerstrategy(obj,strats);
            else
                error('cTrader:registerstrategies:invalid input of strategies')
            end
        end
        %end of 'registerstrategies'
        
    end
    
    
    methods (Access = private)
        function obj = registerstrategy(obj,strat)
            if ~isa(strat,'cStrategy')
                error('cTrader:registerstrategies:invalid input of strategies')
            end
            
            %only register with a different instrument
            for i = 1:length(obj.Strategies)
                if strcmpi(obj.Strategies{i}.StrategyID,strat.StrategyID)
                    return
                end
            end
            
            n = length(obj.Strategies)+1;
            strats = cell(n,1);
            strats(1:n-1,1) = obj.Strategies;
            strats{n,1} = strat;
            obj.Strategies = strats;
        end
        %end of 'registerstrategy'
        
    end
    
end