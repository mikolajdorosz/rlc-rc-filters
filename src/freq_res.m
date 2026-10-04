function freq_res(type, b, a, params, circuit, axAmp, axPhase)
    % freq_res(type, b, a, params, circuit, axAmp, axPhase)

    f = logspace(-1, 5, 600);
    s = 1j * 2 * pi * f;
    H = polyval(b, s) ./ polyval(a, s);

    plot_with_markers(axAmp, f, 20*log10(abs(H)), type, params, circuit, '|H(f)| [dB]');
    plot_with_markers(axPhase, f, unwrap(angle(H)), type, params, circuit, 'φ(f)');
end

function plot_with_markers(ax, f, y, type, params, circuit, ylabelText)
    semilogx(ax, f, y, 'LineWidth', 1.2); grid(ax, 'on'); hold(ax, 'on');
    if strcmp(circuit, 'RLC')
        switch type
            case 'FPP'
                xline(ax, params.f0, '--r');
                xline(ax, real(params.fc_1), '--g');
                xline(ax, real(params.fc_2), '--g');
            case {'FDP','FGP'}
                xline(ax, params.f0, '--r');
                xline(ax, real(params.fc), '--g');
        end
    else
        if isfield(params,'fc')
            xline(ax, real(params.fc), '--g');
        end
    end
    xlabel(ax, 'f [Hz]'); title(ax, sprintf('%s: %s', circuit, ylabelText)); hold(ax, 'off');
end
