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
        ds = cBloomberg;
    end
%     if nargin < 2
    if isempty(instrument)
        for i = 1:ns
            date2 = floor(mdefut.candles_{i}(1,1));
            count = 1;
            date1 = date2;
            while count <= nop
                date1 = businessdate(date1,-1);
                count = count + 1;
            end
            date2str = [datestr(date2,'yyyy-mm-dd'),' 08:59:00'];
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
                    candles = ds.intradaybar(instruments{i},datestr(buckets(1)),datestr(buckets(idx+1)),mdefut.candle_freq_(i),'trade');
                    for j = 1:size(candles,1)
                        mdefut.candles_{i}(j,2:end) = candles(j,2:end);
                    end
                end
            end

        end
        ret = true;
        ds.close;
        return
    end

    if ~isa(instrument,'cInstrument'), error('cMDEFut:initcandles:invalid instrument input');end
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
            date2str = [datestr(date2,'yyyy-mm-dd'),' 08:59:00'];
            date1str = [datestr(date1,'yyyy-mm-dd'),' 09:00:00'];
            candles = ds.intradaybar(instruments{i},date1str,date2str,mdefut.candle_freq_(i),'trade');
            mdefut.hist_candles_{i} = candles;
            t = now;
            buckets = mdefut.candles_{i}(:,1);
            idx = find(buckets<=t);
            if isempty(idx)
                %todo:here we shall return an error
            else
                idx = idx(end);
                candles = ds.intradaybar(instruments{i},datestr(buckets(1)),datestr(buckets(idx)),mdefut.candle_freq_(i),'trade');
                for j = 1:size(candles,1)
                    mdefut.candles_{i}(j,2:end) = candles(j,2:end);
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