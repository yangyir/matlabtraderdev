function data = history(obj,instrument,fields,fromdate,todate)
    %cWind not implemented yet
    if isa(instrument,'cInstrument')
        if isa(instrument,'cFX')
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument.code_wind,fields,fromdate,todate,'TradingCalendar=AMEX');
        else
            if strcmpi(instrument.code_wind(1:2),'sc')
                [wdata,~,~,wtime] = obj.ds_.wsd([instrument.code_wind(1:end-3),'INE'],fields,fromdate,todate,'PriceAdj=F');
            else
                [wdata,~,~,wtime] = obj.ds_.wsd(instrument.code_wind,fields,fromdate,todate,'PriceAdj=F');
            end
        end
        data = [wtime,wdata];
    else
        if strcmpi(instrument,'SPTAUUSDOZ.IDC') || strcmpi(instrument,'SPTAGUSDOZ.IDC') || ...
                strcmpi(instrument,'FTSE.GI')
            %gold
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=LSE');
        elseif strcmpi(instrument,'SX5E.DF')
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=FSE');
        elseif strcmpi(instrument,'B00.IPE') || strcmpi(instrument,'B.IPE')
            %brent crude
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=IPE');
        elseif strcmpi(instrument,'S.CBT') || strcmpi(instrument,'C.CBT') || strcmpi(instrument,'W.CBT') 
            %brent crude
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=CME');    
        elseif strcmpi(instrument,'CA03ME.LME') || ...
                strcmpi(instrument,'CA.LME') || ...
                strcmpi(instrument,'AH.LME') || ...
                strcmpi(instrument,'PB.LME') || ...
                strcmpi(instrument,'ZS.LME') || ...
                strcmpi(instrument,'NI.LME') || ...
                strcmpi(instrument,'SN.LME')            
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=LME');
        elseif strcmpi(instrument,'10YRNOTE.GBM') || ...
                strcmpi(instrument,'USDX.FX') || ...
                strcmpi(instrument,'EURUSD.FX') || ...
                strcmpi(instrument,'USDJPY.FX') || ...
                strcmpi(instrument,'GBPUSD.FX') || ...
                strcmpi(instrument,'AUDUSD.FX') || ...
                strcmpi(instrument,'AUDJPY.FX') || ...
                strcmpi(instrument,'SPX.GI') || ...
                strcmpi(instrument,'IXIC.GI')
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F','TradingCalendar=AMEX');    
        else
            [wdata,~,~,wtime] = obj.ds_.wsd(instrument,fields,fromdate,todate,'PriceAdj=F');
        end
        data = [wtime,wdata];
    end
    idx = ~isnan(sum(data,2));
    data = data(idx,:);
end
%end of history