classdef cVol < cObj
    %base class for volatility object
    properties (Access = public)
        AssetName
        VolName
        VolType
    end
    
    methods %SET/GET methods
        function assetname = get.AssetName(obj)
            assetname = obj.AssetName;
        end
        
        function volname = get.VolName(obj)
            volname = obj.VolName;
        end
        
        function voltype = get.VolType(obj)
            voltype = obj.VolType;
        end
        
        function obj = set.AssetName(obj,assetname)
            obj.AssetName = assetname;
        end
                
        function obj = set.VolName(obj,volname)
            obj.VolName = volname; 
        end
        
        function obj = set.VolType(obj,voltype)
            obj.VolType = voltype;
        end
        

        
    end
	
end