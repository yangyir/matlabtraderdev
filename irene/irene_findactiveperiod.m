function [datefrom,dateto] = irene_findactiveperiod(varargin)
%
p = inputParser;
p.KeepUnmatched = true;p.CaseSensitive = false;
p.addParameter('code','',@ischar);
p.addParameter('frequency','30m',@ischar);
p.parse(varargin{:});

code = p.Results.code;
freq = p.Results.frequency;

[~,resstruct_i] = charlotte_loaddata('futcode',code,'frequency',freq);
dtstart = getlastbusinessdate(resstruct_i.px(1,1));
dtsend = getlastbusinessdate(resstruct_i.px(end,1));
if isfx(code)
    datefrom = dtstart;
    dateto = dtsend;
    return
else
    dts = gendates('fromdate',dtstart,'todate',dtsend);
    for i = 1:length(dts)
        fn_i = [getenv('datapath'),'activefutures\activefutures_',datestr(dts(i),'yyyymmdd'),'.txt'];
        data_i = cDataFileIO.loadDataFromTxtFile(fn_i);
        found_i = sum(strcmpi(data_i,code)) > 0;
        if found_i
            datefrom = dts(i);
            break
        end
    end
    %
    for j = i+1:length(dts)
        fn_j = [getenv('datapath'),'activefutures\activefutures_',datestr(dts(j),'yyyymmdd'),'.txt'];
        data_j = cDataFileIO.loadDataFromTxtFile(fn_j);
        dateto = dts(j);
        if sum(strcmpi(data_j,code)) == 0
            dateto = dts(j-1);
            break
        end
    end
    %
end


end