function data = history(obj,instrument,fields,fromdate,todate)
    %cWind not implemented yet
    if isa(instrument,'cInstrument')
        [wdata,~,~,wtime] = obj.ds_.wsd(instrument.code_wind,fields,fromdate,todate,'PriceAdj=F');
        data = [wtime,wdata];
    else
        [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F');
        data = [wtime,wdata];
    end
end
%end of history