function [] = bkf_printtrades_tdsq( tradesin )
%BKF_PRINTTRADES_TDSQ Summary of this function goes here
%   Detailed explanation goes here
    totalpnl = 0;
    for i = 1:tradesin.latest_
        if ~isempty(tradesin.node_(i).closepnl_)
            pnl_i = tradesin.node_(i).closepnl_;
        else
            pnl_i = tradesin.node_(i).runningpnl_;
            if isempty(pnl_i), pnl_i = 0;end
        end
    
        fprintf('%2d\t%2d\t%s\t%5d\n',tradesin.node_(i).id_,...
            tradesin.node_(i).opendirection_*tradesin.node_(i).openvolume_,...
            datestr(tradesin.node_(i).opendatetime2_,'yy-mm-dd HH:MM'),...
            pnl_i);
        totalpnl = totalpnl + pnl_i;
    end
    
    fprintf('totalpnl:%s\n',num2str(totalpnl));

end
