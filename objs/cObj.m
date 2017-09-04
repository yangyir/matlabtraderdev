classdef cObj
    %base class for all obeject
    properties
        ObjHandle
        ObjType
    end
    
    methods
        %SET/GET methods
        function objHandle = get.ObjHandle(obj)
            objHandle = obj.ObjHandle;
        end
        
        function objType = get.ObjType(obj)
            objType = obj.ObjType;
        end
        
        function obj = set.ObjHandle(obj,objHandle)
            obj.ObjHandle = objHandle;
        end
        
        function obj = set.ObjType(obj,type)
            obj.ObjType = type;
        end
        
    end
    
end