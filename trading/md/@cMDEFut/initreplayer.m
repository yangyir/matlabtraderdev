function [] = initreplayer(obj,varargin)
%cMyTimerObj
    p = inputParser;
    p.CaseSensitive = false;p.KeepUnmatched = true;
    p.addParameter('code','',@ischar);
    p.addParameter('fn','',@ischar);
    p.parse(varargin{:});
    codestr = p.Results.code;
    fn = p.Results.fn;
    
%     obj.registerinstrument(codestr);
    
    r = cReplayer;
    r.loadtickdata('code',codestr,'fn',fn);
    obj.replayer_ = r;
    
    obj.mode_ = 'replay';
    
    [~,idx] = r.instruments_.hasinstrument(codestr);
    
    obj.replay_date1_ = floor(r.tickdata_{idx}(1,1));
    obj.replay_date2_ = datestr(obj.replay_date1_,'yyyy-mm-dd');
%     
    obj.replay_datetimevec_ = r.tickdata_{idx}(:,1);
    obj.replay_count_ = 1;
    
end