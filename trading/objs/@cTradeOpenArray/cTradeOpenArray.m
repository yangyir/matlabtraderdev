classdef cTradeOpenArray < cArray
    properties(Abstract = false)
        %note:
        %we cannot use node_@cTradeOpen since the base class cArray has no
        %restriction in defining node_
        %all restrictions shall be implemented only in set methods
        %with the correct elemement class initialized
        node_ = cTradeOpen;
    end
    
    methods
        function set.node_(obj, node)
            if isa(node, 'cTradeOpen')
                obj.node_ = node;
            else
                error('cTradeOpenArray£ºinvalid node input');
            end
        end
    end
    
    methods
        new = copy(obj)
        [count] = count(obj)
        [new] = filterbycode(obj,code)
        [postions] = convert2positions(obj)
        [filename] = toexcel(obj, filename, sheetname, start_pos, end_pos);
        [obj] = fromexcel(obj, filename, sheetname); 
        [filename] = totxt(obj, filename, start_pos, end_pos);
        [obj] = fromtxt(obj, filename); 

    end
end