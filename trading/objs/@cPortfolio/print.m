function [] = print(cport)
    n = cport.count;
    if n == 0
        fprintf('empty portfolio....\n');
    end
    for i = 1:n
        instrument_i = cport.instrument_list{i}.code_ctp;
        c_ = cport.instrument_avgcost(i);
        v_ = cport.instrument_volume(i);
        vtoday_ = cport.instrument_volume_today(i);
        fprintf('instrument:%s;avgcost:%4.2f;volume:%d;volumetoday:%d\n',instrument_i,c_,v_,vtoday_);
%         cport.pos_list_{i}.print;

    end
end
%end of print