function [] = charlotte_print_kelly(k1,k2)
if isempty(k1) || k1 == -inf
    k1 = -9.99;
end
if isempty(k2) || k2 == -inf
    k2 = -9.99;
end

if k1 >= 0 && k2 >= 0
    fprintf('\tkold:%6.1f%%\tknew:%6.1f%%\n',100*k1,100*k2);
elseif k1 < 0 && k2 > 0
    fprintf('\tkold:%6.1f%%\tknew:%6.1f%%\n',100*k1,100*k2);
elseif k1 >= 0 && k2 < 0
    fprintf('\tkold:%6.1f%%\tknew:%6.1f%%\n',100*k1,100*k2);
else
    fprintf('\tkold:%6.1f%%\tknew:%6.1f%%\n',100*k1,100*k2);
end
end