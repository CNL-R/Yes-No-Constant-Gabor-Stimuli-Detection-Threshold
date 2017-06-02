function [] = CreateAuditoryNoise(Duration, SampleRate, Filename)
%Generates auditory noise and converts to audio WAV file. 
%   Frquency in Hz
%   Duration in ms
%   Sample Rate in Hz

    %Converting Duration from ms to seconds (because Hz is used as units in frequency and sample rate)
    Duration = Duration / 1000;
    
  
    y = randn(SampleRate * Duration, 1);
    
    audiowrite(Filename, y, SampleRate);
end
