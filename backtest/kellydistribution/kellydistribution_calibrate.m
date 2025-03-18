function [kellytable,tblpnlout,statsout,tbl2checkall] = kellydistribution_calibrate(varargin)
%function to calibrate kellytable
%
p = inputParser; 
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('assetname','',@ischar);
p.addParameter('frequency','',@ischar);
p.parse(varargin{:});

assetname = p.Results.assetname;
freq = p.Results.frequency;
if strcmpi(freq,'5m')
    freqin = 'intraday-5m';
elseif strcmpi(freq,'15m')
    freqin = 'intraday-15m';
elseif strcmpi(freq,'30m')
    freqin = 'intraday';
elseif strcmpi(freq,'daily')
    freqin = 'daily';
else
    error('kellydistribution_calibrate:invalid frequency input')
end

[assets,types,~,codes] = getassetmaptable();

idx = strcmpi(assets,assetname);
thistype = types{idx,1};
thiscode = lower(codes{idx,1});

if ~strcmpi(freq,'daily')
    foldername = [getenv('onedrive'),'\matlabdev\',thistype,'\',thiscode];
    listing = dir(foldername);
    ncodes = 0;
    codes_list = cell(1000,1);
    for i = 3:size(listing,1)
        
        fn_i = listing(i).name;
        if ~isempty(strfind(fn_i,'_5m')) || ~isempty(strfind(fn_i,'_15m')) || ~isempty(strfind(fn_i,'_'))
            continue;
        end
        ncodes = ncodes + 1;
        codes_list{ncodes,1} = fn_i(1:end-4);
    end
    codes_list = codes_list(1:ncodes,:);
    if ncodes == 0
        kellytable = [];
        return;
    end
    thisoutput = fractal_kelly_summary('codes',codes_list,'frequency',freqin,'usefractalupdate',0,'usefibonacci',1,'direction','both');
    %lastest kelly table
    [~,~,~,~,~,~,~,kellytable] = kellydistributionsummary(thisoutput);
else
    error('kellydistribution_calibdate:to be implemented')
end

tbl2check = cell(ncodes,1);
for i = 1:ncodes
    [dt1,dt2] = irene_findactiveperiod('code',codes_list{i});
    if isempty(dt1) || isempty(dt2)
        continue;
    end
    dt1 = datestr(dt1,'yyyy-mm-dd');
    dt2 = datestr(dt2,'yyyy-mm-dd');
    [~,~,tbl2check{i}] = charlotte_backtest_period('code',codes_list{i},'fromdate',dt1,'todate',dt2,'kellytables',kellytable,'showlogs',false,'figureidx',99,'frequency',freq);
    if i == 1
        tbl2checkall = tbl2check{i};
    else
        tmp = [tbl2checkall;tbl2check{i}];
        tbl2checkall = tmp;
    end
end
[tblpnlout,~,statsout] = irene_trades2dailypnl('tradestable',tbl2checkall,'frequency',freq);

end