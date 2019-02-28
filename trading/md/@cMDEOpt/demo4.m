mdeopt = cMDEOpt;
underliercode = 'cu1904';
nstrikes = 7;
[c,p] = mdeopt.loadoptions(underliercode,nstrikes);
%%
mdeopt.login('connection','ctp','countername','ccb_ly_fut');
mdeopt.start;
counter = CounterCTP.ccb_ly_fut;
counter.login;
%% query positions
cw_exist = zeros(size(c));
pw_exist = zeros(size(p));
for i = 1:size(c,1)
    [pos,ret] = counter.queryPositions(c{i}.code_ctp);
    if ret
        cw_exist(i) = pos.total_position * pos.direction;
    end
    [pos,ret] = counter.queryPositions(p{i}.code_ctp);
    if ret
        if length(pos) > 0
            for j = 1:length(pos)
                if pos(j).direction > 0
                    pw_exist(i) = pos(j).total_position * pos(j).direction;
                end
            end
        else
            pw_exist(i) = pos.total_position * pos.direction;
        end
        
    end
end
%%
cw_exist = [0;0;0;3;1;-2;-1];
pw_exist = [0;0;2;2;0;0;0];
portfolio_exist = [c;p];
weights_exist = [cw_exist;pw_exist];
greeks_exist = mdeopt.getportfoliogreeks(portfolio_exist,weights_exist)

%%
cw = [0;0;0;0;1;0;0];
pw = [0;0;0;1;0;0;0];
portfolio = [c;p];
weights = [cw+cw_exist;pw+pw_exist];
greeks = mdeopt.getportfoliogreeks(portfolio,weights)

%%
entrusts = EntrustArray;
for i = 1:size(cw,1);
    if cw(i) ~= 0
        e = Entrust;
        qc = mdeopt.qms_.getquote(c{i});
        if cw(i) > 0
            cprice = qc.ask1;
        else
            cprice = qc.bid1;
        end
        e.fillEntrust(1,c{i}.code_ctp,cw(i),cprice,abs(cw(i)),1,c{i}.code_ctp);
        e.multiplier = c{i}.contract_size;
        entrusts.push(e);
    end
end
%
for i = 1:size(pw,1);
    if pw(i) ~= 0
        e = Entrust;
        qp = mdeopt.qms_.getquote(p{i});
        if pw(i) > 0
            pprice = qp.ask1;
        else
            pprice = qp.bid1;
        end
        e.fillEntrust(1,p{i}.code_ctp,pw(i),pprice,abs(pw(i)),1,p{i}.code_ctp);
        e.multiplier = p{i}.contract_size;
        entrusts.push(e);
    end
end
%%
nentrust = entrusts.latest;
for ientrust = 1:nentrust
    counter.placeEntrust(entrusts.node(ientrust));
end
%%
port_pnltotal = 0;
port_pnltheta = 0;
port_pnldelta = 0;
port_pnlgamma = 0;
port_pnlvega = 0;
port_pnlunexplained = 0;


quotes = mdeopt.qms_.getquote;
for i = 1:size(c,1)
    if cw_exist(i) ~= 0
        pnlbreakdown = opt_pnlbreakdown_rt(c{i},quotes,cw_exist(i));
        port_pnltotal = port_pnltotal + pnlbreakdown.pnltotal;
        port_pnltheta = port_pnltheta + pnlbreakdown.pnltheta;
        port_pnldelta = port_pnldelta + pnlbreakdown.pnldelta;
        port_pnlgamma = port_pnlgamma + pnlbreakdown.pnlgamma;
        port_pnlvega = port_pnlvega + pnlbreakdown.pnlvega;
        port_pnlunexplained = port_pnlunexplained + pnlbreakdown.pnlunexplained;
    end
    if pw_exist(i) ~= 0
        pnlbreakdown = opt_pnlbreakdown_rt(p{i},quotes,pw_exist(i));
        port_pnltotal = port_pnltotal + pnlbreakdown.pnltotal;
        port_pnltheta = port_pnltheta + pnlbreakdown.pnltheta;
        port_pnldelta = port_pnldelta + pnlbreakdown.pnldelta;
        port_pnlgamma = port_pnlgamma + pnlbreakdown.pnlgamma;
        port_pnlvega = port_pnlvega + pnlbreakdown.pnlvega;
        port_pnlunexplained = port_pnlunexplained + pnlbreakdown.pnlunexplained;
    end
end
greeks_exist = mdeopt.getportfoliogreeks(portfolio_exist,weights_exist);
fprintf('\nreal-time pnl and risk breakdown:\n');
fprintf('%10s:%8.0f\n','pnltotal',port_pnltotal);
fprintf('%10s:%8.0f\n','pnltheta',port_pnltheta);
fprintf('%10s:%8.0f\n','pnldelta',port_pnldelta);
fprintf('%10s:%8.0f\n','pnlgamma',port_pnlgamma);
fprintf('%10s:%8.0f\n','pnlvega',port_pnlvega);
fprintf('%10s:%8.0f\n','pnlother',port_pnlunexplained);
%
fprintf('%10s:%8.1fk\n','risktheta',greeks_exist.theta/1000);
fprintf('%10s:%8.1fk\n','riskdelta',greeks_exist.deltacarry/1000);
fprintf('%10s:%8.1fk\n','riskgamma',greeks_exist.gammacarry/1000);
fprintf('%10s:%8.1fk\n','pnlvega',greeks_exist.vegacarry/1000);
fprintf('\n');
%%
mdeopt.plotvolslice('cu1904',7);



