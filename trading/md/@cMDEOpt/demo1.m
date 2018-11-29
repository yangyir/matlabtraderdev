%% user inputs
code_ctp_underlier = 'cu1902';
numstrikes = 5;
%%
mdeopt = cMDEOpt;
[calls,puts] = mdeopt.loadoptions(code_ctp_underlier,numstrikes);
strikes = zeros(numstrikes,1);
for i = 1:numstrikes, strikes(i) = calls{i}.opt_strike;end
%%
mdeopt.login('connection','ctp','countername','ccb_ly_fut');
mdeopt.start

%% plot latest vol vs. last business's carry vol
mdeopt.plotvolslice(code_ctp_underlier,numstrikes);

%% synthetic straddle vol

greeks1 = mdeopt.getgreeks('cu1902C50000');
greeks2 = mdeopt.getgreeks('cu1902C49000');
deltacarry = 3*(greeks1.deltacarry + greeks2.deltacarry)
theta = 3*(greeks1.theta + greeks2.theta)
gammacarry = 3*(greeks1.gammacarry + greeks2.gammacarry)
vegacarry = 3*(greeks1.vegacarry + greeks2.vegacarry)




%%

c2trade1 = [code_ctp_underlier,'C',num2str(strike2)];c2trade2 = [code_ctp_underlier,'C',num2str(strike2+strikebucket)]
p2trade1 = [code_ctp_underlier,'P',num2str(strike1)];p2trade2 = [code_ctp_underlier,'P',num2str(strike1-strikebucket)];
qc1 = mdeopt.qms_.getquote(c2trade1);qc2 = mdeopt.qms_.getquote(c2trade2);
qp1 = mdeopt.qms_.getquote(p2trade1);qp2 = mdeopt.qms_.getquote(p2trade2);
% mdeopt.deltacarry_
% long strike1 put and strike2 call
greeksc2trade1 = mdeopt.getgreeks(c2trade1);
greeksc2trade2 = mdeopt.getgreeks(c2trade2);
greeksp2trade1 = mdeopt.getgreeks(p2trade1);
greeksp2trade2 = mdeopt.getgreeks(p2trade2);
cvolume1 = 1;
cvolume2 = -cvolume1*0;
pvolume1 = round(abs(cvolume1*greeksc2trade1.deltacarry/greeksp2trade1.deltacarry));
pvolume2 = -pvolume1*0;

deltacarry = cvolume1*greeksc2trade1.deltacarry + pvolume1*greeksp2trade1.deltacarry +...
    cvolume2*greeksc2trade2.deltacarry + pvolume2*greeksp2trade2.deltacarry;
gammacarry = cvolume1*greeksc2trade1.gammacarry + pvolume1*greeksp2trade1.gammacarry +...
    cvolume2*greeksc2trade2.gammacarry + pvolume2*greeksp2trade2.gammacarry;
thetacarry = cvolume1*greeksc2trade1.theta + pvolume1*greeksp2trade1.theta +...
    cvolume2*greeksc2trade2.theta + pvolume2*greeksp2trade2.theta;
vegacarry = cvolume1*greeksc2trade1.vegacarry + pvolume1*greeksp2trade1.vegacarry +...
    cvolume2*greeksc2trade2.vegacarry + pvolume2*greeksp2trade2.vegacarry;
premium = cvolume1*qc1.ask1 + pvolume1*qp1.ask1 +...
    cvolume2*qc2.bid1 + pvolume2*qp2.bid1;

fprintf('%s:%d\t%s:%d\t%s:%d\t%s:%d\n',c2trade1,cvolume1,p2trade1,pvolume1,c2trade2,cvolume2,p2trade2,pvolume2);
fprintf('Premium:%s\tTheta:%6.0f\tDelta:%6.0f\tGamma:%6.0f\tVega:%6.0f\n',...
    num2str(premium),thetacarry,deltacarry,gammacarry,vegacarry);
%% trade
opt_counter = CounterCTP.ccb_ly_fut;
if ~opt_counter.is_Counter_Login, opt_counter.login;end
%%
qc1 = mdeopt.qms_.getquote(c2trade1);qc2 = mdeopt.qms_.getquote(c2trade2);
qp1 = mdeopt.qms_.getquote(p2trade1);qp2 = mdeopt.qms_.getquote(p2trade2);
offset = 1;
if cvolume1 ~= 0
    centrust1 = Entrust;
    centrust1.fillEntrust(1,c2trade1,sign(cvolume1),qc1.bid1,cvolume1,offset,c2trade1);
end
if cvolume2 ~= 0
    centrust2 = Entrust;
    centrust2.fillEntrust(1,c2trade2,sign(cvolume2),qc2.bid1,cvolume1,offset,c2trade1);
end
pentrust = Entrust;
pentrust.fillEntrust(1,p2trade1,direction,qp1.bid1,pvolume1,offset,p2trade1);


%%
ret1 = opt_counter.placeEntrust(centrust1);
ret2 = opt_counter.placeEntrust(pentrust);

















%%
mdeopt.logoff