classdef cStrategyGenericVanilla < cStrategy
    % trading strategy which replicate the the synthetic vanilla portfolios
    % which are defined via class cVanillaPortfoli as a property of the
    % strategy class itself
    properties
        VanillaPortfolio   %cVanillaPortfolio
    end
    
    methods
        function obj = cStrategyGenericVanilla(varargin)
            obj = init(obj,varargin{:});
        end
        %end of constructor
    end
    
    %methods for modifying the synthetic vanilla portfolio
    methods (Access = public)
        function obj = add(obj,vanillas)
            if iscell(vanillas)
                for i = 1:length(vanillas)
                    obj = obj.addvanilla(vanillas{i});
                end
            else
                obj = obj.addvanilla(vanillas);
            end
        end
        %end of 'add' function
        
        
        function obj = removevanilla(obj,vanilla)
            vp = obj.VanillaPortfolio;
            vp = vp.remove(vanilla);
            obj.VanillaPortfolio = vp;
        end
        %end of removevanilla function
        
        function obj = setuseflag(obj,idx,use)
            vp = obj.VanillaPortfolio;
            vp = vp.setuseflag(idx,use);
            obj.VanillaPortfolio = vp;
        end
        %end of setuseflag function
        
        function [bcodes,symbols] = uniqueunderlier(obj)
            vp = obj.VanillaPortfolio;
            [bcodes,symbols] = vp.uniqueunderlier;
        end
        %end of uniqueunderlier function
        
    end
    %end of methods for modifying the syntheric vanilla portfolio
    
    %methods for generate orders
    methods (Access = public)
        function order = genorder(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('UnderlierPrice',{},@istruct);
            p.addParameter('UnderlierVol',{},@(x)validateattributes(x,{'cMarketVol','struct'},{},'UnderlierVol'));
            p.addParameter('TradingPlatform',{},@(x)validateattributes(x,{'cTradingPlatform'},{},'TradingPlatform'));
            p.addParameter('LiquidityAdjustment',0,@isnumeric);
            p.parse(varargin{:});
            
            
        end
        %end of genorder
        
    end
    
    methods (Access = private)
        function obj = init(obj,varargin)
            p = inputParser;
            p.CaseSensitive = false;p.KeepUnmatched = true;
            p.addParameter('StrategyID',1,@isnumeric);
            p.addParameter('InitialBalance',[],@isnumeric);
            p.addParameter('MaxMarginRatio',0.7,@isnumeric);
            p.addParameter('StopLossRatio',0.1,@isnumeric);
            p.parse(varargin{:});
            obj.StrategyID = p.Results.StrategyID;
            obj.InitialBalance = p.Results.InitialBalance;
            obj.MaxMarginRatio = p.Results.MaxMarginRatio;
            obj.StopLossRatio = p.Results.StopLossRatio;
            %
            obj.VanillaPortfolio = cVanillaPortfolio('vp');
            
        end
        %end of 'init' function
        
        function obj = addvanilla(obj,vanilla)
            vp = obj.VanillaPortfolio;
            vp = vp.add(vanilla);
            obj.VanillaPortfolio = vp;
            instruments = vp.instruments;
            obj = obj.registerinstruments(instruments);
        end
        %end of addvanilla function
        
    end
end