classdef(Abstract) cArray < handle
    
    properties
        latest_@double   = 0 ;       % 
        capacity_@double = 1000;     %
        issorted_@double = 0;        % ascend 1£¬ descend -1£¬ else 0.
    end
    
    properties(Abstract = true, SetAccess = public, GetAccess = public)
        node_;    
    end
    
    
    properties(Hidden = true)
        headers_@cell;
        table_@cell;
    end
    
    methods
        [obj] = push(obj, node_)
        [obj] = insertbyindex(obj, i, onenode_)
        [obj] = push_front(obj, node_s)
        [node_] = removebyindex(obj, i)
        [obj] = clear_array(obj)
        [ret] = isempty(obj)
        [txt] = print(obj);
        [ table, flds ] = totable(obj, start_pos, end_pos)
        [ filename ] = toexcel(obj, filename, sheetname, start_pos, end_pos);        
        [obj] = fromexcel(obj, filename, sheetname); 
    end
    
end

