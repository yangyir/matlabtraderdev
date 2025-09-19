function [ret] = initcandles(mdeopt,instrument,varargin)
% a cMDEOpt function
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('NumberofPeriods',20,@isnumeric);
    p.parse(varargin{:});
    nop = p.Results.NumberofPeriods;
    instruments = mdeopt.qms_.instruments_.getinstrument;
    ns = size(instruments,1);
    ds = cLocal;
    
    if nargin < 2
        for i = 1:ns
            date2 = floor(mdeopt.candles_{i}(1,1));
            if mdeopt.candle_freq_(i) ~= 1440
                count = 1;
                date1 = date2;
                foldername = [getenv('DATAPATH'),'intradaybar\',instruments{i}.code_ctp];
                filelist = ls(foldername);
                if mdeopt.candle_freq_(i) == 30
                    nop = 20;
                elseif mdeopt.candle_freq_(i) == 15
                    nop = 10;
                elseif mdeopt.candle_freq_(i) == 5 || mdeopt.candle_freq_(i) == 1
                    nop = 5;
                end
                
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
                candles = ds.intradaybar(instruments{i},date1str,date2str,mdeopt.candle_freq_(i),'trade');
                mdeopt.hist_candles_{i,1} = candles;
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
                    candles(:,1) = candles(:,1)+(mdeopt.candles_{i}(1,1)-date2);
                else
                    candles(2:end,1) = candles(1:end-1,1)+(mdeopt.candles_{i}(1,1)-date2);
                    candles = candles(2:end,:);
                end
                mdeopt.hist_candles_{i,1} = candles;
            end
            
            %fill the live candles in case it is missing
            if ~strcmpi(mdeopt.mode_,'replay')
                t = now;
                buckets = mdeopt.candles_{i}(:,1);
                idx = find(buckets<=t);
                if isempty(idx)
                    %todo:here we shall return an error
                else
                    idx = idx(end);
                    mdeopt.candles_count_(i) = idx;
                    if idx < size(buckets,1)
                        hh = hour(t);
                        if (hh < 21 && hh >= 15) || (hh > 2 && hh < 9)
                            if  mdeopt.candle_freq_(i) ~= 1440
                                candles = ds.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx+1),'yyyy-mm-dd HH:MM:SS'),mdeopt.candle_freq_(i),'trade');
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
                            error('not implemented pls check code')    
                        end
                        %
                        if mdeopt.candle_freq_(i) ~= 1440
                            if size(candles,1) < idx
                                tmp = [candles;mdeopt.candles_{i}(idx+1:end,:)];
                                mdeopt.candles_{i} = tmp;
                                mdeopt.candles_count_(i) = size(candles,1);
                            else
                                for j = 1:size(candles,1)
                                    mdeopt.candles_{i}(j,2:end) = candles(j,2:end);
                                end
                                mdeopt.candles_count_(i) = idx;
                            end
                        else
                            mdeopt.candles_{i}(idx,:) = candles;
                            mdeopt.candles_count_(i) = idx;
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
            error('%s:initcandles:invalid instrument input',class(mdeopt))
        end
    end
    flag = false;
    for i = 1:ns
        if strcmpi(instruments{i}.code_ctp,instrument.code_ctp)
            flag = true;
            date2 = floor(mdeopt.candles_{i}(1,1));
            if mdeopt.candle_freq_(i) ~= 1440
                %intraday candles for the last 10 business dates
                count = 1;
                date1 = date2;
                foldername = [getenv('DATAPATH'),'intradaybar\',instrument.code_ctp];
                filelist = ls(foldername);
                if mdeopt.candle_freq_(i) == 30
                    nop = 20;
                elseif mdeopt.candle_freq_(i) == 15
                    nop = 10;
                elseif mdeopt.candle_freq_(i) == 5 || mdeopt.candle_freq_(i) == 1
                    nop = 5;
                end
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
                candles = ds.intradaybar(instruments{i},date1str,date2str,mdeopt.candle_freq_(i),'trade');
                mdeopt.hist_candles_{i,1} = candles;
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
                    candles(:,1) = candles(:,1)+(mdeopt.candles_{i}(1,1)-date2);
                else
                    candles(2:end,1) = candles(1:end-1,1)+(mdeopt.candles_{i}(1,1)-date2);
                    candles = candles(2:end,:);
                end
                mdeopt.hist_candles_{i,1} = candles;
            end
            
            %fill the live candles in case it is missing
            if ~strcmpi(mdeopt.mode_,'replay')
                t = now;
                buckets = mdeopt.candles_{i}(:,1);
                idx = find(buckets<=t);
                if isempty(idx)
                    %todo:here we shall return an error
                else
                    idx = idx(end);
                    if idx <= size(buckets,1)
                        hh = hour(t);
                        if (hh < 21 && hh >= 15) || (hh > 2 && hh < 9)
                            if  mdeopt.candle_freq_(i) ~= 1440
                                candles = ds.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx),'yyyy-mm-dd HH:MM:SS'),mdeopt.candle_freq_(i),'trade');
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
                                        mdeopt.lastclose_(i) = kc(end,5);
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
                                        mdeopt.lastclose_(i) = kc(end,5);
                                    end
                                end
                            end
                        else
                            category = getfutcategory(instruments{i});
                            mm = minute(t);
                            if (hh == 12 || (hh == 11 && mm > 30)) || (category <= 3 && (hh > 15 || hh < 9))
                                if mdeopt.candle_freq_(i) ~= 1440
                                    try
                                        candles = ds.intradaybar(instruments{i},datestr(buckets(1),'yyyy-mm-dd HH:MM:SS'),datestr(buckets(idx),'yyyy-mm-dd HH:MM:SS'),mdeopt.candle_freq_(i),'trade');
                                    catch
                                        error('data on the current trading date is not found on local drive\n')
                                    end
                                else
                                    try
                                        if ~mdeopt.qms_.isconnect
                                            mdeopt.login('connection','ctp','countername','ccb_ly_fut');
                                            mdeopt.qms_.watcher_.ds.realtime(instruments{i}.code_ctp,'');
                                        end
                                        data = mdeopt.qms_.watcher_.ds.realtime(instruments{i}.code_ctp,'');
                                        mkt = data{1}.mkt;
                                        candles = [buckets(idx),mkt(2),mkt(3),mkt(4),mkt(1)];
                                    catch
                                         error('CTP error')
                                     end
                                end
                                    
                            else
                                if mdeopt.candle_freq_(i) == 1440
                                    try
                                        if ~mdeopt.qms_.isconnect
                                            mdeopt.login('connection','ctp','countername','ccb_ly_fut');
                                            mdeopt.qms_.watcher_.ds.realtime(instruments{i}.code_ctp,'');
                                        end
                                        data = mdeopt.qms_.watcher_.ds.realtime(instruments{i}.code_ctp,'');
                                        mkt = data{1}.mkt;
                                        candles = [buckets(idx),mkt(2),mkt(3),mkt(4),mkt(1)];
                                    catch
                                         error('CTP error')
                                    end
                                else
                                    error('invalid time to initiate mktdata as connection to remote database is now disabled\n')
                                end
                            end
                            
                        end
                        if mdeopt.candle_freq_(i) ~= 1440
                            if size(candles,1) < idx
                                tmp = [candles;mdeopt.candles_{i}(idx+1:end,:)];
                                mdeopt.candles_{i} = tmp;
                                mdeopt.candles_count_(i) = size(candles,1);
                            else
                                for j = 1:size(candles,1)
                                    mdeopt.candles_{i}(j,2:end) = candles(j,2:end);
                                end
                                mdeopt.candles_count_(i) = idx;
                            end
                        else
                            mdeopt.candles_{i}(idx,:) = candles;
                            mdeopt.candles_count_(i) = idx;
                        end
                    end
                end
            end
            ret = true;
            break
        end
    end
    if ~flag, error('%s:initcandles:instrument not found',class(mdeopt)); end
    ds.close;
end
%end of initcandles