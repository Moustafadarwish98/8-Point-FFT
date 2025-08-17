clear; clc; close all;

% =====================[ Create Type Table ]=====================
T = fft_core_types('fixed');  % or 'single' for single precision

% =====================[ Randomized Test Cases ]==================
nseeds = 1000;
test_inputs = cell(1, nseeds);

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

    % MATLAB built-in FFT
    X_builtin = fft(double(test_inputs{t}));

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

for k = 1:length(directed_tests)
    fprintf('\n=========== Directed Test %d ===========\n', k);
    
    x_dir = cast(directed_tests{k}, 'like', T.x);

    % Run custom FFT
    X_custom = fft_core_mex(x_dir);

    % MATLAB built-in FFT
    X_builtin = fft(double(x_dir));

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
% =====================[ Show Instrumentation Results ]===========

% --- Added: Average statistics for all random test inputs ---
avg_error = mean(errors);
avg_sqnr  = mean(sqnr_vals);

fprintf('\n================ Overall Random Test Results ================\n');
fprintf('Average Relative Error: %.6f %%\n', avg_error);
fprintf('Average SQNR: %.2f dB\n', avg_sqnr);

% =====================[ Show Instrumentation Results ]===========
showInstrumentationResults fft_core_mex

