function [] = print(obj)
    fprintf('%s ',obj.update_time2);   
    fprintf('trade:%4.1f;',obj.last_trade);
    fprintf('delta:%4.2f;',obj.delta);
    fprintf('gamma:%4.2f;',obj.gamma);
    fprintf('theta:%4.2f;',obj.theta);
    fprintf('vega:%4.2f;',obj.vega);
    fprintf('iv:%4.2f;',obj.impvol);
    fprintf('tau:%2.2f:',obj.opt_business_tau);
    fprintf('instrument:%s\n',obj.code_ctp);

end