classdef cPoint < handle
    properties
        x@double
        y@double
    end
    
    methods
        function obj = cPoint(x,y)
            if nargin == 0
                obj.x = NaN;
                obj.y = NaN;
                return
            end
                
            obj.x = x;
            obj.y = y;
        end
        
        function d = distance(obj,pointin)
            if ~isa(pointin,'cPoint')
                error('cPoint:distance:invalid point input')
            end
            x2 = pointin.x;
            y2 = pointin.y;
            x1 = obj.x;
            y1 = obj.y;
            d = sqrt((x1-x2)*(x1-x2)+(y1-y2)*(y1-y2));
        end
        
    end
end