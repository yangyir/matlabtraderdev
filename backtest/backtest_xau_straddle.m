% bbgcode = 'xau curncy';
% datefrom = '10-Oct-2016';
% dateto = '26-Mar-2017';
% data = timeseries(c,bbgcode,{datefrom,dateto},1,'trade');
% sec = struct('BloombergCode',bbgcode,'ContractSize',5);
% notional = 1e6;

%%
% use the same vol
% underliervol = {struct('Instrument',sec,'Vol',0.01)};

%%
time = data(:,1);   %date/time
cp = data(:,5);
datesunique = unique(floor(time));
ndays = length(datesunique);
straddles = cell(ndays,3);
strats = cell(ndays,1);
tps = cell(ndays,1);

for i = 1:ndays-1
    idx = time >= datesunique(i) & time < datesunique(i+1);
    cp_i = cp(idx);
    time_i = time(idx);
    tradedate_i = datesunique(i);
    expirydate_i = dateadd(tradedate_i,'3m');
    t = (expirydate_i - tradedate_i)/252;
    straddles{i} = cStraddle('underlier',sec,...
        'strike',cp_i(1),...
        'tradedate',tradedate_i,...
        'expirydate',expirydate_i,...
        'notional',notional);
    %do a valuation
    straddles{i,2} = valstraddle(cp_i(1),cp_i(1),0,t,0.01,0,notional);
    straddles{i,3} = 'live';
    strats{i} = cStrategySyntheticStraddle;
    strats{i} = strats{i}.addstraddle(straddles{i,1});
    tps{i} = cTradingPlatform;
    underlierinfo_i = {struct('Instrument',sec,...
        'Time',time_i(1),...
        'Price',cp_i(1))};
    orders = strats{j}.genorder('underlierinfo',underlierinfo_i,...
        'underliervol',underliervol,...
        'tradingplatform',tps{j});
                    
    for ii = 1:length(orders)
        tradeid = length(tps{j}.gettrades)+1;
        tps{j} = tps{j}.sendorder('order',orders{ii},...
            'tradeid',tradeid);
    end
    
end

%%
pnl = zeros(ndays,1);
for i = 1:ndays-1
    cob_i = datesunique(i);
    fprintf('cob date:%s\n',datestr(cob_i,'yyyymmdd'));
    next_cob_i = datesunique(i+1);
    idx = time >= cob_i & time < next_cob_i;
    cp_i = cp(idx);
    time_i = time(idx);
    for j = 1:i
        if isempty(straddles{j})
            continue
        end
        if straddles{j,1}.TradeDate <= cob_i && strcmpi(straddles{j,3},'live')
            %first to do a valuation of the straddle to check whether we
            %should remove the straddle from the list
%             if j == i
%                 premium_j = straddles{j,2};
%                 pnl_j = 0;
%             else
%                 t = (straddles{j}.ExpiryDate-cob_i)/252;
%                 premium_j = valstraddle(cp_i(1),straddles{j}.Strike,0,t,0.01,0,notional);
%                 pnl_j = premium_j - straddles{j,2};
%             end
%             
%             
%             if pnl_j <= -1e4
%                 straddles{j,3} = 'dead';
%             end
            
            if straddles{j,1}.ExpiryDate < cob_i
                %straddle expired
                straddles{j,3} = 'dead';
            end
            
            if ~strcmpi(straddles{j,3},'dead')
                tps{j}.printpositions;
                for k = 1:length(cp_i)
                    underlierinfo_i = {struct('Instrument',sec,...
                        'Time',time_i(k),...
                        'Price',cp_i(k))};
                    orders = strats{j}.genorder('underlierinfo',underlierinfo_i,...
                        'underliervol',underliervol,...
                        'tradingplatform',tps{j});
                    
                    for ii = 1:length(orders)
                        tradeid = length(tps{j}.gettrades)+1;
                        tps{j} = tps{j}.sendorder('order',orders{ii},...
                            'tradeid',tradeid);
                    end
%                     pnl(j,1) = tps{j}.calcpnl(underlierinfo{1});
%                     fprintf('%s pnl of %4.0f straddle:%4.2f\n',...
%                         datestr(time_i(k),'yyyymmdd HH:MM'),...
%                         j,pnl(j,1));
                    
                end
                tps{j}.printpositions;
                pnl(j,1) = tps{j}.calcpnl(underlierinfo_i{1});
                fprintf('%s pnl of %s straddle:%4.2f\n',...
                    datestr(time_i(k),'yyyymmdd HH:MM'),...
                    num2str(j),pnl(j,1));    
            
            end
            
            
        end
    end
end

