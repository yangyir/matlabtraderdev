function [ret] = initcandles(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('NumberofPeriods',10,@isnumeric);
    p.parse(varargin{:});
    nop = p.Results.NumberofPeriods;
    instruments = mdefut.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    if strcmpi(mdefut.mode_,'replay')
        ds = cLocal;
    else
%         ds = cBloomberg;
        ds = cLocal;
    end
    if nargin < 2
%     if isempty(instrument)
        for i = 1:ns
            date2 = floor(mdefut.candles_{i}(1,1));
            count = 1;
            date1 = date2;
            while count <= nop
                date1 = businessdate(date1,-1);
                count = count + 1;
            end
            lastbd = businessdate(date2,-1);
            if strcmpi(instruments{i}.break_interval{end,end},'01:00:00') ||...
                    strcmpi(instruments{i}.break_interval{end,end},'02:30:00')
                date2str = [datestr(lastbd+1,'yyyy-mm-dd'),' ',instruments{i}.break_interval{end,end}];
            else
                date2str = [datestr(lastbd,'yyyy-mm-dd'),' ',instruments{i}.break_interval{end,end}];
            end
            date1str = [datestr(date1,'yyyy-mm-dd'),' 09:00:00'];
            candles = ds.intradaybar(instruments{i},date1str,date2str,mdefut.candle_freq_(i),'trade');
            mdefut.hist_candles_{i} = candles;

            %fill the live candles in case it is missing
            if ~strcmpi(mdefut.mode_,'replay')
                t = now;
                buckets = mdefut.candles_{i}(:,1);
                idx = find(buckets<=t);
                if isempty(idx)
                    %todo:here we shall return an error
                else
                    idx = idx(end);
                    mdefut.candles_count_(i) = idx;
                    if idx < size(buckets,1)
                        hh = hour(t);
                        if hh < 21 && hh >= 16
                            candles = ds.intradaybar(instruments{i},datestr(buckets(1)),datestr(buckets(idx+1)),mdefut.candle_freq_(i),'trade');
                        else
                            try
                                ds2 = cBloomberg;
                                candles = ds2.intradaybar(instruments{i},datestr(buckets(1)),datestr(buckets(idx+1)),mdefut.candle_freq_(i),'trade');
                            catch e
                                fprintf('%s\n',e.message);
                                return
                            end
                        end
                        %
                        if size(candles,1) < idx
                            tmp = [candles;mdefut.candles_{i}(idx+1:end,:)];
                            mdefut.candles_{i} = tmp;
                            mdefut.candles_count_(i) = size(candles,1);
                        else
                            for j = 1:size(candles,1)
                                mdefut.candles_{i}(j,2:end) = candles(j,2:end);
                            end
                            mdefut.candles_count_(i) = idx;
                        end
                    end
                end
            end

        end
        ret = true;
        ds.close;
        return
    end

    if ~isa(instrument,'cInstrument')
        try
            instrument = code2instrument(instrument);
        catch
            error('cMDEFut:initcandles:invalid instrument input')
        end
    end
    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            date2 = floor(mdefut.candles_{i}(1,1));
            %intraday candles for the last 10 business dates
            count = 1;
            date1 = date2;
            while count <= nop
                date1 = businessdate(date1,-1);
                count = count + 1;
            end
            lastbd = businessdate(date2,-1);
            if strcmpi(instruments{i}.break_interval{end,end},'01:00:00') ||...
                    strcmpi(instruments{i}.break_interval{end,end},'02:30:00')
                date2str = [datestr(lastbd+1,'yyyy-mm-dd'),' ',instruments{i}.break_interval{end,end}];
            else
                date2str = [datestr(lastbd,'yyyy-mm-dd'),' ',instruments{i}.break_interval{end,end}];
            end
            date1str = [datestr(date1,'yyyy-mm-dd'),' ',instruments{i}.break_interval{1,1}];
            candles = ds.intradaybar(instruments{i},date1str,date2str,mdefut.candle_freq_(i),'trade');
            mdefut.hist_candles_{i} = candles;
            
            %fill the live candles in case it is missing
            if ~strcmpi(mdefut.mode_,'replay')
                t = now;
                buckets = mdefut.candles_{i}(:,1);
                idx = find(buckets<=t);
                if isempty(idx)
                    %todo:here we shall return an error
                else
                    idx = idx(end);
                    if idx <= size(buckets,1)
                        hh = hour(t);
                        if hh < 21 && hh >= 16
                            candles = ds.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx),'yyyy-mm-dd HH:MM:SS'),mdefut.candle_freq_(i),'trade');
                        else
                            try
                                ds2 = cBloomberg;
                                candles = ds2.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx),'yyyy-mm-dd HH:MM:SS'),mdefut.candle_freq_(i),'trade');
                            catch e
                                fprintf('%s\n',e.message);
                                return
                            end
                        end
                        if size(candles,1) < idx
                            tmp = [candles;mdefut.candles_{i}(idx+1:end,:)];
                            mdefut.candles_{i} = tmp;
                            mdefut.candles_count_(i) = size(candles,1);
                        else
                            for j = 1:size(candles,1)
                                mdefut.candles_{i}(j,2:end) = candles(j,2:end);
                            end
                            mdefut.candles_count_(i) = idx;
                        end
                    end
                end
            end
            ret = true;
            break
        end
    end
    if ~flag, error('cMDEFut:initcandles:instrument not found'); end
    ds.close;
end
%end of initcandles