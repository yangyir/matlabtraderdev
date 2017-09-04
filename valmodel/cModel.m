classdef cModel < cObj
    %base class for option pricing/risk management model
    properties (Access = public)
        CalcIntrinsic
        ExtraResults
        ModelName
    end
    
    methods %SET/GET methods
        function calcintrinsic = get.CalcIntrinsic(obj)
            calcintrinsic = obj.CalcIntrinsic;
        end
        
        function name = get.ModelName(obj)
            name = obj.ModelName;
        end
        
        function extraresults = get.ExtraResults(obj)
            extraresults = obj.ExtraResults;
        end
                
        function obj = set.CalcIntrinsic(obj,calcintrinsic)
            obj.CalcIntrinsic = calcintrinsic; 
        end
        
        function obj = set.ModelName(obj,name)
            obj.ModelName = name;
        end
        
        function obj = set.ExtraResults(obj,extraresults)
            obj.ExtraResults = extraresults;
        end
        
    end
	
end