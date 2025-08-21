function Xk = fft_core(x_in) %#codegen

    % ---- Type table ----
    T = fft_core_types('fixed');

    % ---- Validate length ----
    N = length(x_in);
    if N ~= 8
        coder.internal.error('fft_core:InvalidLength', ...
            'This FFT only supports 8-point input.');
    end

    % ---- Twiddle factors ----
    W = T.W; % fixed-point twiddle array
    for k = 0:N-1
        W(k+1) = fi(exp(-1j * 2 * pi * k / N), ...
                    numerictype(W), fimath(W));
    end

    fprintf('Input x(n):\n');
    disp(x_in);

    % ---- Bit reversal ----
    x = bit_reversal_zero_based(x_in, T.x); 
    fprintf('Bit-reversed order:\n');
    disp(x);

    % ---- Stage 1 ----
    s1 = T.s1;
    s1(1) = x(1) + x(2);
    s1(2) = x(1) - x(2);
    s1(3) = x(3) + x(4);
    s1(4) = x(3) - x(4);
    s1(5) = x(5) + x(6);
    s1(6) = x(5) - x(6);
    s1(7) = x(7) + x(8);
    s1(8) = x(7) - x(8);
    fprintf('After Stage 1:\n');
    disp(s1);

    % ---- Stage 2 ----
    s2 = T.s2;
    s2(1) = s1(1) + W(1) * s1(3);
    s2(3) = s1(1) - W(1) * s1(3);
    s2(2) = s1(2) + W(3) * s1(4);
    s2(4) = s1(2) - W(3) * s1(4);
    s2(5) = s1(5) + W(1) * s1(7);
    s2(7) = s1(5) - W(1) * s1(7);
    s2(6) = s1(6) + W(3) * s1(8);
    s2(8) = s1(6) - W(3) * s1(8);
    fprintf('After Stage 2:\n');
    disp(s2);

    % ---- Stage 3 ----
    s3 = T.s3;
    s3(1) = s2(1) + W(1) * s2(5);
    s3(5) = s2(1) - W(1) * s2(5);
    s3(2) = s2(2) + W(2) * s2(6);
    s3(6) = s2(2) - W(2) * s2(6);
    s3(3) = s2(3) + W(3) * s2(7);
    s3(7) = s2(3) - W(3) * s2(7);
    s3(4) = s2(4) + W(4) * s2(8);
    s3(8) = s2(4) - W(4) * s2(8);
    fprintf('Final FFT Output (Stage 3):\n');
    disp(s3);

    % ---- Output ----
    Xk = cast(s3, 'like', T.Xk);

end

% --- Bit reversal ---
function x_reordered = bit_reversal_zero_based(x_in, xtype)
    N = length(x_in);
    num_bits = log2(N);
    x_reordered = xtype;
    for n = 0:N-1
        bin_str = dec2bin(n, num_bits);
        bin_rev = bin_str(end:-1:1);
        rev_n   = bin2dec(bin_rev);
        x_reordered(rev_n + 1) = x_in(n + 1);
    end
end
