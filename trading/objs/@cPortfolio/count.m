function n = count(cPort)
    if isempty(cPort)
        n = 0;
    else
        n = length(cPort.pos_list_);
    end
end
%end of count