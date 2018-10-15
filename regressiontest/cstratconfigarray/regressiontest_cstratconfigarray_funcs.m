%
filename = 'C:\yangyiran\config\generalconfig.txt';
riskcontrols = cStratConfigArray;
fprintf('load risk control configurations from %s\n',filename);

riskcontrols.loadfromfile('filename',filename);
n = riskcontrols.latest_;

plist = properties(riskcontrols.node_);

np = size(plist,1);
fprintf('display configurations:\n\n');
for i = 1:np
    if strcmpi(plist{i},'instrument_'), continue;end
    fprintf('%25s',plist{i}(1:end-1));
    for j = 1:n
        val = riskcontrols.node_(j).(plist{i});
        valdatatype = class(val);
        if ischar(val)
            fprintf('\t%10s',val);
        elseif strcmpi(valdatatype,'double')
            fprintf('\t%10s',num2str(val));
        end
    end
    fprintf('\n');
end
% load risk control configurations from C:\yangyiran\config\generalconfig.txt
% display configurations:
% 
%                   codectp	    cu1812	    zn1812
%                samplefreq	        5m	        5m
%               pnlstoptype	       ABS	       ABS
%                   pnlstop	    -50000	    -20000
%              pnllimittype	       ABS	       ABS
%                  pnllimit	     50000	     20000
%             bidopenspread	         0	         0
%            bidclosespread	         0	         0
%             askopenspread	         0	         0
%            askclosespread	         0	         0
%                 baseunits	         1	         2
%                  maxunits	         5	        10
%                 autotrade	         0	         0
%        executionperbucket	         1	         1
%     maxexecutionperbucket	         1	         1

%%
% get funcs
fprintf('\ntest getconfigvalue functions...\n');
code = 'cu1812';
fprintf('get risk control configurations of %s...\n',code);
for i = 1:np
    if strcmpi(plist{i},'codectp_'), continue;end
    if strcmpi(plist{i},'instrument_'), continue;end
    fprintf('%25s:',plist{i}(1:end-1));
    val = riskcontrols.getconfigvalue('code',code,'propname',plist{i}(1:end-1));
    valdatatype = class(val);
    if ischar(val)
        fprintf('\t%10s',val);
    elseif strcmpi(valdatatype,'double')
        fprintf('\t%10s',num2str(val));
    end
    fprintf('\n');
end
% test getconfigvalue functions...
% get risk control configurations of cu1812...
%                samplefreq:	        5m
%               pnlstoptype:	       ABS
%                   pnlstop:	    -50000
%              pnllimittype:	       ABS
%                  pnllimit:	     50000
%             bidopenspread:	         0
%            bidclosespread:	         0
%             askopenspread:	         0
%            askclosespread:	         0
%                 baseunits:	         1
%                  maxunits:	         5
%                 autotrade:	         0
%        executionperbucket:	         1
%     maxexecutionperbucket:	         1

%%
% now test with an instrument which is not included in the StratConfigArray
code2check = 'ni1901';
try
    val = riskcontrols.getconfigvalue('code',code2check,'propname','autotrade');
catch e
    fprintf('ERROR:%s\n',e.message);
end
% ERROR:cStratConfigArray:getconfigvalue:config of ni1901 not found
%%
% now test with a configuration property that is not inlcluded in
% cStratConfig
try
    val = riskcontrols.getconfigvalue('code',code,'propname','weight');
catch e
    fprintf('ERROR:%s\n',e.message);
end
% ERROR:cStratConfigArray:getconfigvalue:No appropriate method, property, or field weight_ for class cStratConfig.

