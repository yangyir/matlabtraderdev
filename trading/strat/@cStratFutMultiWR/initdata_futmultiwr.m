function [] = initdata_futmultiwr(obj)
    obj.mde_fut_.initcandles;
    instruments = obj.getinstruments;
    for i = 1:obj.count
        ti = obj.mde_fut_.calc_technical_indicators(instruments{i});
        if ~isempty(ti{1})
            obj.wr_(i) = ti{1}(1);
        end
    end
end