function [audio_output, fs] = process_audio(audio_file, b, a, axLin, axDB)
    %   [audio_output, fs] = process_audio(audio_file, b, a, axLin, axDB)
    
    [audio_input, fs] = audioread(audio_file);
    N = length(audio_input); t = (0:N-1)/fs;
    [A, B, C, D] = tf2ss(b, a);
    x0 = zeros(size(A,1), 1);
    [t_out, x_out] = odeRK4AB(A, B, audio_input, t, x0);
    if size(x_out,2) ~= N, x_out = x_out.'; end
    audio_output = (C * x_out) + D * audio_input.';
    audio_output = audio_output.';

    [audio_input_fft, audio_output_fft] = compute_fft(audio_input, audio_output);

    plot_fft(axLin, audio_input_fft, audio_output_fft, fs, 'Amplituda', false);
    plot_fft(axDB, audio_input_fft, audio_output_fft, fs, 'Amplituda [dB]', true);
end

function [X_input, X_output] = compute_fft(x, y)
    N = length(x); eps_val = 1e-12;  % zabezpieczenie przed log(0)

    X_input  = abs(fft(x)) / max(abs(fft(x)));
    X_output = abs(fft(y)) / max(abs(fft(y)));
    X_input  = X_input  + eps_val;
    X_output = X_output + eps_val;
end
function plot_fft(ax, X_input, X_output, fs, plotTitle, use_dB)
    N = length(X_input); df = fs/N; f = (0:N-1)*df;

    if use_dB
        X_input  = 20*log10(X_input);
        X_output = 20*log10(X_output);
    end

    plot(ax, f, X_input, 'Color', [0.7 0.7 0.7]); hold(ax, 'on');
    plot(ax, f, X_output, 'b', 'LineWidth', 1.2); grid(ax, 'on');
    xlabel(ax, 'f [Hz]'); title(ax, plotTitle); xlim(ax, [0 fs/2]); hold(ax, 'off');
end
