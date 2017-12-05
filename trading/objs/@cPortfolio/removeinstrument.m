function [] = removeinstrument(cport,instrument)
    [bool,idx] = cport.hasinstrument(instrument);
    if ~bool
        %a warning or error message shall be issued
        return;
    else
        n = cport.count;
        if n == 1
            cport.instrument_list = {};
            cport.instrument_avgcost = [];
            cport.instrument_volume = [];
            cport.instrument_volume_today = [];
            cport.pos_list_ = {};
        else
            list_ = cell(n-1,1);
            c_ = zeros(n-1,1);
            v_ = zeros(n-1,1);
            vtoday_ = zeros(n-1,1);
            pos_list = cell(n-1,1);
            for i = 1:idx-1
                list_{i,1} = cport.instrument_list{i,1};
                c_(i,1) = cport.instrument_avgcost(i,1);
                v_(i,1) = cport.instrument_volume(i,1);
                vtoday_(i,1) = cport.instrument_volume_today(i,1);
                pos_list{i,1} = cport.pos_list_{i,1};
            end
            for i = idx+1:n
                list_{i-1,1} = cport.instrument_list{i,1};
                c_(i-1,1) = cport.instrument_avgcost(i,1);
                v_(i-1,1) = cport.instrument_volume(i,1);
                vtoday_(i-1,1) = cport.instrument_volume_today(i,1);
                pos_list{i-1,1} = cport.pos_list_{i,1};
            end
            cport.instrument_list = list_;
            cport.instrument_avgcost = c_;
            cport.instrument_volume = v_;
            cport.instrument_volume_today = vtoday_;
            cport.pos_list_ = pos_list;
        end

    end
end
%end of removeinstrument