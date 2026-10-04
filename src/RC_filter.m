function [b, a, params] = RC_filter(type, R, C)
% [b, a, params] = RC_filter(type, R, C)
    
    a = [R*C 1];
    switch type
        case 'FDP', b = [1];
        case 'FGP', b = [R*C 0];
    end
    
    params.tau = R*C;
    params.wc = 1/(R*C);
    params.fc = params.wc/(2*pi);
end
