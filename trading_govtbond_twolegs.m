%%
% init
entrusts_govtbond_curvesloping = EntrustArray;
code_5y = 'TF1712';bnd_5y = cFutures(code_5y);bnd_5y.loadinfo([code_5y,'_info.txt']);
code_10y = 'T1712';bnd_10y = cFutures(code_10y);bnd_10y.loadinfo([code_10y,'_info.txt']);
qms_ctp.registerinstrument(bnd_5y);
qms_ctp.registerinstrument(bnd_10y);
qms_ctp.refresh;
q_5y = qms_ctp.getquote(bnd_5y);
q_10y = qms_ctp.getquote(bnd_10y);

%%
c_govtbond_curvesloping = c_kim;
pos_5y = c_govtbond_curvesloping.queryPositions(code_5y);
pos_10y = c_govtbond_curvesloping.queryPositions(code_10y);    
bumpup = 0.0001;
bumpdn = -0.0001;
pxup_5y = q_5y.last_trade-q_5y.duration*bumpup*100;
pxdn_5y = q_5y.last_trade-q_5y.duration*bumpdn*100;
pxup_10y = q_10y.last_trade-q_10y.duration*bumpup*100;
pxdn_10y = q_10y.last_trade-q_10y.duration*bumpdn*100;
%parallel risk
riskparallelup = (pxup_5y-q_5y.last_trade)*pos_5y.total_position*pos_5y.direction*1e4+...
    (pxup_10y-q_10y.last_trade)*pos_10y.total_position*pos_10y.direction*1e4;
riskparalleldn = (pxdn_5y-q_5y.last_trade)*pos_5y.total_position*pos_5y.direction*1e4+...
        (pxdn_10y-q_10y.last_trade)*pos_10y.total_position*pos_10y.direction*1e4;
fprintf('parallel carry risk 1bp up:%+4.0f; 1bp dn:%+4.0f\n',riskparallelup,riskparalleldn);
riskslopeup = (pxup_10y-q_10y.last_trade)*pos_10y.total_position*pos_10y.direction*1e4;
riskslopedn = (pxdn_10y-q_10y.last_trade)*pos_10y.total_position*pos_10y.direction*1e4;
fprintf('slope carry risk 1bp up:%+4.0f; 1bp dn:%+4.0f\n',riskslopeup,riskslopedn);
%%
qms_ctp.refresh;
spd_bid = q_10y.yield_ask1 - q_5y.yield_bid1;
spd = q_10y.yield_last_trade - q_5y.yield_last_trade;
spd_ask = q_10y.yield_bid1 - q_5y.yield_ask1;
fprintf('bid:%2.1f;ask:%2.1f;trade:%2.1f;10y:%2.2f\n',spd_bid*100,spd_ask*100,spd*100,q_10y.yield_last_trade)

%%
% trade one leg
% user input
c_govtbond_curvesloping = c_ly;
direction = 1;
offset = 1;
unit = 1;

%trading part related codes
qms_ctp.refresh;
v2 = 7*unit;
v1 = round(v2*q_10y.duration/q_5y.duration);

%note:if num_ticks > 0, we always place an entrust below the market
%trade,i.e. place a buy order lower than the current ask and place a sell
%order higher than the current bid. In case num_ticks < 0, we trade above
%the market
if direction > 0
    %buy the spread, i.e. long 5y and short 10y
    ask1 = q_5y.ask1;
    bid2 = q_10y.bid1;
elseif direction < 0
    %sell the spread, i.e. short 5y and long 10y
    bid1 = q_5y.bid1;
    ask2 = q_10y.ask1;
end
d1 = direction;
d2 = -direction;

%first to withdraw pending entrust
% withdrawpendingentrusts(counter,instrument.code_ctp)

e1 = Entrust;
e2 = Entrust;
if direction > 0
    e1.fillEntrust(1,bnd_5y.code_ctp,d1,ask1,v1,offset,bnd_5y.code_ctp);
    e2.fillEntrust(1,bnd_10y.code_ctp,d2,bid2,v2,offset,bnd_10y.code_ctp);    
else
    e1.fillEntrust(1,bnd_5y.code_ctp,d1,bid1,v1,offset,bnd_5y.code_ctp);
    e2.fillEntrust(1,bnd_10y.code_ctp,d2,ask2,v2,offset,bnd_10y.code_ctp);    
end

c_govtbond_curvesloping.placeEntrust(e1);
c_govtbond_curvesloping.placeEntrust(e2);
%
entrusts_govtbond_curvesloping.push(e1);
entrusts_govtbond_curvesloping.push(e2);



%%
% cancel all pending entrust associated with the instrument itself
withdrawpendingentrusts(c_govtbond_curvesloping,bnd_5y.code_ctp);
%%
withdrawpendingentrusts(c_govtbond_curvesloping,bnd_10y.code_ctp);