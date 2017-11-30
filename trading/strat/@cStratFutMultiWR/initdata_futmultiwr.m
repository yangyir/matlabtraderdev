function [] = initdata_futmultiwr(obj)
    obj.mde_fut_.initcandles;
    instruments = obj.instruments_.getinstrument;
    for i = 1:obj.count
        ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
        if ~isempty(ti)
            obj.wr_(i) = ti(end);
        end
    end
end