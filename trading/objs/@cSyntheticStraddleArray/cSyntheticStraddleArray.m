classdef cSyntheticStraddleArray < cArray
    properties(Abstract = false)
        %note:
        %we cannot use node_@cSyntheticStraddle since the base class cArray has no
        %restriction in defining node_
        %all restrictions shall be implemented only in set methods
        %with the correct elemement class initialized
        node_ = cSyntheticStraddle;
    end
    
    methods
        function set.node_(obj, node)
            if isa(node, 'cSyntheticStraddle')
                obj.node_ = node;
            else
                error('cSyntheticStraddleArray��invalid node input');
            end
        end
    end
end