underlier = 'cu1901';
cobdate = getlastbusinessdate;
predate = businessdate(cobdate,-1);
data = cDataFileIO.loadDataFromTxtFile([underlier,'_daily.txt']);
pxclose = data(data(:,1)==datenum(cobdate),end);
if pxclose <= 40000
    bucketsize = 500;
elseif pxclose > 40000 && pxclose < 80000
    bucketsize = 1000;
else
    bucketsize = 2000;
end
neareststrike1 = floor(pxclose/bucketsize)*bucketsize;
neareststrike2 = ceil(pxclose/bucketsize)*bucketsize;
strikes = [neareststrike1-2*bucketsize;neareststrike1-bucketsize;...
    neareststrike1;neareststrike2;neareststrike2+bucketsize;...
    neareststrike2+2*bucketsize];
c = cell(size(strikes));
p = c;
for i = 1:size(strikes,1)
    c{i} = [underlier,'C',num2str(strikes(i))];
    p{i} = [underlier,'P',num2str(strikes(i))];
end

pnlbreakc = cell(size(strikes));
pnlbreakp = pnlbreakc;
for i = 1:size(strikes,1)
    pnlbreakc{i} = pnlriskbreakdown1(c{i},cobdate);
    pnlbreakp{i} = pnlriskbreakdown1(p{i},cobdate);
end
%%
fprintf('\npnl breakdown of calls from %s to %s:\n',datestr(predate,'dd-mmm'),datestr(cobdate,'dd-mmm'));
fprintf('%14s%14s%14s%14s%14s%14s%14s%14s%14s\n','code','totalpnl','thetapnl','deltapnl','gammapnl','vegapnl','unexplained','iv1','iv2');
for i = 1:size(strikes,1)
    fprintf('%14s',c{i});
    fprintf('%14.1f',pnlbreakc{i}.pnltotal);
    fprintf('%14.1f',pnlbreakc{i}.pnltheta);
    fprintf('%14.1f',pnlbreakc{i}.pnldelta);
    fprintf('%14.1f',pnlbreakc{i}.pnlgamma);
    fprintf('%14.1f',pnlbreakc{i}.pnlvega);
    fprintf('%14.1f',pnlbreakc{i}.pnlunexplained);
    fprintf('%14.1f%%',pnlbreakc{i}.iv1*100);
    fprintf('%14.1f%%',pnlbreakc{i}.iv2*100);
    fprintf('\n');
end

fprintf('\npnl breakdown of puts from %s to %s:\n',datestr(predate,'dd-mmm'),datestr(cobdate,'dd-mmm'));
fprintf('%14s%14s%14s%14s%14s%14s%14s%14s%14s\n','code','totalpnl','thetapnl','deltapnl','gammapnl','vegapnl','unexplained','iv1','iv2');
for i = 1:size(strikes,1)
    fprintf('%14s',p{i});
    fprintf('%14.1f',pnlbreakp{i}.pnltotal);
    fprintf('%14.1f',pnlbreakp{i}.pnltheta);
    fprintf('%14.1f',pnlbreakp{i}.pnldelta);
    fprintf('%14.1f',pnlbreakp{i}.pnlgamma);
    fprintf('%14.1f',pnlbreakp{i}.pnlvega);
    fprintf('%14.1f',pnlbreakp{i}.pnlunexplained);
    fprintf('%14.1f%%',pnlbreakp{i}.iv1*100);
    fprintf('%14.1f%%',pnlbreakp{i}.iv2*100);
    fprintf('\n');
end

    




    