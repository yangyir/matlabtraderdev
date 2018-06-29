function [ node_ ] = removebyindex(obj, i) 
    try                
        node_ = obj.node_(i);
        obj.node_(i) = [];
        obj.latest_ = obj.latest_ - 1;
    catch e
        fprintf('cArray.removebyindex:%s\n',e.message);
    end

end