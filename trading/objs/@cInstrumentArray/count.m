function n = count(obj)
    if ~obj.isvalid
        n = 0;
    else
        if isempty(obj)
            n = 0;
        else
            n = length(obj.list_);
        end
    end
end
    %end of count