function [] = registerinstrument(obj,instrument)
%a cMDEOpt function
    if ~isa(instrument,'cInstrument')
        instrument = code2instrument(instrument);
    end
        
    codestr = instrument.code_ctp;
    [isopt,~,~,underlierstr] = isoptchar(codestr);
    if ~isopt, return; end
    
    underlier = code2instrument(underlierstr);
    if isempty(obj.underlier_)
        obj.underlier_ = underlier;
        obj.ticksquick_ = [obj.ticksquick_;zeros(1,4)];
        obj.macdlead_ = [obj.macdlead_;12];
        obj.macdlag_ = [obj.macdlag_;26];
        obj.macdavg_ = [obj.macdavg_;9];
        obj.tdsqlag_ = [obj.tdsqlag_;4];
        obj.tdsqconsecutive_ = [obj.tdsqconsecutive_;9];
        obj.nfractals_ = [obj.nfractals_;6];
        obj.candle_freq_ = [obj.candle_freq_;1];
        obj.newset_ = [obj.newset_;0];
        obj.candles_count_ = [obj.candles_count_;0];
        obj.candles4save_count_ = [obj.candles4save_count_;0];
        obj.ticks_count_ = [obj.ticks_count_;0];
        %
        if strcmpi(obj.mode_,'realtime')
            hh = hour(now);
            if hh < 2
                cobdate = today - 1;
            elseif hh == 2
                mm = minute(now);
                if mm > 30
                    cobdate = today;
                else
                    cobdate = today - 1;
                end
            else
                cobdate = today;
            end
        else
            cobdate = obj.replay_date1_;
        end
        buckets = getintradaybuckets2('date',cobdate,...
                    'frequency',[num2str(obj.candle_freq_(end)),'m'],...
                    'tradinghours',underlier.trading_hours,...
                    'tradingbreak',underlier.trading_break);
        candle = [buckets,zeros(size(buckets,1),4)];
        obj.candles_ = {candle};
        buckets4save = getintradaybuckets2('date',cobdate,...
                    'frequency','1m',...
                    'tradinghours',underlier.trading_hours,...
                    'tradingbreak',underlier.trading_break);
        candle4save = [buckets4save,zeros(size(buckets4save,1),4)];
        obj.candles4save_ = {candle4save};
        obj.categories_ = getfutcategory(underlier);
        filename = [underlierstr,'_daily.txt'];
        dailypx = cDataFileIO.loadDataFromTxtFile(filename);
        idx = find(dailypx(:,1) <= cobdate,1,'last');
        if ~isempty(idx)
            obj.lastclose_ = [obj.lastclose_;dailypx(idx,5)];
        end
        %
        blankstr = ' ';
        nintervals = size(underlier.break_interval,1);
        datenum_open = zeros(nintervals,1);
        datenum_close = zeros(nintervals,1);
        datestr_start = datestr(floor(candle(1,1)));
        datestr_end = datestr(floor(candle(end,1)));
        for i = 1:nintervals
            datenum_open(i,1) = datenum([datestr_start,blankstr,underlier.break_interval{i,1}]);
            if obj.categories_ ~= 5
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
            obj.datenum_open_ = datenum_open;
            obj.datenum_close_ = datenum_close;
        end
        %
        if obj.savetick_
            n = 1e5;%note this size sall be enough for day trading
            obj.ticks_ = {zeros(n,2)};
        end
    else
        if ~strcmpi(obj.underlier_.code_ctp,underlierstr)
            error('ERROR:%s:registerinstrument:only option on %s can be registed...\n',class(obj),underlierstr)
        end
    end
    %
    if ~obj.qms_.instruments_.hasinstrument(underlier)
        obj.qms_.registerinstrument(underlier);
    end
    
    obj.qms_.registerinstrument(instrument);
    if isempty(obj.options_)
        obj.options_ = cInstrumentArray;
    end
    
    if ~obj.options_.hasinstrument(instrument)
        obj.options_.addinstrument(instrument);
        obj.ticksquick_ = [obj.ticksquick_;zeros(1,4)];
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
        %candle tenors shall be the same as the underlier
        obj.candles_ = [obj.candles_;obj.candles_{1}];
        obj.candles4save_ = [obj.candles4save_;obj.candles4save_{1}];
        if obj.savetick_
            obj.ticks_ = [obj.ticks_;obj.ticks_{1}];
        end
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
        %
        obj.macdlead_ = [obj.macdlead_;12];
        obj.macdlag_ = [obj.macdlag_;26];
        obj.macdavg_ = [obj.macdavg_;9];
        obj.tdsqlag_ = [obj.tdsqlag_;4];
        obj.tdsqconsecutive_ = [obj.tdsqconsecutive_;9];
        obj.nfractals_ = [obj.nfractals_;6];
        obj.candle_freq_ = [obj.candle_freq_;1];
        obj.newset_ = [obj.newset_;0];
        obj.candles_count_ = [obj.candles_count_;0];
        obj.candles4save_count_ = [obj.candles4save_count_;0];
        obj.ticks_count_ = [obj.ticks_count_;0];
        if strcmpi(obj.mode_,'realtime')
            hh = hour(now);
            if hh < 2
                cobdate = today - 1;
            elseif hh == 2
                mm = minute(now);
                if mm > 30
                    cobdate = today;
                else
                    cobdate = today - 1;
                end
            else
                cobdate = today;
            end
        else
            cobdate = obj.replay_date1_;
        end
        filename = [instrument.code_ctp,'_daily.txt'];
        dailypx = cDataFileIO.loadDataFromTxtFile(filename);
        idx = find(dailypx(:,1) <= cobdate,1,'last');
        if ~isempty(idx)
            obj.lastclose_ = [obj.lastclose_;dailypx(idx,5)];
        end
    end
    
    % compute num21_00_00_; num21_00_0_5_;num00_00_00_;num00_00_0_5_ if it
    % is required
    
    if obj.categories_ > 3
        datestr_start = datestr(floor(obj.candles4save_{1}(1,1)));
        obj.num21_00_00_ = datenum([datestr_start,' 21:00:00']);
        obj.num21_00_0_5_ = datenum([datestr_start,' 21:00:0.5']);
    end
    if obj.categories_ == 5
        datestr_end = datestr(floor(obj.candles4save_{1}(end,1)));
        obj.num00_00_00_ = datenum([datestr_end,' 00:00:00']);
        obj.num00_00_0_5_ = datenum([datestr_end,' 00:00:0.5']);
    end
    
end
%end of registerinstrument