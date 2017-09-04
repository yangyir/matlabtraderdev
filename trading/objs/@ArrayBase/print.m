function [txt] = print(obj)
% PRINT 逐一（行）打印node，需要定义了node.println方法
% [txt] = print(obj)
% --------------------------
% 程刚，20160210

txt = '';
nd = obj.node;
L = length(nd);
for i =1:L
    txtln = nd(i).println;
    txt = sprintf('%s%s', txt, txtln);
end

if nargout == 0
    disp(txt);
end
end

