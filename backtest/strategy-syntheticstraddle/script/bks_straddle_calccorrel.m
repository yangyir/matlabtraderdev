% the long synthetic straddle sequential(LSSS) strategy performs well when
% the underlier is trending, but it could keep loosing money if the market
% is fluctuate over the time. In order to improve the performace of LSSS,
% different underliers with long correlation between each other shall be
% choosen.....
%
% below the correlation matrix with one year time horizon is computed, the
% following underlier are sampled for this calculation
% equity index: eqindex_300, eqindex_50, eqindex_500
% govt bond: govtbond_10y
% precious metals:gold,silver
% energy:crude oil,PTA,methanol
% base metals:copper,aluminum,zinc,nickel
% industrial:iron ore,deformed bar,rubber
% agriculture:sugar,palm oil,corn
asset_list={'eqindex_300';'eqindex_50';'eqindex_500';...
            'govtbond_10y';...
            'gold';'silver';...
            'copper';'aluminum';'zinc';'nickel';...
            'pta';'methanol';'crude oil';...
            'sugar';'corn';'palm oil';...
            'rubber';'deformed bar';'iron ore'};
nasset = length(asset_list);
rollinfo = cell(nasset,1);
pxoidata = cell(nasset,1);
for i = 1:nasset
    [rollinfo{i},pxoidata{i}] = bkfunc_genfutrollinfo(asset_list{i});
end
%%
i = 10;
[x,y] = bkfunc_genfutrollinfo(asset_list{i});
x