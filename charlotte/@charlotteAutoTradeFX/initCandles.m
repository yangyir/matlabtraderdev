function [] = initCandles(obj)
% a charlotteAutoTradeFX method
    try
        filenames = charlotte_select_fx_files;
        ncodes = size(obj.codes_,1);
        for i = 1:ncodes
            data =  readtable(filenames{i},'readvariablenames',1);
            idxlast = find(~isnan(data.Close),1,'last');
            % for save memory, we cut the latest 220 candles
            if idxlast >= 220
                idxfirst = idxlast - 219;
            else
                idxfirst = 1;
            end
            
            candleopen = data.Open(idxfirst:idxlast);
            candlehigh = data.High(idxfirst:idxlast);
            candlelow = data.Low(idxfirst:idxlast);
            candleclose = data.Close(idxfirst:idxlast);
            candledate = data.Date(idxfirst:idxlast);
            candletime = data.Time(idxfirst:idxlast);
            n = size(candledate,1);
            candledatetime = zeros(n,1);
            for j = 1:n
                thisbardate = candledate{j};
                thisbartime = candletime{j};
                thisbardatestr = [thisbardate(1:4),thisbardate(6:7),thisbardate(9:10)];
                candledatetime(j) = datenum([thisbardatestr,' ',thisbartime],'yyyymmdd HH:MM');
            end
            obj.candles_{i} = [candledatetime,candleopen,candlehigh,candlelow,candleclose];
        end
    catch ME
        % error happened and event is triggered
        notify(obj, 'ErrorOccurred', ...
            charlotteErrorEventData(ME.message));
    end
%Note:here the processor still has no idea of what frequencies are used for
%trading
end