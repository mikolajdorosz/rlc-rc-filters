function wc = cutoff_freq(b, a)
% wc = cutoffFreq(b, a)

    w = logspace(-3, 6, 2000); s = 1j * w;
    H = polyval(b, s) ./ polyval(a, s);
    mag = abs(H); Hmax = max(mag); H3dB = Hmax / sqrt(2);

    idx = find(diff(mag > H3dB));
    if isempty(idx), wc = [];
    else, wc = arrayfun(@(i) interp1(mag(i:i+1), w(i:i+1), H3dB), idx); end
end
