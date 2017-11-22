function [] = variablenotused(v)
    try
        if exist(v,'variable'), return; end
    catch
    end
end