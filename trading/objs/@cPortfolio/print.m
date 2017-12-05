function [] = print(cport)
    n = cport.count;
    if n == 0
        fprintf('empty portfolio....\n');
    end
    for i = 1:n
%         instrument_i = obj.instrument_list{i}.code_ctp;
%         c_ = obj.instrument_avgcost(i);
%         v_ = obj.instrument_volume(i);
%         vtoday_ = obj.instrument_volume_today(i);
%         fprintf('instrument:%s;avgcost:%4.2f;volume:%d;volumetoday:%d\n',instrument_i,c_,v_,vtoday_);
        cport.pos_list_{i}.print;

    end
end
%end of print