function [] = print(pos)
    volume = pos.direction_ * pos.position_total_;
    volume_today = pos.direction_ * pos.position_today_;
    if ~isempty(volume)
        fprintf('code:%s;volume:%d;volume(today):%d;cost(carry):%4.2f;cost(open):%4.2f\n',...
            pos.code_ctp_,volume,volume_today,pos.cost_carry_,pos.cost_open_);
    else
        fprintf('empty position......\n');
    end
end