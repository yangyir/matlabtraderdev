savedailybarfrombloomberg2(conn,'510050 CH Equity');
%
for i = 1:length(opt_c_feb)
    savedailybarfrombloomberg2(conn,opt_c_feb{i});
    savedailybarfrombloomberg2(conn,opt_p_feb{i});
end
%
for i = 1:length(opt_c_mar)
    savedailybarfrombloomberg2(conn,opt_c_mar{i});
    savedailybarfrombloomberg2(conn,opt_p_mar{i});
end
%
for i = 1:length(opt_c_jun)
    savedailybarfrombloomberg2(conn,opt_c_jun{i});
    savedailybarfrombloomberg2(conn,opt_p_jun{i});
end
