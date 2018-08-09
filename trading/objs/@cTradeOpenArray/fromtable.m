function [obj] = fromtable(obj,table)
    if ~iscell(table), error('cTradeOpenArray:fromtable:invalid table input');end
    
    nodeClassName = class(obj.node_);
    
    [nrows, ~] = size(table);
    eval( ['obj.node_ = ' nodeClassName ';' ] );
    for i = 2:nrows
        eval( ['anode = ', nodeClassName, ';'] );
        anode = anode.table2tradeopen(table(1,:),table(i,:));
        %
        obj.node_(i-1) = anode;
        obj.latest_ = i-1;
    end
    
end