function [] = init(obj,name)
%cTrader
    if ~ischar(name), error('cTrader:invalid trader name input');end
    obj.name_ = name;
    
end