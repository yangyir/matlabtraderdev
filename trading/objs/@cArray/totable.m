function [ table, flds ] = totable(obj, start_pos, end_pos)
    if ~exist('start_pos', 'var')
        start_pos = 1;
    end

    if ~exist('end_pos', 'var')
        end_pos = start_pos + length(obj.node) - 1; 
    end

    nodes = obj.node(start_pos : end_pos);
    N = length(nodes);

    flds = properties( nodes );
    F = length(flds);

    table = cell(N+1, F);
    
    for col = 1:F
        f = flds{col};
        table{1, col} = f;
    end


    for lin = 1:N
        for col = 1:F
            n = nodes(lin);
            f = flds{col};
            table{lin+1, col} = n.(f);
        end
    end

    obj.table   = table;
    obj.headers = flds;

end