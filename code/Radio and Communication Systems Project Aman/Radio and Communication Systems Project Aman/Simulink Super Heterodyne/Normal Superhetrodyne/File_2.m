% This m-file accompanies the simulink model dsb_lc_sim.mdl which models double sideband large carrier amplitude modulation.
% This script is running at the end of the simulation to display time and frequency domain plots for the signals involved.
% Student:    Aman Khatri
% Credits:    Marco Chiesa
% Course:     EE-421
% Term:       Spring 2012
% Instructor: Larry Lokey

% parameters - these are the only values that need to be changed
fft_length=32768;                                                             % length of the fft. should be power of 2

Signal_1_M=50;                                                              % decimation factor for modulating signal
Signal_2_M=5;                                                                  % decimation factor for carrier signal
Signal_3_M=10;                                                               % decimation factor for modulated signal
Signal_4_M=10;                                                             % decimation factor for transmitted signal
Signal_5_M=5;                                                              % decimation factor for demodulated signal
Signal_6_M=50;                                                               % decimation factor for recovered signal

simulation_start_time=0;                                                      % start time for simulink simulation
simulation_stop_time=5;                                                       % stop time for simulink simulation
Signal_1_start_plot_time=0;                                                 % start time for the modulating signal time domain plot(relative from simulation start time)
Signal_1_stop_plot_time=5;                                                % stop time for the modulating signal time domain plot(relative from simulation start time)
Signal_2_start_plot_time=0;                                                    % start time for the carrier signal time domain plot(relative from simulation start time)
Signal_2_stop_plot_time=5;                                                   % stop time for the carrier signal time domain plot(relative from simulation start time)
Signal_3_start_plot_time=0.05;                                                  % start time for the modulated signal time domain plot(relative from simulation start time)
Signal_3_stop_plot_time=0.15;                                                 % stop time for the modulated signal time domain plot(relative from simulation start time)
Signal_4_start_plot_time=0.05;                                                % start time for the transmitted signal time domain plot(relative from simulation start time)
Signal_4_stop_plot_time=3;                                               % stop time for the transmitted signal time domain plot(relative from simulation start time)
Signal_5_start_plot_time=0.5;                                                % start time for the demodulated signal time domain plot(relative from simulation start time)
Signal_5_stop_plot_time=5;                                               % stop time for the demodulated signal time domain plot(relative from simulation start time)
Signal_6_start_plot_time=1;                                               % start time for the recovered signal time domain plot(relative from simulation start time)
Signal_6_stop_plot_time=5;                                                 % stop time for the recovered signal time domain plot(relative from simulation start time)
% parameters



% simulate double sideband suppressed carrier
File_2_sim;                                                                   % open simulation
sim(gcs, [simulation_start_time simulation_stop_time]);                       % run simulation set duration
waitfor(gcs,'SimulationStatus','stopped');                                    % wait until simulation ends



% initialize variables for modulating signal
Signal_1_time=Signal_1.time;                                              % sample times for the modulating signal (x-axis for time domain plot)
Signal_1_time_values=Signal_1.signals.values;                             % time domain values for the modulating signal
Signal_1_Fs=1/(Signal_1_time(2)-Signal_1_time(1));                      % sampling frequency for the modulating signal
Signal_1_freq=(Signal_1_Fs/Signal_1_M)*(0:fft_length/2)/fft_length;     % valid frequency range (x-axis) for downsampled frequency domain plot
Signal_1_freq_values=abs(fft(Signal_1_time_values(1:Signal_1_M:end),fft_length));      % magnitude freq spectrum after downsampling

% initialize variables for carrier signal
Signal_2_time=Signal_2.time;                                                    % sample times for the carrier signal (x-axis for time domain plot)
Signal_2_time_values=Signal_2.signals.values;                                   % time domain values for the carrier signal
Signal_2_Fs=1/(Signal_2_time(2)-Signal_2_time(1));                               % sampling frequency for the carrier signal
Signal_2_freq=(Signal_2_Fs/Signal_2_M)*(0:fft_length/2)/fft_length;              % valid frequency range (x-axis) for downsampled frequency domain plot
Signal_2_freq_values=abs(fft(Signal_2_time_values(1:Signal_2_M:end),fft_length));               % magnitude freq spectrum after downsampling

% initialize variables for modulated signal
Signal_3_time=Signal_3.time;                                                % sample times for the modulated signal (x-axis for time domain plot)
Signal_3_time_values=Signal_3.signals.values;                               % time domain values for the modulated signal
Signal_3_Fs=1/(Signal_3_time(2)-Signal_3_time(1));                         % sampling frequency for the modulated signal
Signal_3_freq=(Signal_3_Fs/Signal_3_M)*(0:fft_length/2)/fft_length;        % valid frequency range (x-axis) for downsampled frequency domain plot
Signal_3_freq_values=abs(fft(Signal_3_time_values(1:Signal_3_M:end),fft_length));         % magnitude freq spectrum after downsampling

