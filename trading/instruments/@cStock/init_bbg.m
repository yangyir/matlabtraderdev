function [] = init_bbg(obj,conn)
%cStock
    if isa(obj, 'cStock')
        error('cStock:init_bbg:internal error')
    end
    
    variablenotused(conn);
    fprintf('cStock:init_bbg:not implemented\n');
    
end

