function [respmax,varmax,resp,var] = bkfunc_paramsweep(fun,range)

    %% Generate expression for ndgrid
    N = length(range);
    varmax = zeros(N,1);
    if N == 1
        var = range;
    else
        var = cell(1,N);
        [var{:}] = ndgrid(range{:});
    end
    %% Perform parameter sweep
    sz = size(var{1});
    for i = 1:N
        var{i} = var{i}(:);
    end
    resp = fun(cell2mat(var));
    
    %% Find maximum value and location
    [respmax,idx]   = max(resp);
    for i = 1:N
        varmax(i) = var{i}(idx);
    end
    
    %% Reshape output only if requested
    if nargout > 2
        resp = reshape(resp,sz);
        for i = 1:N
            var{i} = reshape(var{i},sz);
        end
    end %if