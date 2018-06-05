function [obj] = clear_array(obj)
% cleae elements in cArray with the cArray obj kept
    try
        obj.latest_ = 0;
%         obj.node_ = [];
        classname = class(obj.node_);
        eval(['obj.node_ = ' classname ';']);
    catch e
        fprintf('cArray:clear_array:%s\n',e.message);
    end
end