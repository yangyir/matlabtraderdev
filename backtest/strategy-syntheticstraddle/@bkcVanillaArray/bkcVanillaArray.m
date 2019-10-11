classdef bkcVanillaArray < cArray
    properties(Abstract = false)
        %note:
        %restriction in defining node_
        %all restrictions shall be implemented only in set methods
        %with the correct elemement class initialized
        node_ = bkcVanilla;
    end
    
    methods
        function set.node_(obj, node)
            if isa(node, 'bkcVanilla')
                obj.node_ = node;
            else
                error('bkcVanillaArray£ºinvalid node input');
            end
        end
    end
    %
    %
    methods
        premium = premiumused(obj,datein,varargin)
        %
        premium = getproceeds(obj,datein,varargin)
        %
        n = countlivestraddle(obj,datein)
        output = unwindinfo(obj,varargin)
        [pv,margin,delta] = runningpvsynthetic(obj,varargin)
        
    end
    
end