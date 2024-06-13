asset = 'aluminum';
dtfrom = '2024-05-27';
[tblout,kellyout,tblout_notused] = charlotte_kellycheck('assetname',asset,...
    'datefrom',dtfrom,...
    'frequency','intraday',...
    'reportunused',true);
open tblout;
open kellyout;
open tblout_notused;
%
[tblpnl,tblout2,statsout] = charlotte_gensingleassetprofile('assetname',asset);
open tblout2;
open statsout;
set(0,'defaultfigurewindowstyle','docked');
timeseries_plot([tblpnl.dts,tblpnl.runningnotional],'figureindex',2,'dateformat','yy-mmm-dd','title',asset);
timeseries_plot([tblpnl.dts,tblpnl.runningrets],'figureindex',3,'dateformat','yy-mmm-dd','title',asset);
%%
code = tblout2.code{end};
[tblb_headers,tblb_data,~,tbls_data,data] = fractal_gettradesummary(code,...
    'frequency','intraday',...
    'usefractalupdate',0,...
    'usefibonacci',1,...
    'direction','both');
%%
charlotte_plot('futcode','TL2409','figureindex',3,'datefrom','2024-05-24');
%%
assetlist = {'copper';'aluminum';'zinc';'lead';'nickel';'tin'};
nasset = length(assetlist);
tblpnlcell = cell(nasset,1);
for i = 1:nasset
    [tblpnlcell{i},~,~] = charlotte_gensingleassetprofile('assetname',assetlist{i});
end
