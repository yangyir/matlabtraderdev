%charllotte run after the m
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
dt1 = getlastbusinessdate;
file1 = ['activefutures_',datestr(dt1,'yyyymmdd'),'.txt'];
futlist1 = cDataFileIO.loadDataFromTxtFile([activefuturesdir,file1]);
nfut = length(futlist1);

for i = 1:nfut
    if strcmpi(futlist1{i}(1:2),'IF'),continue;end
    if strcmpi(futlist1{i}(1:2),'IH'),continue;end
    if strcmpi(futlist1{i}(1:2),'IC'),continue;end
    if strcmpi(futlist1{i}(1:2),'IM'),continue;end
    if strcmpi(futlist1{i}(1:2),'ZC'),continue;end
    
    activefut_hasbreach_intraday(futlist1{i},false);
    
end