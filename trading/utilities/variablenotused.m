function [] = variablenotused(v)
    if exist(v,'variable'), return; end
end