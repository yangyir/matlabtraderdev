%%
ds = cLocal;
date_from = '2017-12-04';
date_to = datestr(getlastbusinessdate,'yyyy-mm-dd');
%%
%�����ڻ���Ȩ
fut_soymeal = cFutures('m1805');fut_soymeal.loadinfo('m1805_info.txt');
cp_fut_soymeal = ds.history(fut_soymeal,'last_trade',date_from,date_to);
cp_fut_min = min(cp_fut_soymeal(:,2));
cp_fut_max = max(cp_fut_soymeal(:,2));
strike_bucket = 50;
strike_min = floor(cp_fut_min/strike_bucket)*strike_bucket;
strike_max = ceil(cp_fut_max/strike_bucket)*strike_bucket;
strikes = (strike_min:strike_bucket:strike_max)';
nopt = size(strikes,1);
calls_soymeal = cell(nopt,1);
puts_soymeal = cell(nopt,1);
for i = 1:nopt
    calls_soymeal{i,1} = cOption(['m1805-C-',num2str(strikes(i))]);
    calls_soymeal{i,1}.loadinfo(['m1805-C-',num2str(strikes(i)),'_info.txt']);
    puts_soymeal{i,1} = cOption(['m1805-P-',num2str(strikes(i))]);
    puts_soymeal{i,1}.loadinfo(['m1805-P-',num2str(strikes(i)),'_info.txt']);
end
cp_calls_soymeal = cell(nopt,1);
cp_puts_soymeal = cell(nopt,1);
for i = 1:nopt
    cp_calls_soymeal{i,1} = ds.history(calls_soymeal{i,1},'last_trade',date_from,date_to);
    cp_puts_soymeal{i,1} = ds.history(puts_soymeal{i,1},'last_trade',date_from,date_to);
end
%%
%����������(implied volatility)
nbdays = size(cp_fut_soymeal,1);
r = 0.035;
iv_calls_soymeal = cell(nopt,1);
iv_puts_soymeal = cell(nopt,1);

for i = 1:nopt
    iv_calls = zeros(nbdays,2);iv_calls(:,1) = cp_fut_soymeal(:,1);
    iv_puts = zeros(nbdays,2);iv_puts(:,1) = cp_fut_soymeal(:,1);
    for j = 1:nbdays
        S = cp_fut_soymeal(j,2);
        settle = cp_fut_soymeal(j,1);
        X = strikes(i);
        maturity = calls_soymeal{i,1}.opt_expiry_date1;
        premium_call = cp_calls_soymeal{i,1}(j,2);
        iv_calls(j,2) = bjsimpv(S,X,r,settle,maturity,premium_call,[],r,[],'call');
        %
        premium_put = cp_puts_soymeal{i,1}(j,2);
        iv_puts(j,2) = bjsimpv(S,X,r,settle,maturity,premium_put,[],r,[],'put');
    end
    iv_calls_soymeal{i,1} = iv_calls;
    iv_puts_soymeal{i,1} = iv_puts;    
end
%%
%ATMVol(ƽֵ�����ʣ�
atmiv_calls = zeros(nbdays,2);atmiv_calls(:,1) = cp_fut_soymeal(:,1);
atmiv_puts = zeros(nbdays,2);atmiv_puts(:,1) = cp_fut_soymeal(:,1);
for i = 1:nbdays
    S = cp_fut_soymeal(i,2);
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






