function [] = charlotte_print_kelly(k1,k2)
if isempty(k1)
    k1 = -9.99;
end
if isempty(k2)
    k2 = -9.99;
end

if k1 >= 0 && k2 >= 0
    fprintf('\tk:%6.1f%%\t%6.1f%%\n',100*k1,100*k2);
elseif k1 < 0 && k2 > 0
    fprintf('\tk:%6.1f%%\t%6.1f%%\n',100*k1,100*k2);
elseif k1 >= 0 && k2 < 0
    fprintf('\tk:%6.1f%%\t%6.1f%%\n',100*k1,100*k2);
else
    fprintf('\tk:%6.1f%%\t%6.1f%%\n',100*k1,100*k2);
end
end