%%
ds = cLocal;
date_from = '2017-12-04';
date_to = datestr(getlastbusinessdate,'yyyy-mm-dd');
%%
%白糖期货期权
fut_sugar = cFutures('SR805');fut_sugar.loadinfo('SR805_info.txt');
cp_fut_sugar = ds.history(fut_sugar,'last_trade',date_from,date_to);
cp_fut_min = min(cp_fut_sugar(:,2));
cp_fut_max = max(cp_fut_sugar(:,2));
strike_bucket = 100;
strike_min = floor(cp_fut_min/strike_bucket)*strike_bucket;
strike_max = ceil(cp_fut_max/strike_bucket)*strike_bucket;
strikes = (strike_min:strike_bucket:strike_max)';
nopt = size(strikes,1);
calls_sugar = cell(nopt,1);
puts_sugar = cell(nopt,1);
for i = 1:nopt
    calls_sugar{i,1} = cOption(['SR805C',num2str(strikes(i))]);
    calls_sugar{i,1}.loadinfo(['SR805C',num2str(strikes(i)),'_info.txt']);
    puts_sugar{i,1} = cOption(['SR805P',num2str(strikes(i))]);
    puts_sugar{i,1}.loadinfo(['SR805P',num2str(strikes(i)),'_info.txt']);
end
cp_calls_sugar = cell(nopt,1);
cp_puts_sugar = cell(nopt,1);
for i = 1:nopt
    cp_calls_sugar{i,1} = ds.history(calls_sugar{i,1},'last_trade',date_from,date_to);
    cp_puts_sugar{i,1} = ds.history(puts_sugar{i,1},'last_trade',date_from,date_to);
end
%%
%隐含波动率(implied volatility)
nbdays = size(cp_fut_sugar,1);
r = 0.035;
iv_calls_soymeal = cell(nopt,1);
iv_puts_soymeal = cell(nopt,1);

for i = 1:nopt
    iv_calls = zeros(nbdays,2);iv_calls(:,1) = cp_fut_sugar(:,1);
    iv_puts = zeros(nbdays,2);iv_puts(:,1) = cp_fut_sugar(:,1);
    for j = 1:nbdays
        S = cp_fut_sugar(j,2);
        settle = cp_fut_sugar(j,1);
        X = strikes(i);
        maturity = calls_sugar{i,1}.opt_expiry_date1;
        premium_call = cp_calls_sugar{i,1}(j,2);
        iv_calls(j,2) = bjsimpv(S,X,r,settle,maturity,premium_call,[],r,[],'call');
        %
        premium_put = cp_puts_sugar{i,1}(j,2);
        iv_puts(j,2) = bjsimpv(S,X,r,settle,maturity,premium_put,[],r,[],'put');
    end
    iv_calls_soymeal{i,1} = iv_calls;
    iv_puts_soymeal{i,1} = iv_puts;    
end
%%
%ATMVol(平值波动率）
atmiv_calls = zeros(nbdays,2);atmiv_calls(:,1) = cp_fut_sugar(:,1);
atmiv_puts = zeros(nbdays,2);atmiv_puts(:,1) = cp_fut_sugar(:,1);
for i = 1:nbdays
    S = cp_fut_sugar(i,2);
    X_lower = floor(S/strike_bucket)*strike_bucket;
    X_upper = X_lower+strike_bucket;
    idx_lower = find(strikes == X_lower);
    idx_upper = idx_lower+1;
    iv_calls_lower = iv_calls_soymeal{idx_lower,1}(i,2);
    iv_calls_upper = iv_calls_soymeal{idx_upper,1}(i,2);
    atmiv_calls(i,2) = interp1([X_lower,X_upper],[iv_calls_lower,iv_calls_upper],S);
    %
    iv_puts_lower = iv_puts_soymeal{idx_lower,1}(i,2);
    iv_puts_upper = iv_puts_soymeal{idx_upper,1}(i,2);
    atmiv_puts(i,2) = interp1([X_lower,X_upper],[iv_puts_lower,iv_puts_upper],S);
end
plot(atmiv_calls(:,2),'b');hold on;
plot(atmiv_puts(:,2),'r');hold off;






