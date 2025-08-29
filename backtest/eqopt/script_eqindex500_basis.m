% eqindex_500
% index intraday data
eqindex_folder = [getenv('onedrive'),'\matlabdev\equity\000905\'];
eqetf_folder = [getenv('onedrive'),'\matlabdev\equity\510500\'];
eqindex_m1 = load([eqindex_folder,'000905_1m.mat']);
eqindex_data = eqindex_m1.data;
%
eqetf_m1 = load([eqetf_folder,'510500_1m.mat']);
eqetf_data = eqetf_m1.data;
[t,idx1,idx2] = intersect(eqindex_data(:,1),eqetf_data(:,1));
eqindex_etf_data = [t,eqindex_data(idx1,2:5),eqetf_data(idx2,2:5)];
%
date_mat = floor(t);
dateunique_mat = unique(date_mat);
ndate = length(dateunique_mat);
basis_data_cell = cell(ndate,1);
fut_cell = cell(ndate,3);

for i = 1:ndate
    fn_i = [getenv('datapath'),'activefutures\activefutures_',datestr(dateunique_mat(i),'yyyymmdd'),'.txt'];
    futlist_i = cDataFileIO.loadDataFromTxtFile(fn_i);
    futcode_i = futlist_i{3};
    fut_cell{i,1} = dateunique_mat(i);
    fut_cell{i,2} = futcode_i;
    fut_i = code2instrument(futcode_i);
    ltd_i = fut_i.last_trade_date1;
    if ltd_i - dateunique_mat(i) <= 3
        %need to find next futures as the current one is about to expire in
        %three days
        fut_cell{i,3} = getnextfuts(futcode_i);
    else
       fut_cell{i,3} = futcode_i;
    end
end
    %%
for i = 1:ndate  
    fn2_i = [getenv('datapath'),'intradaybar\',fut_cell{i,2},'\',fut_cell{i,2},'_',datestr(fut_cell{i,1},'yyyymmdd'),'_1m.txt'];
    futdata_i = cDataFileIO.loadDataFromTxtFile(fn2_i);
    eq_i = eqindex_etf_data(date_mat == fut_cell{i,1},:);
    [t,idx1,idx2] = intersect(eq_i(:,1),futdata_i(:,1));
    basis_data_cell{i} = [floor(t),t,eq_i(idx1,5),futdata_i(idx2,5),eq_i(idx1,5)-futdata_i(idx2,5)];
end

%%
basis_data_mat = cell2mat(basis_data_cell);
n = size(basis_data_mat,1);
cobdate = basis_data_mat(:,1);
datetime = basis_data_mat(:,2);
idxprice = basis_data_mat(:,3);
futprice = basis_data_mat(:,4);
basis = basis_data_mat(:,5);
currentfuts = cell(n,1);
usedfuts = cell(n,1);
for i = 1:n
    currentfuts{i} = fut_cell{dateunique_mat == cobdate(i),2};
    usedfuts{i} = fut_cell{dateunique_mat == cobdate(i),3};
end
basis_data_table = table(cobdate,datetime,idxprice,futprice,basis,currentfuts,usedfuts);
%%
futs_selected = 'IC2208';

idx_selected = strcmpi(basis_data_table.currentfuts,futs_selected) & ...
    strcmpi(basis_data_table.usedfuts,futs_selected);
basis_data_table_selected = basis_data_table(idx_selected,:);
%%
number1 = 5;number2 = 30;
ma1 = movavg(basis_data_table_selected.basis,'exponential',number1);
ma2 = movavg(basis_data_table_selected.basis,'exponential',number2);
plot(ma1,'r');hold on;
plot(ma2,'b');hold off;
%%
check = timeseries_compress([basis_data_table_selected.datetime,basis_data_table_selected.basis],...
    'tradinghours','09:30-11:30;13:00-15:00',...
    'tradingbreak','',...
    'frequency','5m');
[checkmat,checkstruct] = tools_technicalplot1(check,2,false);
basis_mid = 0.5*(checkstruct.px(:,3) + checkstruct.px(:,4));
plot(basis_mid,'r');