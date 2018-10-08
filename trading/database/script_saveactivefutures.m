%%
c = bbgconnect;
%%
instrument_list = {'eqindex_300';'eqindex_50';'eqindex_500';'govtbond_5y';'govtbond_10y';...
    'gold';'silver';...
    'copper';'aluminum';'zinc';'lead';'nickel';...
    'crude oil';'pta';'lldpe';'pp';'methanol';......
    'deformed bar';'iron ore';
    'soymeal';'sugar';'corn';'rubber';'apple'};
n = size(instrument_list,1);
ctpcode_list = cell(n,1);
for i = 1:n
    info = getassetinfo(instrument_list{i});
    if strcmpi(instrument_list{i},'eqindex_300') ||...
            strcmpi(instrument_list{i},'eqindex_50') ||...
            strcmpi(instrument_list{i},'eqindex_500')
        sec = [info.BloombergCode,'A Index'];
    else
        sec = [info.BloombergCode,'A Comdty'];
    end
    data = c.getdata(sec,'parsekyable_des');
    ctpcode_list{i} = bbg2ctp(data.parsekyable_des{1});
    
    
end
%%
startdt = '2018-06-01';
enddt = '2018-09-28';
busdays = gendates('fromdate',startdt,'todate',enddt);
nbds = size(busdays,1);
activefutlist = cell(nbds,1);
for i = 1:nbds
    list_i = cell(n,1);
    for j = 1:n
        list_i{j} = getactivefutures(c,instrument_list{j},'date',busdays(i));
    end
    activefutlist{i} = list_i;
end
%%
for i = 1:nbds
    fn = ['c:\yangyiran\activefutures\','activefutures_',datestr(busdays(i),'yyyymmdd'),'.txt'];
    fid = fopen(fn,'w');
    data = activefutlist{i};
    for j = 1:size(data,1)
        fprintf(fid,'%s\n',data{j});
    end
    
    fclose(fid);
end


%%
d = cDataFileIO.loadDataFromTxtFile(fn);

    
