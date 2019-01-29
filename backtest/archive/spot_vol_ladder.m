strat = stratopt_yy;

%%
inst = strat.instruments_.getinstrument;

%%
opts = {'m1805-C-2800';'m1805-P-2800';...
    'm1805-C-2850';'m1805-P-2850';...
    'm1805-C-2900';'m1805-P-2900'};

indices = zeros(size(opts,1),1);
strikes = zeros(size(opts,1),1);
for i = 1:size(opts,1) 
    [~,indices(i)] = strat.instruments_.hasinstrument(opts{i}) ;
    strikes(i) = strat.instruments_.getinstrument{indices(i)}.opt_strike;
end

%%
%gross greeks
weights = [-200;-280;...
    -340;-390;...
    -290;0];

thetacarry = 0;
deltacarry = 0;
gammacarry = 0;
vegacarry = 0;

for i = 1:size(opts,1)
    thetacarry = thetacarry+strat.thetacarry_(indices(i))*weights(i);
    deltacarry = deltacarry+strat.deltacarry_(indices(i))*weights(i);
    gammacarry = gammacarry+strat.gammacarry_(indices(i))*weights(i);
    vegacarry = vegacarry+strat.vegacarry_(indices(i))*weights(i);
end

fprintf('theta:%6.0f, delta:%8.0f, gamma:%8.0f, vega:%8.0f\n',thetacarry,deltacarry,gammacarry,vegacarry);

%%
%spot-vol ladder analysis
settle = datenum('2018-02-22','yyyy-mm-dd');
maturity = datenum('2018-04-06','yyyy-mm-dd');
r = 0.035;
mult = 10;
iv = strat.impvol_(indices);
spots = (2800:10:2900)';
ns = size(spots,1);
delta_ns = zeros(ns,1);
gamma_ns = zeros(ns,1);
vega_ns = zeros(ns,1);
for i = 1:ns
    s = spots(i);
    s_up = s*1.005;
    s_dn = s*0.995;
    for j = 1:size(opts,1)
        if strcmpi(inst{j}.opt_type,'C')
            v = bjsprice(s,strikes(j),r,settle, maturity,iv(j), r);
            v_up = bjsprice(s_up,strikes(j),r,settle, maturity,iv(j), r);
            v_dn = bjsprice(s_dn,strikes(j),r,settle, maturity,iv(j), r);
        else
            [~,v] = bjsprice(s,strikes(j),r,settle, maturity,iv(j), r);
            [~,v_up] = bjsprice(s_up,strikes(j),r,settle, maturity,iv(j), r);
            [~,v_dn] = bjsprice(s_dn,strikes(j),r,settle, maturity,iv(j), r);
        end
        delta_ns(i) = delta_ns(i)+(v_up - v_dn)/(s_up-s_dn)*weights(j);
        gamma_ns(i) = gamma_ns(i)+(v_up+v_dn-2*v)/(0.005^2)*0.01/s*weights(j);
    end
    delta_ns(i) = delta_ns(i)*mult*s;
    gamma_ns(i) = gamma_ns(i)*mult*s;
   
end
%%
subplot(211);plot(spots,delta_ns);
subplot(212);plot(spots,gamma_ns);









