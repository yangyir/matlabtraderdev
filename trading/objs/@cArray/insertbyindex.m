function [obj] = insertbyindex(obj, i, onenode_)

    lat = obj.latest_;
    if i<=0
        error('cArray:insertbyindex:invalid non-positive index input');
    end

    if i> lat % 
        warning('cArray:insertbyindex:input index exceed size of array');
        obj.push(onenode_);
    else
        obj.node_(i+1:lat+1) = obj.node_(i:lat);
        obj.node_(i) = onenode_;                
        obj.latest_ = lat + 1;
    end

end