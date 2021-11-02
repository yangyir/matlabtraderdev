function [] = savedata(obj,varargin)
%cETFWatcher
    n_index = size(obj.codes_index_,1);
    n_sector = size(obj.codes_sector_,1);
    n_stock = size(obj.codes_stock_,1);
    
    %save daily data
    savedailybarfromwind2(obj.conn_,'000001.SH');
    for i = 1:n_index, savedailybarfromwind2(obj.conn_,obj.codes_index_{i}(1:end-3));end
    for i = 1:n_sector, savedailybarfromwind2(obj.conn_,obj.codes_sector_{i}(1:end-3));end
    for i = 1:n_stock, savedailybarfromwind2(obj.conn_,obj.codes_stock_{i}(1:end-3));end
    fprintf('daily bar data saved......\n');
    %
    %save intraday data
    lbd = datestr(getlastbusinessdate,'yyyy-mm-dd');
    for i = 1:n_index, savetickfromwind(obj.conn_,obj.codes_index_{i}(1:end-3),'fromdate',lbd,'todate',lbd);end;fprintf('tick data saved for index......\n');
    for i = 1:n_sector, savetickfromwind(obj.conn_,obj.codes_sector_{i}(1:end-3),'fromdate',lbd,'todate',lbd);end;fprintf('tick data saved for sector......\n');
    for i = 1:n_stock, savetickfromwind(obj.conn_,obj.codes_stock_{i}(1:end-3),'fromdate',lbd,'todate',lbd);end;fprintf('tick data saved for stock......\n');
    %
    %tick2candle 
    for i = 1:n_index,tick2candle(obj.codes_index_{i}(1:end-3),lbd);db_intradayloader4(obj.codes_index_{i}(1:end-3)); end
    for i = 1:n_sector,tick2candle(obj.codes_sector_{i}(1:end-3),lbd);db_intradayloader4(obj.codes_sector_{i}(1:end-3));end
    for i = 1:n_stock,tick2candle(obj.codes_stock_{i}(1:end-3),lbd);db_intradayloader4(obj.codes_stock_{i}(1:end-3));end
    
end