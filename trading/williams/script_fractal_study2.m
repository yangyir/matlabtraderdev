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
opendate = opendatetime;
for i = 1:size(codes,1)
    fut = code2instrument(codes{i});
    opennotional(i) = openprice(i) * fut.contract_size;
    opendate(i) = getlastbusinessdate(opendatetime(i));
end
tbl2report = table(codes,openid,opendatetime,opendate,openprice,opennotional,pnlrel,closeid);
tbl2report = sortrows(tbl2report,'opendatetime','ascend');
%%
activefuturesdir = [getenv('DATAPATH'),'activefutures\'];
files = dir(activefuturesdir);
nfiles = size(files,1);

opendateunique = unique(tbl2report.opendate);
% assume the margin rate is 0.1 and the notional allocated per asset is
% 500k(half million)
marginrate = 0.1;
notionalperasset = 8*1e5;
notionalused = zeros(size(opendateunique,1),1);
ntrades = notionalused;
ntradesused = notionalused;
marginused = notionalused;

tradeonlyactive = true;

%
for i = 1:size(opendateunique,1)
    futfilename = ['activefutures_',datestr(opendateunique(i),'yyyymmdd'),'.txt'];
    flag = false;
    for j = 1:nfiles
        if strcmpi(futfilename,files(j).name)
            flag = true;
            break
        end
    end
    if flag
        tblidx = tbl2report.opendate == opendateunique(i);
        tbl_i = tbl2report(tblidx,:);
        codes_i = tbl_i.codes;
        ntrades(i) = size(codes_i,1);
        ntradesused(i) = 0;
        notionalused(i) = 0;
        if tradeonlyactive
            futlist_i = cDataFileIO.loadDataFromTxtFile([activefuturesdir,futfilename]);
            for k = 1:size(codes_i,1)
                foundflag = false;
                for kk = 1:size(futlist_i,1)
                    if strcmpi(codes_i{k},futlist_i{kk})
                        foundflag = true;
                        break
                    end
                end
                if foundflag
                    ntradesused(i) = ntradesused(i) + 1;
                    if notionalperasset < tbl_i.opennotional(k)
                        ntradesused(i) = ntradesused(i) - 1;
                        fprintf('%s:notional allocated per asset is insufficient to %s....\n',datestr(opendateunique(i),'yyyymmdd'),codes_i{k});
                    end
                    notionalused(i) = notionalused(i) + floor(notionalperasset/tbl_i.opennotional(k))*tbl_i.opennotional(k);
                end
            end
        else
            ntradesused(i) = size(codes_i,1);
            for k = 1:size(codes_i,1)
                if notionalperasset < tbl_i.opennotional(k)
                    ntradesused(i) = ntradesused(i) - 1;
                    fprintf('%s:notional allocated per asset is insufficient to %s....\n',datestr(opendateunique(i),'yyyymmdd'),codes_i{k});
                end 
                notionalused(i) = notionalused(i) + floor(notionalperasset/tbl_i.opennotional(k))*tbl_i.opennotional(k);
            end
            
        end
        marginused(i) = notionalused(i)*marginrate;
    else
%         fprintf('list of active futures was not found on %s\n',datestr(opendateunique(i),'yyyymmdd'));
    end
end
tblnotionalsummary = table(opendateunique,ntrades,ntradesused,notionalused,marginused);
%%
dt1 = '2018-04-10';
dt2 = datestr(getlastbusinessdate,'yyyy-mm-dd');
dts = gendates('fromdate',dt1,'todate',dt2,'frequency','daily');

