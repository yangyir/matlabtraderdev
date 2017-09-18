function [] = opt_savepositions(options,underliers,counter,qms)
    if ~isa(options,'cInstrumentArray')
        error('opt_savepositions:invalid instruments input....')
    end
    
    if ~isa(underliers,'cInstrumentArray')
        error('opt_savepositions:invalid underliers input....')
    end
    
    if ~isa(counter,'CounterCTP')
        error('opt_savepositions:invalid counter input......')
    end
    
    if ~isa(qms,'cQMS')
        error('opt_savepositions:invalid qms input......')
    end
    
    opt_dir_ = [getenv('DATAPATH'),'pos_opt\'];
    try
        cd(opt_dir_);
    catch
        mkdir(opt_dir_);
    end
    
    bd = getlastbusinessdate;
    fn = [opt_dir_,'opt_pos_',datestr(bd,'yyyymmdd'),'.txt'];

    n = options.count;
    list = options.getinstrument;
    
    nu = underliers.count;
    listu = underliers.getinstrument;
    
    fid = fopen(fn,'w');
    
    %options
    for i = 1:n
        code_i = list{i}.code_ctp;
        [pos_i,ret_i] = counter.queryPositions(code_i);
        if ~ret_i, continue; end
        p_i = pos_i.direction*pos_i.total_position;
        %
        data = qms.watcher_.ds.history(list{i},'last_trade',datestr(bd),datestr(bd));
        cost_i = data(1,2);
        fprintf(fid,'%s\t%d\t%f\n',code_i,p_i,cost_i);
    end
    
    %underliers
    for i = 1:nu
        code_i = listu{i}.code_ctp;
        [pos_i,ret_i] = counter.queryPositions(code_i);
        if ~ret_i, continue; end
        p_i = pos_i.direction*pos_i.total_position;
        %
        data = qms.watcher_.ds.history(listu{i},'last_trade',datestr(bd),datestr(bd));
        cost_i = data(1,2);
        fprintf(fid,'%s\t%d\t%f\n',code_i,p_i,cost_i);
    end
end