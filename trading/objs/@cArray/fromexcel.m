function [obj] = fromexcel(obj, filename, sheetname)

    nodeClassName = class(obj.node);

    if ~exist('filename', 'var')
        error('cArray:fromexcel:invalid input of filename')
    end

    if ~exist('sheetname', 'var')
        sheetname = nodeClassName;
    end


    % main
    try
        [~, ~, raw] = xlsread(filename, sheetname);
    catch e
        fprintf('%s\n',e.message);
    end

    % 先清空
    eval( ['obj.node = ' nodeClassName ';' ] );

    % 逐一读入
    [L, C] = size(raw);
    for i = 2:L
        eval( ['anode = ', nodeClassName, ';'] );
        for j = 1:C
            try
                fd = raw{1,j};
                anode.(fd) = raw{i,j};
                catch
            end
        end
        obj.node(i-1) = anode;
        obj.latest = i-1;
    end

end
