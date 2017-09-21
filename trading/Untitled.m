%% 
%load option portfolio
fn_ = 'opt_pos_20170920';
p = opt_loadpositions(fn_);

%%
pnltotal = 0;
pnltheta = 0;
pnldelta = 0;
pnlgamma = 0;
pnlvega = 0;
pnlunexplained = 0;
for i = 1:p.count
    output = pnlbreakdown1(p.instrument_list{i},'2017-09-21',p.instrument_volume(i));
    pnltotal = pnltotal + output.pnltotal;
    pnltheta = pnltheta + output.pnltheta;
    pnldelta = pnldelta + output.pnldelta;
    pnlgamma = pnlgamma + output.pnlgamma;
    pnlvega = pnlvega + output.pnlvega;
    pnlunexplained = pnlunexplained + output.pnlunexplained;
end



