savedailybarfrombloomberg2(conn,'510050 CH Equity');
%
% for i = 1:length(opt50_c_feb)
%     savedailybarfrombloomberg2(conn,opt50_c_feb{i});
%     savedailybarfrombloomberg2(conn,opt_p_feb{i});
% end
%
% for i = 1:length(opt50_c_mar)
%     savedailybarfrombloomberg2(conn,opt50_c_mar{i});
%     savedailybarfrombloomberg2(conn,opt50_p_mar{i});
% end
%
% for i = 1:length(opt50_c_apr)
%     savedailybarfrombloomberg2(conn,opt50_c_apr{i});
%     savedailybarfrombloomberg2(conn,opt50_p_apr{i});
% end
%
% for i = 1:length(opt50_c_may)
%     savedailybarfrombloomberg2(conn,opt50_c_may{i});
%     savedailybarfrombloomberg2(conn,opt50_p_may{i});
% end
%
% for i = 1:length(opt50_c_jun)
%     savedailybarfrombloomberg2(conn,opt50_c_jun{i});
%     savedailybarfrombloomberg2(conn,opt50_p_jun{i});
% end
%
% for i = 1:length(opt50_c_jul)
%     savedailybarfrombloomberg2(conn,opt50_c_jul{i});
%     savedailybarfrombloomberg2(conn,opt50_p_jul{i});
% end
%
% for i = 1:length(opt50_c_aug)
%     savedailybarfrombloomberg2(conn,opt50_c_aug{i});
%     savedailybarfrombloomberg2(conn,opt50_p_aug{i});
% end
%
% for i = 1:length(opt50_c_sep)
%     savedailybarfrombloomberg2(conn,opt50_c_sep{i});
%     savedailybarfrombloomberg2(conn,opt50_p_sep{i});
% end
%
% for i = 1:length(opt50_c_oct)
%     savedailybarfrombloomberg2(conn,opt50_c_oct{i});
%     savedailybarfrombloomberg2(conn,opt50_p_oct{i});
% end
%
% for i = 1:length(opt50_c_nov)
%     savedailybarfrombloomberg2(conn,opt50_c_nov{i});
%     savedailybarfrombloomberg2(conn,opt50_p_nov{i});
% end
%
for i = 1:length(opt50_c_dec)
    savedailybarfrombloomberg2(conn,opt50_c_dec{i});
    savedailybarfrombloomberg2(conn,opt50_p_dec{i});
end
%
for i = 1:length(opt50_c_jan)
    savedailybarfrombloomberg2(conn,opt50_c_jan{i});
    savedailybarfrombloomberg2(conn,opt50_p_jan{i});
end
backhome;
