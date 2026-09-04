function [] = gen_condsignals_empirical(obj,varargin)
% a cFORM private function
% to generate conditional signals with input kelly tables
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('kellytables',[],@isstruct);
    p.addParameter('datefrom','',@ischar);
    p.addParameter('dateto','',@ischar);
    p.addParameter('override',0,@isnumeric);
    p.parse(varargin{:});
    strattable = p.Results.kellytables;
    dt1str = p.Results.datefrom;
    dt2str = p.Results.dateto;
    overrideflag = p.Results.override;

    genflag = false;
    if overrideflag
        genflag = true;
    else
        if isempty(obj.condsignals_empirical_)
            genflag = true;
        end
    end

    if ~genflag
        fprintf('gen_condsignals_empirical:done...\n')
        return
    end

    if ~isempty(dt1str)
        dt1num = datenum([dt1str,' 00:00:00'],'yyyy-mm-dd HH:MM:SS');
    else
        dt1num = [];
    end
    
    if ~isempty(dt2str)
        dt2num = datenum([dt2str,' 00:00:00'],'yyyy-mm-dd HH:MM:SS');
    else
        dt2num = [];
    end

    ncodes = size(obj.codes_,1);

    condsignals = cell(ncodes,1);
    instruments_ = obj.instruments_;
    ei = obj.ei_signal_;
    nfractal = charlotte_freq2nfractal(obj.signal_freq_);

    parfor i = 1:ncodes
        fut_i = instruments_{i};
        ei_i = ei{i};
        nbars_i = size(ei_i.px,1);
        condsignals_i = cell(nbars_i,2);
        for j = 1:nbars_i
            t_j = ei_i.px(j,1);
            if ~isempty(dt1num)
                if t_j < dt1num, continue;end
            end
            if ~isempty(dt2num)
                if t_j > dt2num, continue;end
            end

            ei_ij = fractal_truncate(ei_i,j);
            signal = fractal_signal_conditional2('extrainfo',ei_ij,...
                'ticksize',fut_i.tick_size,...
                'nfractal',nfractal,...
                'kellytables',strattable,...
                'assetname',fut_i.asset_name,...
                'ticksizeratio',1);
            if ~isempty(signal)
                condsignals_i{j,1} = signal.directionkellied;
                condsignals_i{j,2} = signal; 
            end
        end
        condsignals{i} = condsignals_i;
    end
    
    obj.condsignals_empirical_ = condsignals;

    fprintf('gen_condsignals_empirical:done...\n')

end