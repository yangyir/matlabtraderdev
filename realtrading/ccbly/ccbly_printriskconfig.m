%
% fprintf('runing ''ccbly_printriskconfig''...\n')
%

riskconfigs2check = cStratConfigArray;
%
if ~exist('ccbly_path','var'), ccbly_init; end
%
if strcmpi(ui_stratname,'manual')
    configfile2mod = ccbly_riskconfigfilename_manual;
elseif strcmpi(ui_stratname,'batman')
    configfile2mod = ccbly_riskconfigfilename_batman;
elseif strcmpi(ui_stratname,'wlpr')
    if exist('ui_wrmode','var')
        if strcmpi(ui_wrmode,'classic')
            configfile2mod = ccbly_riskconfigfilename_wlprclassic;
        elseif strcmpi(ui_wrmode,'flash')
            configfile2mod = ccbly_riskconfigfilename_wlprflash;
        elseif strcmpi(ui_wrmode,'reverse')
            configfile2mod = ccbly_riskconfigfilename_wlprreverse;
        end
    else
        configfile2mod = ccbly_riskconfigfilename_wlpr;
    end
elseif strcmpi(ui_stratname,'wlprbatman')
    configfile2mod = ccbly_riskconfigfilename_wlprbatman;
else
    if isempty(ui_stratname)
        error('ERROR:ccb_setup:blank stratey name input!!!');
    else
        error('ERROR:ccb_setup:%s is not a valid stratey name!!!',ui_stratname);
    end
end
riskconfigs2check.loadfromfile('filename',configfile2mod);
n = riskconfigs2check.latest_;
if n > 0
    proplist = properties(riskconfigs2check.node_(1));
end

fprintf('existing risk configurations...\n');
for i = 1:size(proplist,1)
    if strcmpi(proplist{i},'instrument_'), continue; end
    if strcmpi(proplist{i},'name_'), continue; end
    if strcmpi(proplist{i},'use_')
        fprintf('%25s',upper(proplist{i}(1:end-1)));
    else
        fprintf('%25s',proplist{i}(1:end-1));
    end
    for j = 1:n
        val = riskconfigs2check.node_(j).(proplist{i});
        if isnumeric(val)
            fprintf('%15s',num2str(val));
        else
            fprintf('%15s',val);
        end
    end
    fprintf('\n');
end



clear i j n val proplist