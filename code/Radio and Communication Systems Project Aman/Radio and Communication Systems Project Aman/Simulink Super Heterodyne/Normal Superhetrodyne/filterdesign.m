% This m-file was used to find the difference equation coefficients for the
% low pass filter used in all three simulink models (dsb_sc.mdl, dsb_lc.mdl, ssb.mdl)
% 
% where, 
%      y[n] = (sum(b[u] * x[n-u]) - sum(a[v] * y[n-v])) / a0
% and, 
%      u=(0 ... M)
%      v=(1 ... N)
%      M is number of 'b' coefficients
%      N is number of 'a' coefficients
%      a0 is the zeroth 'a' coefficient
%
% Gain and sample delay blocks using the 'a' and 'b' coefficients were then
% used in simulink to implement a low pass filter. Open the LPF subsystem
% in one of the simulink models to see the filter's construction.
%
% Student:    Marco Chiesa
% Course:     EE-421
% Term:       Spring 2006
% Instructor: Larry Lokey

% parameters - these are the only values that need to be changed
filter_order=6;          % the order of the butterworth low pass filter
cutoff_frequency=500;    % the cutoff frequency (the models use a 100 Hz modulating frequency and a 1 kHz carrier)
Fs=50000;                % the sampling frequency used in the simulink models (dsb_sc.mdl, dsb_lc.mdl, ssb.mdl)
% parameters

format long e;           % set the precision with which answers are displayed in Matlab
[b,a] = butter(filter_order,cutoff_frequency/(Fs/2),'low')   % design a Butterworth digital filter. Note use of normalized cutoff frequency.


%clean up
% remove all variables except 'a' and 'b' vector from workspace
clear filter_order;
clear cutoff_frequency;
clear Fs;
%set output display precision back to default
format;