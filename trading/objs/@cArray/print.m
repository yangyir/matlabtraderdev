function [txt] = print(obj)
%note:println method shall be defined in derived class
    txt = '';
    nd = obj.node_;
    L = length(nd);
    for i =1:L
        txtln = nd(i).println;
        txt = sprintf('%s%s', txt, txtln);
    end

    if nargout == 0
        disp(txt);
    end
end