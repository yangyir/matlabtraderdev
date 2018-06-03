%note:
%run through different assets and check the volume,open interest and volume
%by RMB notional
[AssetName,type_list,bcode_list] = getassetmaptable;
%%
if ~(exist('c','var') && isa(c,'blp'))
    c = bbgconnect;
end
%%
n = size(AssetName,1);
report = cell(n,6);
for i = 1:n
    if strcmpi(type_list{i},'eqindex')
        check = getdata(c,[bcode_list{i},'1 Index'],{'volume','open_int','fut_val_pt','px_last'});
    else
        check = getdata(c,[bcode_list{i},'1 Comdty'],{'volume','open_int','fut_val_pt','px_last'});
    end
    report{i,1} = AssetName{i};%asset name
    report{i,2} = check.volume;%成交量
    report{i,3} = check.open_int;%持仓量
    report{i,4} = str2double(check.fut_val_pt{1});%合约乘数
    report{i,5} = check.px_last;%最新收盘价
    report{i,6} = report{i,4}*report{i,5}*report{i,2};%交易额
end
Notional = cell2mat(report(:,6));
%
%sort report by Notional
temp = zeros(n,2);
for i = 1:n,temp(i,1) = Notional(i);temp(i,2) = i;end
temp2 = sortrows(temp);
report_final = cell(n,6);
for i = 1:n
    report_final{i,1} = report{temp2(n-i+1,2),1};
    report_final{i,2} = report{temp2(n-i+1,2),2};
    report_final{i,3} = report{temp2(n-i+1,2),3};
    report_final{i,4} = report{temp2(n-i+1,2),4};
    report_final{i,5} = report{temp2(n-i+1,2),5};
    report_final{i,6} = report{temp2(n-i+1,2),6};
end
AssetName = report_final(:,1);
Volume = cell2mat(report_final(:,2));
OpenInterest = cell2mat(report_final(:,3));
ContractSize = cell2mat(report_final(:,4));
LastPrice = cell2mat(report_final(:,5));
Notional = cell2mat(report_final(:,6));
report_table = table(AssetName,Volume,OpenInterest,ContractSize,LastPrice,Notional);
%%
%save file to excel
filename = ['market_volume_report_',datestr(getlastbusinessdate,'yyyymmdd'),'.xlsx'];
dirname = [getenv('OneDrive'),'\trading\market_volume_reports\'];
fprintf('write market volume report to excel file %s......\n',filename);
writetable(report_table,[dirname,filename],'Sheet',1,'Range','A1');

%%
% str = sprintf('%15s%12s%12s%15s%13s%19s\n','Asset','Volume','OpenInt','ContractSize','LastPrice','Notional');
% for i = 1:n
% str = sprintf('%s%15s%12s%12s%15s%13s%19s\n',str,report_final{i,1},num2str(report_final{i,2}),...
%     num2str(report_final{i,3}),num2str(report_final{i,4}),...
%     num2str(report_final{i,5}),num2str(report_final{i,6}));
% end
% str = sprintf('%s\n',str);
% str = sprintf('%s\n%s\n',str,['report saved in ',dirname,filename]);
%%
%send email
to = '179024809@qq.com';
subject = 'market volume report 20180601';
body = 'hi,please check the report as attached!';
sendolmail(to,subject,body,{[dirname,filename]});