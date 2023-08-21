function [ret] = initcandles(mdefut,instrument,varargin)
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('NumberofPeriods',20,@isnumeric);
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
        for i = 1:ns
            date2 = floor(mdefut.candles_{i}(1,1));
            if mdefut.candle_freq_(i) ~= 1440
                count = 1;
                date1 = date2;
                foldername = [getenv('DATAPATH'),'intradaybar\',instruments{i}.code_ctp];
                filelist = ls(foldername);
                while count <= nop
                    date1 = businessdate(date1,-1);
                    ifound = false;
                    filename = [instruments{i}.code_ctp,'_',datestr(date1,'yyyymmdd'),'_1m.txt'];
                    %check whether intraday data is available on that date
                    for ifile = 1:size(filelist,1)
                        if strcmpi(filename,filelist(ifile,:))
                            ifound = true;
                            break
                        end
                    end
                    if ifound
                        count = count + 1;
                    else
                        date1 = businessdate(date1,-1);
                        break
                    end
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
            else
                %add daily buckets
                %best to use in-house build index for equity index as it
                %rolls everymonth
                %todo:add oil and base metals
                assetname = instruments{i}.asset_name;
                if strcmpi(assetname,'eqindex_300') || strcmpi(assetname,'eqindex_50') || strcmpi(assetname,'eqindex_500')
                    [ri,oi] = bkfunc_genfutrollinfo(assetname);
                    [~,~,hd] = bkfunc_buildcontinuousfutures(ri,oi);
                else
                    hd = cDataFileIO.loadDataFromTxtFile([instruments{i}.code_ctp,'_daily.txt']);
                end
                category = getfutcategory(instruments{i});
                if category == 1 || category == 2 || category == 3
                    candles = hd(hd(:,1)<date2,1:5);
                else
                    %as the instrument trades in the evening session
                    candles = hd(hd(:,1)<=date2,1:5);
                end
                if length(candles) > 252, candles = candles(end-251:end,:);end
                if category == 1 || category == 2 || category == 3
                    candles(:,1) = candles(:,1)+(mdefut.candles_{i}(1,1)-date2);
                else
                    candles(2:end,1) = candles(1:end-1,1)+(mdefut.candles_{i}(1,1)-date2);
                    candles = candles(2:end,:);
                end
                mdefut.hist_candles_{i} = candles;
            end
            
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
                        if (hh < 21 && hh >= 15) || (hh > 2 && hh < 9)
                            if  mdefut.candle_freq_(i) ~= 1440
                                candles = ds.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx+1),'yyyy-mm-dd HH:MM:SS'),mdefut.candle_freq_(i),'trade');
                            else
                                category = getfutcategory(instruments{i});
                                if category <= 3
                                    %do nothing
                                elseif category == 4
                                    dt1 = datestr(buckets(1),'yyyy-mm-dd HH:MM:SS');
                                    if hh > 2 && hh < 9
                                        dt2 = datestr(floor(buckets(1)) + 23/24,'yyyy-mm-dd HH:MM:SS');
                                    else
                                        dt2 = datestr(floor(buckets(2)) + 15/24,'yyyy-mm-dd HH:MM:SS');
                                    end
                                    kc = ds.intradaybar(instruments{i},dt1,dt2,1,'trade');
                                    candles = [buckets(idx),kc(1,2),max(kc(:,3)),min(kc(:,4)),kc(end,5)];
                                elseif category == 5
                                    dt1 = datestr(buckets(1),'yyyy-mm-dd HH:MM:SS');
                                    if hh > 2 && hh < 9
                                        dt2 = datestr(floor(buckets(1)) + 26.5/24,'yyyy-mm-dd HH:MM:SS');
                                    else
                                        dt2 = datestr(floor(buckets(2)) + 15/24,'yyyy-mm-dd HH:MM:SS');
                                    end
                                    kc = ds.intradaybar(instruments{i},dt1,dt2,1,'trade');
                                    candles = [buckets(idx),kc(1,2),max(kc(:,3)),min(kc(:,4)),kc(end,5)];
                                end
                            end
                        else
                            try
