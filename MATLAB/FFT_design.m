clear; clc; close all;

% =====================[ Create Type Table ]=====================
T = fft_core_types('fixed');  % or 'single' for single precision

% =====================[ Randomized Test Cases ]==================
nseeds = 100;
test_inputs = cell(1, nseeds);
test_outputs_builtin = cell(1, nseeds);
test_outputs_custom  = cell(1, nseeds);

for seed = 1:nseeds
    if seed == 1
        % =====================[ Build Instrumented MEX Once ]============
        buildInstrumentedMex fft_core -args {T.x}
    end
    rng(seed);
    test_inputs{seed} = cast(10*randn(1,8) + 10*1i*randn(1,8), 'like', T.x);
end

% =====================[ Run Tests with Verification ]============
errors = zeros(1, nseeds);   % store error % for plotting
sqnr_vals = zeros(1, nseeds); % store SQNR (dB) for plotting

for t = 1:nseeds
    fprintf('\n================ Test Input %d ================\n', t);

    % Run custom FFT
    X_custom = fft_core_mex(test_inputs{t});
    test_outputs_custom{t} = X_custom;

    % MATLAB built-in FFT
    X_builtin = fft(double(test_inputs{t}));
    test_outputs_builtin{t} = X_builtin;

    % Compute difference
    diff_vec = X_custom - X_builtin;

    % Relative error %
    errors(t) = (norm(double(diff_vec)) / norm(double(X_builtin))) * 100;

    % SQNR (dB)
    signal_power = sum(abs(double(X_builtin)).^2);
    noise_power  = sum(abs(double(diff_vec)).^2);
    sqnr_vals(t) = 10 * log10(signal_power / noise_power);

    % Display for first few seeds only
    fprintf('MATLAB fft(x) Output:\n');
    disp(X_builtin);
    fprintf('Difference (Custom - MATLAB):\n');
    disp(diff_vec);
    fprintf('SQNR: %.2f dB\n', sqnr_vals(t));

    fprintf('Error: %.6f %%\n', errors(t));
    fprintf('SQNR: %.2f dB\n', sqnr_vals(t));
end

