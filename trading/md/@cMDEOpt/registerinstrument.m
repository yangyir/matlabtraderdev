function [] = registerinstrument(obj,instrument)
%cMDEOpt
    if ~isa(instrument,'cInstrument')
        instrument = code2instrument(instrument);
    end
        
    codestr = instrument.code_ctp;
    [isopt,~,~,underlierstr] = isoptchar(codestr);
    if ~isopt, return; end

    obj.qms_.registerinstrument(instrument);
    if isempty(obj.options_)
        obj.options_ = cInstrumentArray;
    end
    
    if ~obj.options_.hasinstrument(instrument)
        obj.options_.addinstrument(instrument);
        obj.delta_ = [obj.delta_;0];
        obj.gamma_ = [obj.gamma_;0];
        obj.vega_ = [obj.vega_;0];
        obj.theta_ = [obj.theta_;0];
        obj.impvol_ = [obj.impvol_;0];
        %
        obj.deltacarry_ = [obj.deltacarry_;0];
        obj.gammacarry_ = [obj.gammacarry_;0];
        obj.vegacarry_ = [obj.vegacarry_;0];
        obj.thetacarry_ = [obj.thetacarry_;0];
        %
        try
            pnlriskoutput = pnlriskbreakdown1(instrument,getlastbusinessdate);
            obj.deltacarryyesterday_ = [obj.deltacarryyesterday_;pnlriskoutput.deltacarry];
            obj.gammacarryyesterday_ = [obj.gammacarryyesterday_;pnlriskoutput.gammacarry];
            obj.vegacarryyesterday_ = [obj.vegacarryyesterday_;pnlriskoutput.vegacarry];
            obj.thetacarryyesterday_ = [obj.thetacarryyesterday_;pnlriskoutput.thetacarry];
            obj.impvolcarryyesterday_ = [obj.impvolcarryyesterday_;pnlriskoutput.iv2];
            obj.pvcarryyesterday_ = [obj.pvcarryyesterday_;pnlriskoutput.premium2];
        catch
            obj.deltacarryyesterday_ = [obj.deltacarryyesterday_;0];
            obj.gammacarryyesterday_ = [obj.gammacarryyesterday_;0];
            obj.vegacarryyesterday_ = [obj.vegacarryyesterday_;0];
            obj.thetacarryyesterday_ = [obj.thetacarryyesterday_;0];
            obj.impvolcarryyesterday_ = [obj.impvolcarryyesterday_;0];
            obj.pvcarryyesterday_ = [obj.pvcarryyesterday_;0];
        end
    end
    
    if isempty(obj.underliers_)
        obj.underliers_ = cInstrumentArray;
    end

    underlier = cFutures(underlierstr);
    underlier.loadinfo([underlierstr,'_info.txt']);
    
    
    if ~obj.underliers_.hasinstrument(underlier)
        obj.underliers_.addinstrument(underlier);
        if strcmpi(obj.mode_,'realtime')
            cobdate = today;
        else
            cobdate = obj.replay_date1_;
        end
                
        buckets = getintradaybuckets2('date',cobdate,...
                    'frequency','15m',...
                    'tradinghours',underlier.trading_hours,...
                    'tradingbreak',underlier.trading_break);
        candle = [buckets,zeros(size(buckets,1),4)];
        if isempty(obj.candles_)
            obj.candles_ = cell(1,1);
            obj.candles_{1} = candle;
        else
            nu_ = size(obj.candles_,1);
            candles = cell(nu_+1,1);
            for i = 1:nu_, candles{i} = obj.candles_{i};end
            candles{i}{i+1} = candle;
            obj.candles_ = candles;
        end
        %
        category = getfutcategory(underlier);
        obj.categories_ = [obj.categories_,category];
        %
        blankstr = ' ';
        nintervals = size(underlier.break_interval,1);
        datenum_open = zeros(nintervals,1);
        datenum_close = zeros(nintervals,1);
        datestr_start = datestr(floor(candle(1,1)));
        datestr_end = datestr(floor(candle(end,1)));
        for i = 1:nintervals
            datenum_open(i,1) = datenum([datestr_start,blankstr,underlier.break_interval{i,1}]);
            if category ~= 5
                datenum_close(i,1) = datenum([datestr_start,blankstr,underlier.break_interval{i,2}]);
            else
                if i == nintervals
                    datenum_close(i,1) = datenum([datestr_end,blankstr,underlier.break_interval{i,2}]);
                else
                    datenum_close(i,1) = datenum([datestr_start,blankstr,underlier.break_interval{i,2}]);
                end
            end
        end
        %
        if isempty(obj.datenum_open_)
            obj.datenum_open_ = cell(1,1);
            obj.datenum_close_ = cell(1,1);
            obj.datenum_open_{1,1} = datenum_open;
            obj.datenum_close_{1,1} = datenum_close;
        else
            nu_ = size(obj.datenum_open_,1);
            datenum_open_new = cell(nu_+1,1);
            datenum_close_new = cell(nu_+1,1);
            for i = 1:nu_
                datenum_open_new{i} = obj.datenum_open_{i};
                datenum_close_new{i} = obj.datenum_close_{i};
            end
            datenum_open_new{i+1} = datenum_open;
            datenum_close_new{i+1} = datenum_close;
            obj.datenum_open_ = datenum_open_new;
            obj.datenum_close_ = datenum_close_new;
        end
        
    end
end
%end of registerinstrument