% initialize variables for transmitted signal
Signal_4_time=Signal_4.time;                                            % sample times for the transmitted signal (x-axis for time domain plot)
Signal_4_time_values=Signal_4.signals.values;                           % time domain values for the transmitted signal
Signal_4_Fs=1/(Signal_4_time(2)-Signal_4_time(1));                   % sampling frequency for the transmitted signal
Signal_4_freq=(Signal_4_Fs/Signal_4_M)*(0:fft_length/2)/fft_length;  % valid frequency range (x-axis) for downsamlped frequency domain plot
Signal_4_freq_values=abs(fft(Signal_4_time_values(1:Signal_4_M:end),fft_length));   % magnitude freq spectrum after downsampling

% initialize variables for demodulated signal
Signal_5_time=Signal_5.time;                                            % sample times for the demodulated signal (x-axis for time domain plot)
Signal_5_time_values=Signal_5.signals.values;                           % time domain values for the demodulated signal
Signal_5_time_values=Signal_5_time_values/max(Signal_5_time_values); % scale the time domain to make between -1 and 1. Not necessary, only for appearance
Signal_5_Fs=1/(Signal_5_time(2)-Signal_5_time(1));                   % sampling frequency for the demodulated signal
Signal_5_freq=(Signal_5_Fs/Signal_5_M)*(0:fft_length/2)/fft_length;  % valid frequency range (x-axis) for downsamlped frequency domain plot
tmp=Signal_5_time_values-mean(Signal_5_time_values);                    % temp time values variable w/o DC component added by envelope detection
Signal_5_freq_values=abs(fft(tmp(1:Signal_5_M:end),fft_length));        % magnitude freq spectrum after downsampling

% initialize variables for Signal_6 signal
Signal_6_time=Signal_6.time;                                                % sample times for the recovered signal (x-axis for time domain plot)
Signal_6_time_values=Signal_6.signals.values;                               % time domain values for the recovered signal
Signal_6_time_values=Signal_6_time_values-mean(Signal_6_time_values);      % remove DC component introduced by envelope detection
Signal_6_Fs=1/(Signal_6_time(2)-Signal_6_time(1));                         % sampling frequency for the recovered signal
Signal_6_freq=(Signal_6_Fs/Signal_6_M)*(0:fft_length/2)/fft_length;        % valid frequency range (x-axis) for downsamlped frequency domain plot
Signal_6_freq_values=abs(fft(Signal_6_time_values(1:Signal_6_M:end),fft_length));   % magnitude freq spectrum after downsampling



close all                                                                     % close any open plot windows

% config figure window sizes
screen_size=get(0,'ScreenSize');
screen_width=screen_size(3);
screen_height=screen_size(4);
figure_width=(screen_width-30)/2;
figure_height=screen_height-120;
figure_x1=15;
figure_x2=screen_width/2;
figure_y=50;


% display time domain plots
figure;                                                                               % open new figure window
set(gcf,'position',[figure_x1 figure_y figure_width figure_height]);                  % set location and size for figure

s1=ceil(Signal_1_Fs*Signal_1_start_plot_time)+1;                                  % starting sample for time domain plot
s1=max(s1,1);
s1=min(s1,length(Signal_1_time));
s2=floor(Signal_1_Fs*Signal_1_stop_plot_time)+1;                                  % last sample for time domain plot
s2=max(s2,1);
s2=min(s2,length(Signal_1_time));
subplot(6,1,1); plot(1000*Signal_1_time(s1:s2),Signal_1_time_values(s1:s2));      % plot modulating signal time domain
title('Message Signal - time domain'); xlabel('Time (milliseconds)'); ylabel('Amplitude (V)');
axis tight;

s1=ceil(Signal_2_Fs*Signal_2_start_plot_time)+1;                                        % starting sample for time domain plot
s1=max(s1,1);
s1=min(s1,length(Signal_2_time));
s2=floor(Signal_2_Fs*Signal_2_stop_plot_time)+1;                                        % last sample for time domain plot
s2=max(s2,1);
s2=min(s2,length(Signal_2_time));
subplot(6,1,2); plot(1000*Signal_2_time(s1:s2),Signal_2_time_values(s1:s2));            % plot carrier signal time domain
title('Modulated Signal - time domain'); xlabel('Time (milliseconds)'); ylabel('Amplitude (V)');
axis tight;

