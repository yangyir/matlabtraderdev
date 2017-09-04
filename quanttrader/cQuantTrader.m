classdef cQuantTrader
    %class of QuantTrader
    %it is a wrapper of the QuantTrader add-ins and its associated
    %functions
    
    properties
        AccountSerialID
        Contracts          % cell of cContract
        TradingPlatform    % cTradingPlatform
        Strategies         % cell of cStrategy and its derivations
    end
    
    methods
        function obj = cQuantTrader(decisionData)
            obj = init(obj,decisionData);
        end
        %
        
        function obj = addstrategy(obj,strategy)
            if ~isa(strategy,'cStrategy')
                error('cQuantTrader:launchstrategy:invaid strategy input');
            end
            if isempty(obj.Strategies)
                n = 1;
            else
                n = length(obj.Strategies)+1;
            end
            strategies = cell(n,1);
            if ~isempty(obj.Strategies)
                strategies{n-1,1} = obj.Strategies; 
            end
            strategies{n,1} = strategy;
            obj.Strategies = strategies;     
        end
        %end of addstrategy function
        
    end
    
    methods (Access = public)
        function [obj,output] = placeorder(obj,decisionData)
            
        end
        % end of placeorder
        
        
    end
    
    methods (Access = private)
        function obj = init(obj,decisionData)
            %the following code shall be executed smoothly if and only if
            %the QuantTrader add-in is installed in the running machine
            orgIDs = decisionData.tickerList;
            futures = cell(length(orgIDs),1);
            for i = 1:length(futures)
                tradingCode = getTradingCodeByOrgid(orgIDs(i));
                windcode = tradingCode{1,1};
                exchange = tradingCode{1,2};
                if exchange == 4 || exchange == 5 ||...
                        exchange == 6 || exchange == 7
                    futures{i} = windcode2contract(windcode);
                else
                    error('cQuantTrader:invalid or unsupported exchange')
                end
            end
            obj.Contracts = futures;
            obj.AccountSerialID = 1;
            obj.TradingPlatform = cTradingPlatform;
        end
        %
    end
    
end

