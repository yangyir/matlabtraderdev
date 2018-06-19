clear
clc
%%
code = 'rb1810';
replay_startdt = '2018-06-04';
replay_enddt = '2018-06-08';
replay_dates = gendates('fromdate',replay_startdt,'todate',replay_enddt);
replay_filenames = cell(size(replay_dates));
fn_candles_ = cell(size(replay_dates));
for i = 1:size(replay_dates,1)
    fn_candles_{i} = [code,'_',datestr(replay_dates(i),'yyyymmdd'),'_1m.txt'];
end
% fns = {'cfe_govtbond_10y_generic_1st_1m.mat';...
%     'shfe_nickel_generic_1st_1m';...
%     'shfe_rebar_generic_1st_1m'};
 idx = 3;
px_1m = cDataFileIO.loadDataFromTxtFile(fn_candles_{1});
if length(replay_dates)>=2
    for k =2:length(replay_dates)
        fn_candles = fn_candles_{k};
        tmp = cDataFileIO.loadDataFromTxtFile(fn_candles);
        px_1m = [px_1m;tmp];
    end
end
%%
% d = load(fns{idx});
% px_1m = d.px_1m;
if idx == 1
    f = code2instrument('T1809');
elseif idx == 2
    f = code2instrument('ni1807');
elseif idx == 3
    f = code2instrument('rb1810');
else
    error('invalid idx input');
    
end
tick_size = f.tick_size;
tick_value = f.tick_value;

%%
% backtest parameters
freq_used = 3;
nperiod = 144;
stoploss_ratio = 0.02;
target_ratio = 0.05;
use_sigma_shift_open = 0;
no_sigma_shift = 1;
%%
px_used = timeseries_compress(px_1m,'Frequency',[num2str(freq_used),'m']);
%open-up trades
npx = size(px_used,1);
%1st column is time
%2nd column is direction 
%3rd column is price open

%4th column is price stoploss
%5th column is price target
%6th column is price volatility

trades = zeros(npx-nperiod,6);
ntrade = 0;
for i = nperiod+1:npx
    pxCs = px_used(i-nperiod:i-1,5);
    %note:we first calculate the standard deviation of the selected freq
    %close price
    sigma = std(pxCs(2:end)-pxCs(1:end-1));
    %then we scale the standard deviation back to 1m freq
    sigma_used = sigma/sqrt(freq_used);
    ntick = round(sigma_used/tick_size);
    pxH = max(px_used(i-nperiod:i-1,3));   %pxH is the highest of the previous nperiod data
    pxL = min(px_used(i-nperiod:i-1,4));   %pxL is the lowest of the previous nperiod data
    spd = use_sigma_shift_open*no_sigma_shift*sigma_used;
    spd = ceil(spd/tick_size)*tick_size;
    
    if pxH + spd <= px_used(i,3)
        %note:if the highest of the current candle period is higher than
        %the previous high, we think we would open a trade with a short
        %direction at the price of pxH
        ntrade = ntrade + 1;
        trades(ntrade,1) = px_used(i,1);
        trades(ntrade,2) = -1;
        pxOpen = pxH + spd;
        trades(ntrade,3) = pxOpen;
        %stop-loss at 5% as of pxH-pxL and target at 20% as of pxH-pxL
        trades(ntrade,4) = pxOpen + round(stoploss_ratio*(pxH-pxL)/tick_size)*tick_size;
        trades(ntrade,5) = pxOpen - round(target_ratio*(pxH-pxL)/tick_size)*tick_size;
        trades(ntrade,6) = sigma;
    elseif pxL -spd >= px_used(i,4)
        %note:if the lowest of the current candle period is lower than the
        %previous low, we think we would open a trade with a long direction
        %at the price of pxL
        ntrade = ntrade + 1;
        trades(ntrade,1) = px_used(i,1);
        trades(ntrade,2) = 1;
        pxOpen = pxL - spd;
        trades(ntrade,3) = pxL-spd;
        %stop-loss at 5% as of pxH-pxL and target at 20% as of pxH-pxL
        trades(ntrade,4) = pxOpen - round(stoploss_ratio*(pxH-pxL)/tick_size)*tick_size;
        trades(ntrade,5) = pxOpen + round(target_ratio*(pxH-pxL)/tick_size)*tick_size;
        trades(ntrade,6) = sigma;
    end
end
trades = trades(1:ntrade,:);
%%
profitLoss = zeros(ntrade,1);
holdPeriod = 72;
bw_max = 1/2;
bw_min = 1/3;
% we take half of the period as the maxium length we hold the trade
for i = 1:ntrade
    tradetime = trades(i,1);
    idx = find(px_used(:,1) == tradetime);
    idx_max = min(idx+holdPeriod-1, npx);
   % profitLoss  = w_r_batman_test_sunq(direction,close, open, open_real, target, stoploss, bw_max, bw_min, holdperiod)
   direction = trades(i,2);
   close = px_used(idx+1:end,5);
   high = px_used(idx+1:end,3);
   low = px_used(idx+1:end, 4);
   open_real = trades(i, 3);
   open = trades(i, 3);
   target = trades(i, 5);
   stoploss = trades(i, 4);
   % stoplossMethod = 1 £º we use the close price to stop loss;  stoplossMethod = 2 £º we use the stoploss value(between high and low) to stop loss
   stoplossMethod =2;
     [profitLoss(i)]  = w_r_batman_test_sunq(direction,close,high,low, open, open_real, target, stoploss, bw_max, bw_min, stoplossMethod);
end

num_of_contract = 10;

pnl = sum(profitLoss)/tick_size*tick_value*num_of_contract;
pWin = sum(profitLoss>0)/size(profitLoss,1);

fprintf('total pnl:%s, prob to win:%4.1f%%;number of trades:%d\n',...
    num2str(pnl),pWin*100,ntrade);
plot(cumsum(profitLoss)/tick_size*tick_value*num_of_contract);
if idx == 1
    title('10y govt bond');
elseif idx == 2
    title('nickel');
elseif idx == 3
    title('rebar');
end
figure
hist(profitLoss/tick_size*tick_value*num_of_contract,50); 
    
   

