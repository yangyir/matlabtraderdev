function timeseries_update(contract,varargin)
%function to update timeseries from bloomberg server
%required input variable is a cContract object
%optional input variable is the flag to control whether tick data is
%updated or not
p = inputParser;p.CaseSensitive = false;p.KeepUnmatched = true;
p.addRequired('Contract',@(x)validateattributes(x,{'cContract'},{},'','Contract'));
p.addParameter('TickUpdateFlag',true,...
    @(x)validateattributes(x,{'logical'},{},'','TickUpdateFlag'));
p.parse(contract,varargin{:});
contract = p.Results.Contract;
tickupdateFlag = p.Results.TickUpdateFlag;

if tickupdateFlag
    freqs = {'1d';'1m';'tick'};
else
    freqs = {'1d';'1m'};
end

expiry = datenum(contract.Expiry);

lastbd = businessdate(today,-1);

cutoffdate = min(expiry,lastbd);

windcode = lower(contract.WindCode);

for i = 1:size(freqs,1)
    try
        tsobj = contract.getTimeSeriesObj('Connection','Bloomberg',...
            'Frequency',freqs{i});
        lastentry = datenum(tsobj.getLastDateEntry);
        if lastentry < cutoffdate
            fprintf(['updating ',windcode,' ',freqs{i},' data......\n']);
            tsobjs = contract.updateTimeSeries('Connection','Bloomberg',...
                'Frequency',freqs{i});
            fprintf(['the last date entry of ',windcode,...
                ' ',freqs{i},' data was: ',...
                datestr(lastentry),' and it is ',tsobjs{1}.getLastDateEntry,...
                ' after updating\n']);
        else
            fprintf([windcode,' ',freqs{i},' data is up to date!\n']);
        end
    catch
        contract.initTimeSeries('Connection','Bloomberg',...
            'Frequency',freqs{i},...
            'DataSource','internet');
        tsobj = contract.getTimeSeriesObj('Connection','Bloomberg',...
            'Frequency',freqs{i});
        fprintf(['after initiating the last date entry of ',windcode,...
            ' ',freqs{i},' data is: ',...
            tsobj.getLastDateEntry,'\n']);
        
    end
    
    
end




        