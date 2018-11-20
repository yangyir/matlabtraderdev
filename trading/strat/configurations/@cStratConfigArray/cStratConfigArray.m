classdef cStratConfigArray < cArray
    properties(Abstract = false)
        %note:
        %we cannot use node_@cStratConfig since the base class cArray has no
        %restriction in defining node_
        %all restrictions shall be implemented only in set methods
        %with the correct elemement class initialized
        node_ = cStratConfig;
    end
    
    methods
        function set.node_(obj, node)
            if isa(node, 'cStratConfig')
                obj.node_ = node;
            else
                error('cStratConfigArray£ºinvalid node input');
            end
        end
    end
    
    methods
         function new = copy(obj)
            % copy() is for deep copy case.
            new = feval(class(obj));
            % copy all non-hidden properties
            p = properties(obj);
            for i = 1:length(p)
                new.(p{i}) = obj.(p{i});
            end
         end     
    end
    
    methods 
        [ret] = loadfromfile(obj,varargin)
        [ret] = hasconfig(obj,config)
        [config] = getconfig(obj,varargin)
        [val] = getconfigvalue(obj,varargin)
        [ret] = totxt(obj,varargin)
    end
    
    methods (Static = true)
        [] = demo()
    end
    
end