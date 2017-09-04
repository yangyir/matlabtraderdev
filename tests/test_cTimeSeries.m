%script to test cTimeSeries class and functions associated to it
%
clc;
fprintf('\nrunning test_cTimeSeries.m......\n');
%%
%1.create a contract object
%contract is 'au1612' which is the gold futures expiring in Dec16 and
%traded in shanghai futures exchange
au1612 = cContract('AssetName','gold','Tenor','1612');
%%
%2.1.create a timeseries object from WIND connection
dateBegin = '19-Sep-2016';
dateEnd = '23-Sep-2016';
intervalDownload = 1;
try
    fprintf('try to create a timeseries object from WIND connection.....\n');
    w = windconnect;
    fields = 'open,high,low,close,volume';
    tsobjConnection = cTimeSeries('Connection',w,...
                            'WindCode',au1612.WindCode,...
                            'Fields',fields,...
                            'FromDate',dateBegin,...
                            'ToDate',dateEnd,...
                            'Frequency',intervalDownload);
catch me
    fprintf([me.message,'\n']);
end
%
%2.2.create a timeseries object from BLOOMBERG connection
answer = who('tsobjConnection');
fprintf('......\n');
if isempty(answer)
    fprintf('wind is not installed on this PC...\n');
    try
        fprintf('try to create a timeseries object from BLOOMBERG connection...\n');
        b = bbgconnect;
        fields = 'trade';
        tsobjConnection = cTimeSeries('Connection',b,...
                                    'BloombergCode',au1612.BloombergCode,...
                                    'Fields',fields,...
                                    'FromDate',dateBegin,...
                                    'ToDate',dateEnd,...
                                    'Frequency',intervalDownload);
    catch me
        fprintf([me.message,'\n']);
    end
end
%%
%3.get timeseries data from the tsobjWind
%filter out data outside trading hours
fprintf('aggregate the timeseries into 15-minutes intraday interval...\n');
intervalDisplay = '15m';
tsData = tsobjConnection.getTimeSeries('Fields','close',...
                                 'FromDate',dateBegin,...
                                 'ToDate',dateEnd,...
                                 'Frequency',intervalDisplay,...
                                 'TradingHours',au1612.TradingHours,...
                                 'TradingBreak',au1612.TradingBreak);
%%
%4.write timeseries data to file
fprintf('save the aggregated timeseries data into local file...\n');
directory = 'C:\Temp';
fileName = 'temptsfile';
fields = 'open,high,low,close,volume';
tsobjConnection.writeTimeSeries2File(...
                                'Directory',directory,...
                                'FileName',fileName,...
                                'Fields',fields,...
                                'FromDate',dateBegin,...
                                'ToDate',dateEnd,...
                                'Frequency',[num2str(intervalDownload),'m'],...
                                'TradingHours',au1612.TradingHours,...
                                'TradingBreak',au1612.TradingBreak);
%%
%5.create a timeseries object from local file saved in the above step
fprintf('create a timeseries object directly from local file...\n');
tsobjFile = cTimeSeries('FileName',[directory,'\',fileName]);
tsDataCheck = tsobjFile.getTimeSeries('Fields','close',...
                                      'FromDate',dateBegin,...
                                      'ToDate',dateEnd,...
                                      'Frequency',intervalDisplay,...
                                      'TradingHours',au1612.TradingHours,...
                                      'TradingBreak',au1612.TradingBreak);
%sanity check
if sum(sum(tsData)-sum(tsDataCheck))~=0
    error('unknown error');
else
    fprintf('sanity check passed\n');
end
%%
%6.update timeseries
fprintf('update the timeseries object with the lastest market data ');
if ~isempty(tsobjConnection.Codes{1})
    fprintf('from BLOOMBERG...\n');
else
    fprintf('from WIND...\n');
end
tsobjConnection = tsobjConnection.updateTimeSeries;
%%
%7.display object properties
fprintf('print results......\n');
fprintf(['   the last date entry of tsobjFile is ',tsobjFile.getLastDateEntry,'\n']);
fprintf(['   the last date entry of tsobWind is ',tsobjConnection.getLastDateEntry,'\n']);
fprintf('done!\n');