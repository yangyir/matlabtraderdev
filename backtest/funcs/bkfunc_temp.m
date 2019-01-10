% assets = getassetmaptable;
c = bbgconnect;
db = cLocal;
assets = {'copper'};
nassets = size(assets,1);
dailyvolres = cell(nassets,1);
for i = 1:nassets, dailyvolres{i} = rollfutures(assets{i});end

%%
rollinfo2use = cell(nassets,1);
% [dataintraday] = bkfunc_loadintradaydata( c, assets );
dtstart = zeros(nassets,1);
for i = 1:nassets
%     data = dataintraday{1};
%     dtstart(i) = data(1,1);
    dtstart(i) = datenum('2018-01-01','yyyy-mm-dd');
    for j = 1:size(dailyvolres{i}.RollInfo,1)
        if dailyvolres{i}.RollInfo{j,1} > dtstart(i)
            break
        end
    end
    rollinfo2use{i} = dailyvolres{i}.RollInfo(j:end,:);
end
%%
% note: rules to calculate intraday returns and to consilidate those
% returns into continuous time series:
% 1. download the pre-active contract until the close on the roll date
% 2. download the post-active contract from the open on the roll date
% 3. use the prices of the pre-active contract until the close on the roll
% date for the intraday return calculation
% 4. use the prices of the post-active contract from the open on the next
% business date after the roll date with the close of the post-active
% contract for the intraday return calculation
% 5.use returns in step 3 and 4 to consolidate continuous return series
clc;
intradaydata2use = cell(nassets,1);
for i = 1:nassets
    rollinfo_i = rollinfo2use{i};
    nrolls_i = size(rollinfo_i,1);
    intradaydata2use_i = cell(nrolls_i+1,1);
    for j = 1:nrolls_i + 1
        if j ~= nrolls_i + 1
            dotindex_j = strfind(rollinfo_i{j,4},'.');
            instrument_j = code2instrument(rollinfo_i{j,4}(1:dotindex_j-1));
            if j == 1
                category_i = getfutcategory(instrument_j);
                mktopentimestr = instrument.break_interval{1,1};
                if category_i == 1 || category_i == 2
                    mktclosetimestr = instrument.break_interval{2,2};
                elseif category_i == 3 || category_i == 4 || category_i == 5
                    mktclosetimestr = instrument.break_interval{3,2};
                end
            end
            if j == 1
                dt1 = [datestr(dtstart(i),'yyyy-mm-dd'),' ',mktopentimestr];
            else
                dt1 = [datestr(rollinfo_i{j-1,1},'yyyy-mm-dd'),' ',mktopentimestr];
            end
            dt2 = [datestr(rollinfo_i{j,1},'yyyy-mm-dd'),' ',mktclosetimestr];
        else
            dotindex_j = strfind(rollinfo_i{j-1,5},'.');
            instrument_j = code2instrument(rollinfo_i{j-1,5}(1:dotindex_j-1));
            dt1 = [datestr(rollinfo_i{j-1,1},'yyyy-mm-dd'),' ',mktopentimestr];
            dt2 = [datestr(getlastbusinessdate,'yyyy-mm-dd'),' ',mktclosetimestr];
        end
        intradaydata2use_i{j}.dt1str = dt1;
        intradaydata2use_i{j}.dt2str = dt2;
        intradaydata2use_i{j}.codectp = instrument_j.code_ctp;
        intradaydata2use_i{j}.data = db.intradaybar(instrument_j,dt1,dt2,1,'trade');
        fprintf('%s <-> %s\n',dt1,dt2);
    end
    intradaydata2use{i} = intradaydata2use_i;
end
clear intradaydata2use_i
%%
freq = 15;
continousret2use = cell(nassets);
for i = 1:nassets
    nfut = size(intradaydata2use{i},1);
    compresseddata = cell(nfut,1);
    ret = cell(nfut,1);
    for j = 1:nfut
       instrument_i = code2instrument(intradaydata2use{i}{j}.codectp);
       compresseddata{j} = timeseries_compress(intradaydata2use{i}{j}.data,...
            'tradinghours',instrument_i.trading_hours,...
            'tradingbreak',instrument_i.trading_break,...
            'frequency',[num2str(freq),'m']);
        ret{j} = [compresseddata{j}(2:end,1),log(compresseddata{j}(2:end,5)./compresseddata{j}(1:end-1,5))];
    end
    %
    %now we consolidate continuous returns
    continousret2use_i = cell(nfut,1);
    continousret2use_i{1} = ret{1};
    for j = 2:nfut
        tbreak = ret{j-1}(end,1);
        idx_j = ret{j}(:,1) > tbreak;
        continousret2use_i{j} = ret{j}(idx_j,:);
    end
    continousret2use{i} = cell2mat(continousret2use_i);
end
%% intraday vol calibation
model = arima('ARLags',1,'Variance',garch(1,1));
modelEstimated = cell(nassets,1);
intradaylv = zeros(nassets,1);
for i = 1:nassets
    modelEstimated{i} = estimate(model,continousret2use{i}(:,2),'print',false);
    paramGarch = modelEstimated{i}.Variance.GARCH{1};
    paramArch = modelEstimated{i}.Variance.ARCH{1};
    paramConst = modelEstimated{i}.Variance.Constant;
    intradaylv(i) = sqrt(paramConst/(1-paramGarch-paramArch));
end
%%
[res] = bkfunc_hvcalib(continousret2use{i},'PlotConditonalVariance',true)
%%
[res2] = bkfunc_intradayhvcalib('copper',dailyvolres{1}.RollInfo);

