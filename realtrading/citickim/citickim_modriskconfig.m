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
fprintf('running ''citickim_modriskconfig''...\n');
%
if ~exist('citickim_riskconfigfilename_manual','var')
    citickim_genriskconfig;
end

if strcmpi(ui_stratname,'manual')
    configfile2mod = [citickim_path_manual,citickim_riskconfigfilename_manual];
elseif strcmpi(ui_stratname,'batman')
    configfile2mod = [citickim_path_batman,citickim_riskconfigfilename_batman];
elseif strcmpi(ui_stratname,'wlpr')
    configfile2mod = [citickim_path_wlpr,citickim_riskconfigfilename_wlpr];
elseif strcmpi(ui_stratname,'wlprbatman')
    configfile2mod = [citickim_path_wlprbatman,citickim_riskconfigfilename_wlprbatman];
else
    if isempty(ui_stratname)
        error('ERROR:citickim_modriskconfig:blank stratey name input!!!');
    else
        error('ERROR:citickim_modriskconfig:%s is not a valid stratey name!!!',ui_stratname);
    end
end

for i = 1:size(ui_codes,1)
    ifoundflag = false;
    for j = 1:size(citickim_futs2trade)
        if strcmpi(ui_codes{i},citickim_futs2trade{j})
            ifoundflag = true;
            break
        end
    end
    if ~ifoundflag
        error('ERROR:citickim_modriskconfig:%s is not in the selected list:%s!!!',...
            ui_codes{i},'change code or run citickim_chooseinstruments with correct list');
    end
end

for i = 1:size(ui_codes,1)
    ret_i = modconfigfile(configfile2mod,'code',ui_codes{i},...
        'PropNames',ui_propnames,...
        'PropValues',ui_propvalues);
    if ret_i
        fprintf('\trisk configs of %s successfully modified\n',ui_codes{i});
    else
        error('ERROR:citickim_modriskconfig:risk configs of %s failed to be modified!!!',ui_codes{i});
    end
end
%%
clear configfile2mode i j ifoundflag ret_i
