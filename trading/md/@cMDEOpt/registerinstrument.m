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
        pnlriskoutput = pnlriskbreakdown1(instrument,getlastbusinessdate);
        obj.deltacarryyesterday_ = [obj.deltacarryyesterday_;pnlriskoutput.deltacarry];
        obj.gammacarryyesterday_ = [obj.deltacarryyesterday_;pnlriskoutput.gammacarry];
        obj.vegacarryyesterday_ = [obj.vegacarryyesterday_;pnlriskoutput.vegacarry];
        obj.thetacarryyesterday_ = [obj.thetacarryyesterday_;pnlriskoutput.thetacarry];
        obj.impvolcarryyesterday_ = [obj.impvolcarryyesterday_;pnlriskoutput.iv2];
        obj.pvcarryyesterday_ = [obj.pvcarryyesterday_;pnlriskoutput.premium2];
    end
    
    if isempty(obj.underliers_)
        obj.underliers_ = cInstrumentArray;
    end

    underlier = cFutures(underlierstr);
    underlier.loadinfo([underlierstr,'_info.txt']);
    
    %doing nothing if the underlier is already in place
    if obj.underliers_.hasinstrument(underlier), return; end
    
    obj.underliers_.addinstrument(underlier);
    nu = obj.underliers_.count;
    underliers = obj.underliers_.getinstrument;
    if isempty(obj.candles_)
        obj.candles_ = cell(nu,1);
        for i = 1:nu
            fut = underliers{i};
            %by default, we use 15m candles for the underlier
            buckets = getintradaybuckets2('date',cobdate,...
                'frequency','15m',...
                'tradinghours',fut.trading_hours,...
                'tradingbreak',fut.trading_break);
            candle_ = [buckets,zeros(size(buckets,1),4)];
            obj.candles_{i} = candle_;
        end
    else
        nu_ = size(obj.candles_,1);
        candles = cell(nu,1);
        if nu_ ~= nu
            for i = 1:nu_, candles{i} = obj.candles_{i};end
            for i = nu_+1:nu
                fut = underliers{i};
                buckets = getintradaybuckets2('date',cobdate,...
                    'frequency','15m',...
                    'tradinghours',fut.trading_hours,...
                    'tradingbreak',fut.trading_break);
                candles{i} = [buckets,zeros(size(buckets,1),4)];
            end
            obj.candles_ = candles;
        end
    end
    
        category = getfutcategory(instrument);
        obj.categories_ = [obj.categories_,category];
    
    blankstr = ' ';
    if isempty(obj.datenum_open_)
        obj.datenum_open_ = cell(nu,1);
        obj.datenum_close_ = cell(nu,1);
        nintervals = size(instrument.break_interval,1);
        datenum_open = zeros(nintervals,1);
        datenum_close = zeros(nintervals,1);
        datestr_start = datestr(floor(obj.candles4save_{nu}(1,1)));
        datestr_end = datestr(floor(obj.candles4save_{nu}(end,1)));
        for j = 1:nintervals
            datenum_open(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,1}]);
            if category ~= 5
                datenum_close(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
            else
                if j == nintervals
                    datenum_close(j,1) = datenum([datestr_end,blankstr,instrument.break_interval{j,2}]);
                else
                    datenum_close(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
                end
            end
        end
        obj.datenum_open_{nu,1} = datenum_open;
        obj.datenum_close_{nu,1} = datenum_close;
    else
        nu_ = size(obj.datenum_open_,1);
        if nu_ ~= nu
            datenum_open = cell(nu,1);
            datenum_close = cell(nu,1);
            for i = 1:nu_
                datenum_open{i} = obj.datenum_open_{i};
                datenum_close{i} = obj.datenum_close_{i};
            end
            nintervals = size(instrument.break_interval,1);
            datenum_open_new = zeros(nintervals,1);
            datenum_close_new = zeros(nintervals,1);
            blankstr = ' ';
            datestr_start = datestr(floor(obj.candles4save_{nu}(1,1)));
            datestr_end = datestr(floor(obj.candles4save_{nu}(end,1)));
            for j = 1:nintervals
                datenum_open_new(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,1}]);
                if category ~= 5
                    datenum_close_new(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
                else
                    if j == nintervals
                        datenum_close_new(j,1) = datenum([datestr_end,blankstr,instrument.break_interval{j,2}]);
                    else
                        datenum_close_new(j,1) = datenum([datestr_start,blankstr,instrument.break_interval{j,2}]);
                    end
                end
            end
            datenum_open{nu,1} = datenum_open_new;
            datenum_close{nu,1} = datenum_close_new;
            obj.datenum_open_ = datenum_open;
            obj.datenum_close_ = datenum_close;
        end
    end

end
%end of registerinstrument