classdef bkcStraddleArray < cArray
    properties(Abstract = false)
        %note:
        %we cannot use node_@cSyntheticStraddle since the base class cArray has no
        %restriction in defining node_
        %all restrictions shall be implemented only in set methods
        %with the correct elemement class initialized
        node_ = bkcStraddle;
    end
    
    methods
        function set.node_(obj, node)
            if isa(node, 'bkcStraddle')
                obj.node_ = node;
            else
                error('bkcStraddleArray£ºinvalid node input');
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
    end
    
end