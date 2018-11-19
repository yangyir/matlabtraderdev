underlier = 'cu1901';
cobdate = getlastbusinessdate;
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


    