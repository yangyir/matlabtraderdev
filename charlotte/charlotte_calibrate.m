function [strat_new, tbltrades] = charlotte_calibrate(varargin)

p = inputParser;
p.CaseSensitive = false;p.KeepUnmatched = true;
p.addParameter('codes',{},@iscell);
p.addParameter('frequency','',@ischar);
p.addParameter('nfractal',2,@isnumeric);

p.parse(varargin{:});
codes = p.Results.codes;
frequency = p.Results.frequency;
nfractal = p.Results.nfractal;

ncodes = size(codes,1);

outputs = cell(ncodes,1);
strat_indivual = cell(ncodes,1);
tbltrades = cell(ncodes,1);
for i = 1:ncodes
    outputs{i} = fractal_kelly_summary('codes',codes(i),...
        'frequency',frequency,...
        'usefractalupdate',0,...
        'usefibonacci',1,...
        'direction','both',...
        'nfractal',nfractal);
    [~,~,tbltrades{i},~,~,~,~,strat_indivual{i}] = kellydistributionsummary(outputs{i});

end

'haha';
% now combine each table together
% we just use for the special modes 
% bmtc,bstc;
% smtc,sstc;
% breachuplvlup_tb,breachdnlvldn_tb;
% breachupsshighvalue_tb,breachdnbshighvalue_tb;
% breachuplvlup_tc,breachdnlvldn_tc;
% breachupsshighvalue_tc,breachdnbshighvalue_tc;
% breachuphighsc13,breachdnlowbc13;
asset = codes;
tablenames = {'bmtc';'bstc';...
    'smtc';'sstc';...
    'breachuplvlup_tb';'breachdnlvldn_tb';...
    'breachupsshighvalue_tb';'breachdnbshighvalue_tb';...
    'breachuplvlup_tc';'breachdnlvldn_tc';...
    'breachupsshighvalue_tc';'breachdnbshighvalue_tc';...
    'breachuphighsc13';'breachdnlowbc13'};
tables = cell(size(tablenames,1),1);
%
for itable = 1:size(tablenames,1)
    tablename_i = tablenames{itable};
    N = zeros(ncodes,1);
    W = N;R = N;K = N;winavg = N;lossavg = N;
    for i = 1:ncodes
        try
            N(i) = strat_indivual{i}.(tablename_i).N(1);
            W(i) = strat_indivual{i}.(tablename_i).W(1);
            R(i) = strat_indivual{i}.(tablename_i).R(1);
            K(i) = strat_indivual{i}.(tablename_i).K(1);
            winavg(i) = strat_indivual{i}.(tablename_i).winavg(1);
            lossavg(i) = strat_indivual{i}.(tablename_i).lossavg(1);
        catch
        end
    end
    tables{itable} = table(asset,N,W,R,K,winavg,lossavg);
end
%


% for other modes, we use:
% kelly_matrix_l,kelly_matrix_s;
% winprob_matrix_l, winprob_matrix_s;
% signal_l,signal_s;
% asset_list
assetlist = asset';
% first to combine signal modes
signal_l = strat_indivual{1}.signal_l;
signal_s = strat_indivual{1}.signal_s;
for i = 2:ncodes
    temp_l = [signal_l;strat_indivual{i}.signal_l];
    signal_l = temp_l;
    temp_s = [signal_s;strat_indivual{i}.signal_s];
    signal_s = temp_s;
end
signal_l = unique(signal_l);
signal_s = unique(signal_s);

kelly_matrix_l = zeros(size(signal_l,1),ncodes);
winprob_matrix_l = kelly_matrix_l;

kelly_matrix_s = zeros(size(signal_s,1),ncodes);
winprob_matrix_s = kelly_matrix_s;

for i = 1:size(signal_l,1)
    for j = 1:ncodes
        idx_ij = strcmpi(strat_indivual{j}.signal_l,signal_l{i});
        k_ij = strat_indivual{j}.kelly_matrix_l(idx_ij);
        p_ij = strat_indivual{j}.winprob_matrix_l(idx_ij);
        if ~isempty(k_ij)
            if k_ij == -inf
                k_ij = -9.99;
            end
            kelly_matrix_l(i,j) = k_ij;
            winprob_matrix_l(i,j) = p_ij;
        else
            kelly_matrix_l(i,j) = 0;
            winprob_matrix_l(i,j) = 0;
        end
    end
end

for i = 1:size(signal_s,1)
    for j = 1:ncodes
        idx_ij = strcmpi(strat_indivual{j}.signal_s,signal_s{i});
        k_ij = strat_indivual{j}.kelly_matrix_s(idx_ij);
        p_ij = strat_indivual{j}.winprob_matrix_s(idx_ij);
        if ~isempty(k_ij)
            if k_ij == -inf
                k_ij = -9.99;
            end
            kelly_matrix_s(i,j) = k_ij;
            winprob_matrix_s(i,j) = p_ij;
        else
            kelly_matrix_s(i,j) = 0;
            winprob_matrix_s(i,j) = 0;
        end
    end
end


strat_new = struct;
for itable = 1:size(tablenames,1)
    strat_new.(tablenames{itable}) = tables{itable};
end

strat_new.kelly_matrix_l = kelly_matrix_l;
strat_new.winprob_matrix_l = winprob_matrix_l;
strat_new.kelly_matrix_s = kelly_matrix_s;
strat_new.winprob_matrix_s = winprob_matrix_s;
strat_new.signal_l = signal_l;
strat_new.signal_s = signal_s;
strat_new.asset_list = assetlist;


end