%                                 ds2 = cBloomberg;
                                if strcmpi(mdefut.qms_.watcher_.conn,'wind') &&  mdefut.qms_.watcher_.isconnect
                                     candles = mdefut.qms_.watcher_.ds.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx),'yyyy-mm-dd HH:MM:SS'),mdefut.candle_freq_(i),'trade');
                                else
                                    if mdefut.candle_freq_(i) ~= 1440
                                        ds2 = cWind;
                                        candles = ds2.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx+1),'yyyy-mm-dd HH:MM:SS'),mdefut.candle_freq_(i),'trade');
                                        ds2.close;
                                    else
                                        try
                                            if ~mdefut.qms_.isconnect
                                                mdefut.login('connection','ctp','countername','ccb_ly_fut');
                                                mdefut.qms_.watcher_.ds.realtime(instruments{i}.code_ctp,'');
                                            end
                                            data = mdefut.qms_.watcher_.ds.realtime(instruments{i}.code_ctp,'');
                                            mkt = data{1}.mkt;
                                            candles = [buckets(idx),mkt(2),mkt(3),mkt(4),mkt(1)];
                                        catch
                                            error('CTP error')
                                        end
                                    end
                                end
                            catch e
                                fprintf('%s\n',e.message);
                                return
                            end                            
                        end
                        %
                        if mdefut.candle_freq_(i) ~= 1440
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
                        else
                            mdefut.candles_{i}(idx,:) = candles;
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
            if mdefut.candle_freq_(i) ~= 1440
                %intraday candles for the last 10 business dates
                count = 1;
                date1 = date2;
                foldername = [getenv('DATAPATH'),'intradaybar\',instrument.code_ctp];
                filelist = ls(foldername);
                while count <= nop
                    date1 = businessdate(date1,-1);
                    ifound = false;
                    filename = [instrument.code_ctp,'_',datestr(date1,'yyyymmdd'),'_1m.txt'];
                    %check whether intraday data is available on that date
                    for ifile = 1:size(filelist,1)
                        if strcmpi(filename,filelist(ifile,:))
                            ifound = true;
                            break
                        end
                    end
                    if ifound
                        count = count + 1;
                    else
                        date1 = businessdate(date1,1);
                        break
                    end
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
            else
                %add daily buckets
                assetname = instruments{i}.asset_name;
                if strcmpi(assetname,'eqindex_300') || strcmpi(assetname,'eqindex_50') || strcmpi(assetname,'eqindex_500')
                    [ri,oi] = bkfunc_genfutrollinfo(assetname);
                    [~,~,hd] = bkfunc_buildcontinuousfutures(ri,oi);
                else
                    hd = cDataFileIO.loadDataFromTxtFile([instruments{i}.code_ctp,'_daily.txt']);
                end
                category = getfutcategory(instruments{i});
                if category == 1 || category == 2 || category == 3
                    candles = hd(hd(:,1)<date2,1:5);
                else
                    candles = hd(hd(:,1)<=date2,1:5);
                end
                if length(candles) > 252, candles = candles(end-251:end,:);end
                if category == 1 || category == 2 || category == 3
                    candles(:,1) = candles(:,1)+(mdefut.candles_{i}(1,1)-date2);
                else
                    candles(2:end,1) = candles(1:end-1,1)+(mdefut.candles_{i}(1,1)-date2);
                    candles = candles(2:end,:);
                end
                mdefut.hist_candles_{i} = candles;
            end
            
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
                        if (hh < 21 && hh >= 15) || (hh > 2 && hh < 9)
                            if  mdefut.candle_freq_(i) ~= 1440
                                candles = ds.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx),'yyyy-mm-dd HH:MM:SS'),mdefut.candle_freq_(i),'trade');
                            else
                                category = getfutcategory(instruments{i});
                                if category <= 3
                                    %do nothing
                                elseif category == 4
                                    dt1 = datestr(buckets(1),'yyyy-mm-dd HH:MM:SS');
                                    if hh > 2 && hh < 9
                                        dt2 = datestr(floor(buckets(1)) + 23/24,'yyyy-mm-dd HH:MM:SS');
                                    else
                                        dt2 = datestr(floor(buckets(2)) + 15/24,'yyyy-mm-dd HH:MM:SS');
                                    end
                                    kc = ds.intradaybar(instruments{i},dt1,dt2,1,'trade');
                                    candles = [buckets(idx),kc(1,2),max(kc(:,3)),min(kc(:,4)),kc(end,5)];
                                    if hh < 21 && hh >= 15
                                        mdefut.lastclose_(i) = kc(end,5);
                                    end
                                elseif category == 5
                                    dt1 = datestr(buckets(1),'yyyy-mm-dd HH:MM:SS');
                                    if hh > 2 && hh < 9
                                        dt2 = datestr(floor(buckets(1)) + 26.5/24,'yyyy-mm-dd HH:MM:SS');
                                    else
                                        dt2 = datestr(floor(buckets(2)) + 15/24,'yyyy-mm-dd HH:MM:SS');
                                    end
                                    kc = ds.intradaybar(instruments{i},dt1,dt2,1,'trade');
                                    candles = [buckets(idx),kc(1,2),max(kc(:,3)),min(kc(:,4)),kc(end,5)];
                                    if hh < 21 && hh >= 15
                                        mdefut.lastclose_(i) = kc(end,5);
                                    end
                                end
                            end
                        else
                            try
%                                 ds2 = cBloomberg;
                                if strcmpi(mdefut.qms_.watcher_.conn,'wind') &&  mdefut.qms_.watcher_.isconnect
                                    candles = mdefut.qms_.watcher_.ds.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx),'yyyy-mm-dd HH:MM:SS'),mdefut.candle_freq_(i),'trade');
                                else
                                    if mdefut.candle_freq_(i) ~= 1440
                                        ds2 = cWind;
                                        candles = ds2.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx),'yyyy-mm-dd HH:MM:SS'),mdefut.candle_freq_(i),'trade');
                                        ds2.close;
                                    else
                                        try
                                            if ~mdefut.qms_.isconnect
                                                mdefut.login('connection','ctp','countername','ccb_ly_fut');
                                                mdefut.qms_.watcher_.ds.realtime(instruments{i}.code_ctp,'');
                                            end
                                            data = mdefut.qms_.watcher_.ds.realtime(instruments{i}.code_ctp,'');
                                            mkt = data{1}.mkt;
                                            candles = [buckets(idx),mkt(2),mkt(3),mkt(4),mkt(1)];
                                        catch
                                            error('CTP error')
                                        end
                                    end
                                end
                            catch e
                                fprintf('%s\n',e.message);
                                return
                            end                           
                        end
                        if mdefut.candle_freq_(i) ~= 1440
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
                        else
                            mdefut.candles_{i}(idx,:) = candles;
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