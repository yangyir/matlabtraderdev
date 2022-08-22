function data = history(obj,instrument,fields,fromdate,todate)
    %cWind not implemented yet
    if isa(instrument,'cInstrument')
        if isa(instrument,'cFX')
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument.code_wind,fields,fromdate,todate,'TradingCalendar=AMEX');
        else
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument.code_wind,fields,fromdate,todate,'PriceAdj=F');
        end
        data = [wtime,wdata];
    else
        if strcmpi(instrument,'SPTAUUSDOZ.IDC')
            %gold
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=LSE');
        elseif strcmpi(instrument,'B00.IPE')
            %brent crude
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=IPE');
        elseif strcmpi(instrument,'CA03ME.LME')
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=LME');
        elseif strcmpi(instrument,'10YRNOTE.GBM') || ...
                strcmpi(instrument,'USDX.FX') || ...
                strcmpi(instrument,'EURUSD.FX') || ...
                strcmpi(instrument,'USDJPY.FX') || ...
                strcmpi(instrument,'GBPUSD.FX') || ...
                strcmpi(instrument,'AUDUSD.FX') || ...
                strcmpi(instrument,'SPX.GI')
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=AMEX');    
        else
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F');
        end
        data = [wtime,wdata];
    end
end
%end of history