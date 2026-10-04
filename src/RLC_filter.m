function [b, a, params] = RLC_filter(type, R, L, C)
% [b, a, params] = RLC_filter(type, R, L, C)
    
    a = [L*C, R*C, 1];
    switch type
        case 'FDP'
            b = [1];
        case 'FGP'
            b = [L*C, 0, 0];
        case 'FPP'
            b = [R, 0] * C;
    end
    
    params.w0  = 1/sqrt(L*C);                   % nietłumiona
    params.f0  = params.w0/(2*pi);
    params.ksi = (R/2)*sqrt(C/L);
    params.w1 = params.w0*sqrt(1-params.ksi^2); % tłumiona
    params.f1 = params.w1/(2*pi);
    params.d = params.ksi*params.w0;
    params.A = params.w0/sqrt(1-params.ksi^2);  % rezonansowa
    params.tau = R*C;
    
    switch type                                 % graniczne
        case {'FDP', 'FGP'}
            wc = cutoff_freq(b, a);
            params.wc = wc(1);
            params.fc = params.wc/(2*pi);
        case 'FPP'
            wc = cutoff_freq(b, a);
            params.wc_1 = wc(1);
            params.wc_2 = wc(2);
            params.bw = (params.wc_2 - params.wc_1)/(2*pi);
            params.fc_1 = params.wc_1/(2*pi);
            params.fc_2 = params.wc_2/(2*pi);
    end
end
