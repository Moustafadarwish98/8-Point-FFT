function T = fft_core_types(dt)
% fft_core_types  Type table for fft_core function (fixed-point setup, 12-bit total)

switch dt
    case 'double'
        % Double precision (for floating-point reference runs)
        T.x = complex(double(zeros(1,8)), double(zeros(1,8)));
        
    case 'single'
        % Single precision
        T.x = complex(single(zeros(1,8)), single(zeros(1,8)));
        
    case 'fixed'
        % ===== Fixed-point definitions =====
        % Format: numerictype(signed, total_bits, fractional_bits)
        WL = 12;  % total word length in bits
        
        % ---- Integer bits from simulation results ----
        IB_Xk   = 8;  
        IB_x_in = 6;
        IB_s1   = 7;
        IB_s2   = 7;
        IB_s3   = 8;
        IB_W    = 2;
        IB_x    = 6;
        
        % ---- Define each variable ----
        T.x_in  = fi(complex(zeros(1,8)), 1, WL, WL - IB_x_in);
        T.Xk    = fi(complex(zeros(1,8)), 1, WL, WL - IB_Xk);
        T.s1    = fi(complex(zeros(1,8)), 1, WL, WL - IB_s1);
        T.s2    = fi(complex(zeros(1,8)), 1, WL, WL - IB_s2);
        T.s3    = fi(complex(zeros(1,8)), 1, WL, WL - IB_s3);
        T.W     = fi(complex(zeros(1,8)), 1, WL, WL - IB_W);
        T.x     = fi(complex(zeros(1,8)), 1, WL, WL - IB_x);
        
        % Scalars
        T.k     = fi(0, 1, WL, 0);    % integer index
        T.N     = fi(8, 1, WL, 0);    % constant
        
    otherwise
        error('Unsupported data type: %s', dt);
end
end
