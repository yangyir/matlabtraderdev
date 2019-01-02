% modify risk configuration
%
%% user inputs
if ~ui_override || ~exist('ui_override','var')
    ui_stratname = 'manual';
    ui_codes = {'T1903'};
    ui_propnames = {'bidopenspread';'askopenspread'};
    ui_propvalues = {5;5};
end

%%
fprintf('running ''ccbly_modriskconfig''...\n');
%
if ~exist('ccbly_riskconfigfilename_manual','var')
    ccbly_genriskconfig;
end

if strcmpi(ui_stratname,'manual')
    configfile2mod = [ccbly_path_manual,ccbly_riskconfigfilename_manual];
elseif strcmpi(ui_stratname,'batman')
    configfile2mod = [ccbly_path_batman,ccbly_riskconfigfilename_batman];
elseif strcmpi(ui_stratname,'wlpr')
    if exist('ui_wrmode','var')
        if strcmpi(ui_wrmode,'classic')
            configfile2mod = [ccbly_path_wlpr,ccbly_riskconfigfilename_wlprclassic];
        elseif strcmpi(ui_wrmode,'flash')
            configfile2mod = [ccbly_path_wlpr,ccbly_riskconfigfilename_wlprflash];
        elseif strcmpi(ui_wrmode,'reverse')
            configfile2mod = [ccbly_path_wlpr,ccbly_riskconfigfilename_wlprreverse];
        end
    else
        configfile2mod = [ccbly_path_wlpr,ccbly_riskconfigfilename_wlpr];
    end
    
    
elseif strcmpi(ui_stratname,'wlprbatman')
    configfile2mod = [ccbly_path_wlprbatman,ccbly_riskconfigfilename_wlprbatman];
else
    if isempty(ui_stratname)
        error('ERROR:ccb_modriskconfig:blank stratey name input!!!');
    else
        error('ERROR:ccb_modriskconfig:%s is not a valid stratey name!!!',ui_stratname);
    end
end

for i = 1:size(ui_codes,1)
    ifoundflag = false;
    for j = 1:size(ccbly_futs2trade)
        if strcmpi(ui_codes{i},ccbly_futs2trade{j})
            ifoundflag = true;
            break
        end
    end
    if ~ifoundflag
        error('ERROR:ccb_modriskconfig:%s is not in the selected list:%s!!!',...
            ui_codes{i},'change code or run ccbly_chooseinstruments with correct list');
    end
end

for i = 1:size(ui_codes,1)
    ret_i = modconfigfile(configfile2mod,'code',ui_codes{i},...
        'PropNames',ui_propnames,...
        'PropValues',ui_propvalues);
    if ret_i
        fprintf('\trisk configs of %s successfully modified\n',ui_codes{i});
    else
        error('ERROR:ccb_modriskconfig:risk configs of %s failed to be modified!!!',ui_codes{i});
    end
end
%%
clear configfile2mode i j ifoundflag ret_i
