savedailybarfrombloomberg2(conn,'510300 CH Equity');
%
% for i = 1:length(opt300_c_feb)
%     savedailybarfrombloomberg2(conn,opt300_c_feb{i});
%     savedailybarfrombloomberg2(conn,opt300_p_feb{i});
% end
% 
% for i = 1:length(opt300_c_mar)
%     savedailybarfrombloomberg2(conn,opt300_c_mar{i});
%     savedailybarfrombloomberg2(conn,opt300_p_mar{i});
% end
%
for i = 1:length(opt300_c_apr)
    savedailybarfrombloomberg2(conn,opt300_c_apr{i});
    savedailybarfrombloomberg2(conn,opt300_p_apr{i});
end
%
for i = 1:length(opt300_c_may)
    savedailybarfrombloomberg2(conn,opt300_c_may{i});
    savedailybarfrombloomberg2(conn,opt300_p_may{i});
end
%
for i = 1:length(opt300_c_jun)
    savedailybarfrombloomberg2(conn,opt300_c_jun{i});
    savedailybarfrombloomberg2(conn,opt300_p_jun{i});
end
%
backhome;