n = size(tbl_output,1);
idx2keep = ones(n,1);
for i = 1:n
    if isempty(tbl_output{i,14}) || isempty(tbl_output{i,20})
        idx2keep(i) = 0;
    end
end
idx2keep = logical(idx2keep);

opendatetime = tbl_output(idx2keep,13);opendatetime = cell2mat(opendatetime);
codes = tbl_output(idx2keep,14);
openid = tbl_output(idx2keep,15);openid = cell2mat(openid);
openprice = tbl_output(idx2keep,17);openprice = cell2mat(openprice);
pnlrel = tbl_output(idx2keep,18);pnlrel = cell2mat(pnlrel);
closeid = tbl_output(idx2keep,20);closeid = cell2mat(closeid);

opennotional = openprice;
for i = 1:size(codes,1)
    fut = code2instrument(codes{i});
    opennotional(i) = openprice(i) * fut.contract_size;
end
opendate =  floor(opendatetime);
tbl2report = table(codes,openid,opendatetime,opendate,openprice,opennotional,pnlrel,closeid);
tbl2report = sortrows(tbl2report,'opendatetime','ascend');
%%
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
files = dir(activefuturesdir);
nfiles = size(files,1);

for i = 1:size(tbl2report.opendate,1)
    futfilename = ['activefutures_',datestr(tbl2report.opendate(i),'yyyymmdd'),'.txt'];
    flag = false;
    for j = 1:nfiles
        if strcmpi(futfilename,files(j).name)
            flag = true;
            break
        end
    end
    if flag
        
    end
end