% =====================[ Plot Error & SQNR ]=====================
figure;
subplot(2,1,1);
plot(1:nseeds, errors, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Seed Number');
ylabel('Relative Error (%)');
title('FFT Core: Relative Error vs Seed (fixed)');
grid on;
ylim([0 max(errors)*1.1]);

subplot(2,1,2);
plot(1:nseeds, sqnr_vals, '-o', 'LineWidth', 1.5, 'MarkerSize', 4);
xlabel('Seed Number');
ylabel('SQNR (dB)');
title('FFT Core: SQNR vs Seed (fixed)');
grid on;

% =====================[ Directed Test Inputs ]===================
directed_tests = {
    [1, 2, 3, 4, 4, 3, 2, 1],
    [0, 1, 2, 3, 4, 5, 6, 7]
};
directed_outputs_builtin = cell(1,length(directed_tests));
directed_outputs_custom  = cell(1,length(directed_tests));

for k = 1:length(directed_tests)
    fprintf('\n=========== Directed Test %d ===========\n', k);
    
    x_dir = cast(directed_tests{k}, 'like', T.x);

    % Run custom FFT
    X_custom = fft_core_mex(x_dir);
    directed_outputs_custom{k} = X_custom;

    % MATLAB built-in FFT
    X_builtin = fft(double(x_dir));
    directed_outputs_builtin{k} = X_builtin;

    % Compute difference
    diff_vec = X_custom - X_builtin;

    % Relative error %
    err_val = (norm(double(diff_vec)) / norm(double(X_builtin))) * 100;

    % SQNR (dB)
    signal_power = sum(abs(double(X_builtin)).^2);
    noise_power  = sum(abs(double(diff_vec)).^2);
    sqnr_val = 10 * log10(signal_power / noise_power);

    % Display results
    fprintf('Input:\n');
    disp(double(x_dir));
    fprintf('MATLAB fft(x):\n');
    disp(X_builtin);
    fprintf('Difference (Custom - MATLAB):\n');
    disp(diff_vec);
    fprintf('Error: %.6f %%\n', err_val);
    fprintf('SQNR: %.2f dB\n', sqnr_val);
end

% =====================[ Overall Statistics ]====================
avg_error = mean(errors);
avg_sqnr  = mean(sqnr_vals);

fprintf('\n================ Overall Random Test Results ================\n');
fprintf('Average Relative Error: %.6f %%\n', avg_error);
fprintf('Average SQNR: %.2f dB\n', avg_sqnr);

% =====================[ Show Instrumentation Results ]===========
showInstrumentationResults fft_core_mex;

% ================================================================
% ===== Extra Part: Save Inputs & Outputs for Verilog ============
% ================================================================
INPUT_FRAC = 6;   % Q6.6
OUTPUT_FRAC = 4;  % Q8.4
WORD_LEN = 12;
max_val = 2^(WORD_LEN-1)-1;
min_val = -2^(WORD_LEN-1);

% Open files
f_in_r  = fopen('fft_inputs_real.mem','w');
f_in_i  = fopen('fft_inputs_imag.mem','w');
f_out_r = fopen('fft_outputs_real.mem','w');
f_out_i = fopen('fft_outputs_imag.mem','w');

for t = 1:nseeds
    x = double(test_inputs{t});
    y = double(test_outputs_builtin{t}); % MATLAB reference
    
    % Quantize inputs (Q6.6)
    xr_q = round(real(x)*2^INPUT_FRAC);
    xi_q = round(imag(x)*2^INPUT_FRAC);
    xr_q = min(max(xr_q, min_val), max_val);
    xi_q = min(max(xi_q, min_val), max_val);

    % Quantize outputs (Q8.4)
    yr_q = round(real(y)*2^OUTPUT_FRAC);
    yi_q = round(imag(y)*2^OUTPUT_FRAC);
    yr_q = min(max(yr_q, min_val), max_val);
    yi_q = min(max(yi_q, min_val), max_val);

    % Write each of 8 samples
    for k = 1:8
        fprintf(f_in_r,  '%03X\n', mod(xr_q(k), 2^WORD_LEN));
        fprintf(f_in_i,  '%03X\n', mod(xi_q(k), 2^WORD_LEN));
        fprintf(f_out_r, '%03X\n', mod(yr_q(k), 2^WORD_LEN));
        fprintf(f_out_i, '%03X\n', mod(yi_q(k), 2^WORD_LEN));
    end
end

% Save directed tests too
for k = 1:length(directed_tests)
    x = double(directed_tests{k});
    y = double(directed_outputs_builtin{k});
    
    % Quantize inputs (Q6.6)
    xr_q = round(real(x)*2^INPUT_FRAC);
    xi_q = round(imag(x)*2^INPUT_FRAC);
    xr_q = min(max(xr_q, min_val), max_val);
    xi_q = min(max(xi_q, min_val), max_val);

    % Quantize outputs (Q8.4)
    yr_q = round(real(y)*2^OUTPUT_FRAC);
    yi_q = round(imag(y)*2^OUTPUT_FRAC);
    yr_q = min(max(yr_q, min_val), max_val);
    yi_q = min(max(yi_q, min_val), max_val);

    for n = 1:8
        fprintf(f_in_r,  '%03X\n', mod(xr_q(n), 2^WORD_LEN));
        fprintf(f_in_i,  '%03X\n', mod(xi_q(n), 2^WORD_LEN));
        fprintf(f_out_r, '%03X\n', mod(yr_q(n), 2^WORD_LEN));
        fprintf(f_out_i, '%03X\n', mod(yi_q(n), 2^WORD_LEN));
    end
end

fclose(f_in_r);
fclose(f_in_i);
fclose(f_out_r);
fclose(f_out_i);

% Also save .mat for MATLAB debug
save('fft_test_vectors_fixed.mat', ...
     'test_inputs','test_outputs_builtin','test_outputs_custom', ...
     'directed_tests','directed_outputs_builtin','directed_outputs_custom');

disp('✅ Saved random + directed test vectors in Q6.6/Q8.4 (hex for Verilog + .mat for MATLAB).');

% =====================[ Stage 1 & 2 Results ]===================
stage1_outputs = cell(1, nseeds);
stage2_outputs = cell(1, nseeds);

for t = 1:nseeds
    x = double(test_inputs{t});

    % ----- Stage 1: 2-point butterflies -----
    stage1 = zeros(1,8);
    for k = 1:4
        a = x(2*k-1);
        b = x(2*k);
        stage1(2*k-1) = a + b;
        stage1(2*k)   = a - b;
    end
    stage1_outputs{t} = stage1;

    % ----- Stage 2: 4-point FFTs -----
    X4a = fft(stage1(1:4));
    X4b = fft(stage1(5:8));
    stage2 = [X4a, X4b];
    stage2_outputs{t} = stage2;
end

% Directed tests too
directed_stage1 = cell(1,length(directed_tests));
directed_stage2 = cell(1,length(directed_tests));
for k = 1:length(directed_tests)
    x = double(directed_tests{k});
    stage1 = zeros(1,8);
    for m = 1:4
        a = x(2*m-1);
        b = x(2*m);
        stage1(2*m-1) = a + b;
        stage1(2*m)   = a - b;
    end
    directed_stage1{k} = stage1;
    X4a = fft(stage1(1:4));
    X4b = fft(stage1(5:8));
    directed_stage2{k} = [X4a, X4b];
end

% Append to .mat file
save('fft_test_vectors_fixed.mat', ...
     'stage1_outputs','stage2_outputs', ...
     'directed_stage1','directed_stage2','-append');

disp('✅ Stored Stage 1 & 2 results in .mat file');

% =====================[ Export Stage 1 & 2 to .mem ]=============
ST12_FRAC = 5;   % Q7.5 format

f_st1_r = fopen('fft_stage1_real.mem','w');
f_st1_i = fopen('fft_stage1_imag.mem','w');
f_st2_r = fopen('fft_stage2_real.mem','w');
f_st2_i = fopen('fft_stage2_imag.mem','w');

for t = 1:nseeds
    % ---- Stage 1 (Q7.5) ----
    y1 = double(stage1_outputs{t});
    y1r_q = round(real(y1) * 2^ST12_FRAC);
    y1i_q = round(imag(y1) * 2^ST12_FRAC);
    y1r_q = min(max(y1r_q, min_val), max_val);
    y1i_q = min(max(y1i_q, min_val), max_val);

    for k = 1:8
        fprintf(f_st1_r, '%03X\n', mod(y1r_q(k), 2^WORD_LEN));
        fprintf(f_st1_i, '%03X\n', mod(y1i_q(k), 2^WORD_LEN));
    end

    % ---- Stage 2 (Q7.5) ----
    y2 = double(stage2_outputs{t});
    y2r_q = round(real(y2) * 2^ST12_FRAC);
    y2i_q = round(imag(y2) * 2^ST12_FRAC);
    y2r_q = min(max(y2r_q, min_val), max_val);
    y2i_q = min(max(y2i_q, min_val), max_val);

    for k = 1:8
        fprintf(f_st2_r, '%03X\n', mod(y2r_q(k), 2^WORD_LEN));
        fprintf(f_st2_i, '%03X\n', mod(y2i_q(k), 2^WORD_LEN));
    end
end

% Directed tests
for k = 1:length(directed_tests)
    % Stage 1 (Q7.5)
    y1 = double(directed_stage1{k});
    y1r_q = round(real(y1) * 2^ST12_FRAC);
    y1i_q = round(imag(y1) * 2^ST12_FRAC);
    y1r_q = min(max(y1r_q, min_val), max_val);
    y1i_q = min(max(y1i_q, min_val), max_val);
    for n = 1:8
        fprintf(f_st1_r, '%03X\n', mod(y1r_q(n), 2^WORD_LEN));
        fprintf(f_st1_i, '%03X\n', mod(y1i_q(n), 2^WORD_LEN));
    end

    % Stage 2 (Q7.5)
    y2 = double(directed_stage2{k});
    y2r_q = round(real(y2) * 2^ST12_FRAC);
    y2i_q = round(imag(y2) * 2^ST12_FRAC);
    y2r_q = min(max(y2r_q, min_val), max_val);
    y2i_q = min(max(y2i_q, min_val), max_val);
    for n = 1:8
        fprintf(f_st2_r, '%03X\n', mod(y2r_q(n), 2^WORD_LEN));
        fprintf(f_st2_i, '%03X\n', mod(y2i_q(n), 2^WORD_LEN));
    end
end

fclose(f_st1_r);
fclose(f_st1_i);
fclose(f_st2_r);
fclose(f_st2_i);

disp('✅ Exported Stage 1 & 2 results to .mem (hex, signed Q7.5).');

