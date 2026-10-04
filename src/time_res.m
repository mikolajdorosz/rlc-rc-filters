function time_res(b, a, circuit, params, axImpulse, axStep)
    % time_res(b, a, circuit, axImpulse, axStep)

    if isempty(a) || isempty(b), return; end

    [A, B, C, D] = tf2ss(b, a); K = size(A,1);

    if strcmp(circuit, "RC"), t_max = 5*params.tau;
    else, t_max = max(params.tau, 1/params.w0); end

    dt = 1e-5; t = 0:dt:5*t_max;
    x0 = zeros(K,1);

    u_imp = zeros(1, length(t)); u_imp(1) = 1/dt;
    [ti, xi] = odeRK4AB(A, B, u_imp, t, x0);
    xi = xi.'; yi = (C * xi) + D * u_imp; yi = yi.';

    u_step = ones(1, length(t));
    [ts, xs] = odeRK4AB(A, B, u_step, t, x0);
    xs = xs.'; ys = (C * xs) + D * u_step; ys = ys.'; 

    plot_response(axImpulse, ti, yi, 'b', sprintf('%s: Impuls', circuit));
    plot_response(axStep, ts, ys, 'r', sprintf('%s: Skok', circuit));
end

function plot_response(ax, t, y, color, plotTitle)
    plot(ax, t, y, color, 'LineWidth', 1.2); grid(ax, 'on');
    xlabel(ax, 't [s]'); title(ax, plotTitle);
    yMax = max(abs(y)); ylim(ax, [-yMax-0.1*yMax, yMax+0.1*yMax]);
end