s1=ceil(Signal_3_Fs*Signal_3_start_plot_time)+1;                                    % starting sample for time domain plot
s1=max(s1,1);
s1=min(s1,length(Signal_3_time));
s2=floor(Signal_3_Fs*Signal_3_stop_plot_time)+1;                                    % last sample for time domain plot
s2=max(s2,1);
s2=min(s2,length(Signal_3_time));
subplot(6,1,3); plot(1000*Signal_3_time(s1:s2),Signal_3_time_values(s1:s2));        % plot modulated signal time domain
title('Signal After the Mixer has been Implemented - time domain'); xlabel('Time (milliseconds)'); ylabel('Amplitude (V)');
axis tight;

s1=ceil(Signal_4_Fs*Signal_4_start_plot_time)+1;                                % starting sample for time domain plot
s1=max(s1,1);
s1=min(s1,length(Signal_4_time));
s2=floor(Signal_4_Fs*Signal_4_stop_plot_time)+1;                                % last sample for time domain plot
s2=max(s2,1);
s2=min(s2,length(Signal_4_time));
subplot(6,1,4); plot(1000*Signal_4_time(s1:s2),Signal_4_time_values(s1:s2));    % plot transmitted signal time domain
title('Signal after Implimentation of Filter which allows attenuation of higher frequencies - time domain'); xlabel('Time (milliseconds)'); ylabel('Amplitude (V)');
axis tight;

s1=ceil(Signal_5_Fs*Signal_5_start_plot_time)+1;                                % starting sample for time domain plot
s1=max(s1,1);
s1=min(s1,length(Signal_5_time));
s2=floor(Signal_5_Fs*Signal_5_stop_plot_time)+1;                                % last sample for time domain plot
s2=max(s2,1);
s2=min(s2,length(Signal_5_time));
subplot(6,1,5); plot(1000*Signal_5_time(s1:s2),Signal_5_time_values(s1:s2));    % plot demodulated signal time domain
title('Demodulation of the Signal - time domain'); xlabel('Time (milliseconds)'); ylabel('Amplitude (V)');
axis tight;

s1=ceil(Signal_6_Fs*Signal_6_start_plot_time)+1;                                    % starting sample for time domain plot
s1=max(s1,1);
s1=min(s1,length(Signal_6_time));
s2=floor(Signal_6_Fs*Signal_6_stop_plot_time)+1;                                    % last sample for time domain plot
s2=max(s2,1);
s2=min(s2,length(Signal_6_time));
subplot(6,1,6); plot(1000*Signal_6_time(s1:s2),Signal_6_time_values(s1:s2));        % plot recovered signal time domain
title('Filtered Signal(Recovered Message) - time domain'); xlabel('Time (milliseconds)'); ylabel('Amplitude (V)');
axis tight;


% display frequency domain plots
figure;                                                                                      % open new figure window
set(gcf,'position',[figure_x2 figure_y figure_width figure_height]);                         % set location and size for figure

subplot(6,1,1); plot(Signal_1_freq,Signal_1_freq_values(1:fft_length/2+1));              % plot Signal_1 signal frequency domain (zero to Fs/2)
title('Message Signal - frequency domain'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
set(gca,'YTick',[]);                                                                         % turn off y axis tick marks

subplot(6,1,2); plot(Signal_2_freq,Signal_2_freq_values(1:fft_length/2+1));                    % plot carrier signal frequency domain (zero to Fs/2)
title('Modulated Signal - frequency domain'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
set(gca,'YTick',[]);                                                                         % turn off y axis tick marks

subplot(6,1,3); plot(Signal_3_freq,Signal_3_freq_values(1:fft_length/2+1));                % plot modulated signal frequency domain (zero to Fs/2)
title('Signal After the Mixer has been Implemented - frequency domain'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
set(gca,'YTick',[]);                                                                         % turn off y axis tick marks

subplot(6,1,4); plot(Signal_4_freq,Signal_4_freq_values(1:fft_length/2+1));            % plot transmitted signal frequency domain (zero to Fs/2)
title('Signal after Implimentation of Filter which allows attenuation of higher frequencies - frequency domain'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
set(gca,'YTick',[]);                                                                         % turn off y axis tick marks

subplot(6,1,5); plot(Signal_5_freq,Signal_5_freq_values(1:fft_length/2+1));            % plot demodulated signal frequency domain (zero to Fs/2)
title('Demodulation of the Signal - frequency domain'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
set(gca,'YTick',[]);                                                                         % turn off y axis tick marks

subplot(6,1,6); plot(Signal_6_freq,Signal_6_freq_values(1:fft_length/2+1));                % plot recovered signal frequency domain (zero to Fs/2)
title('Filtered Signal(Recovered Message) - frequency domain'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
set(gca,'YTick',[]);                                                                         % turn off y axis tick marks



% clean up
clear all                                                                                    % remove all variables from workspace