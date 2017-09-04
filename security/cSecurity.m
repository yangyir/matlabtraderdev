classdef cSecurity < cObj
    %base class for security object
    properties (Access = public)
        SecurityName
    end
    
    methods %SET/GET methods
        function secname = get.SecurityName(obj)
            secname = obj.SecurityName;
        end
                        
        function obj = set.SecurityName(obj,secname)
            obj.SecurityName = secname; 
        end
        
    end
	
end