function [vbl,respMade,rt] = PresentAVStimulus(stimulusTexture, Frequency, Volume, window, vbl, ifi, Duration1, Duration2, GetResp, tStart, PreviousRespMade, rt, rectCenter)
%Plays an audiovisual stimulus for the given Duration in ms. Will generate a vbl if no vbl is given. Has ability to receive user input in form of key press or rt
%   
%   stimulusTexture - texture of the stimulus that you wish to present Use Screen('MakeTexture') to convert matrix to texture. 
%   Frequency - frequency of the auditory stimuli in hertz
%   Volume - volume of the auditory stimuli as a fraction 0-1. (0.5 for half volume)
%   window: window ptr of the window to present the stimuli. [window, windowRect] = PsychImaging('OpenWindow', screenNumber, 0.5, [], 32, 2,...
%       [], [],  kPsychNeed32BPCFloat);
%   vbl: if this is the first presentation of the stimulus, it creates one. This function returns vbl for subsequent presentation functions.
%       ENTER 0 if this is the first presentation!!! vbl is used to keep track of the time a stimulus was played for strict timing of presentations
%   ifi: Flip Interval. Use ifi = Screen('GetFlipInterval', windowPtr) to get it
%   Duration: For a stimulus of X ms, enter X for Duration1 and 0 for Duration 2. For a stimulus played for a random amount of time between X and Y, input X as
%   Duration1 and Y as Duration2
%   GetResp: set to true if you want response information (whether a response was made and RT)
%   tStart: start time of desired RT interval.
%   PreviousRespMade: represents response to the presentation that preceded this one if you are stringing presentation intervals of which you desire the same response. 
%       Set to 0 if there is no response to the presentation before this one. 
%   rt: represents previous reaction time to the presentation that preceded this one if you are stringing presentation intervals of which you desire the same response.
%       Set to 0 if there is no response to the presentation before this one. 
%   rectCenter: rectCenter = CenterRectOnPointd(baseRect, xPos, yPos); Used to center rectangle texture in the middle of the screen
%   
%IMPORTANT NOTE: This function will only change respMade to true if a response is
%made. If there is no response, respMade is NOT set to false. This is to accomodate
%for a series of presentations that wish to get user response. Initialize
%respMade as false before calling any presentX stimulus. 

%setting respMade to previous response and setting default rt to 0
respMade = PreviousRespMade;

%setting number of frames to wait before redrawing
waitframes = 1;

%setting Time in Frames
if Duration2 > Duration1
    timeMSecs = (rand(1)*(Duration2 - Duration1) + Duration1)/1000;
    timeFrames = round(timeMSecs ./ ifi);
    Duration = timeMSecs;
else
    timeMSecs = Duration1/1000;
    timeFrames = round(timeMSecs ./ ifi);
    Duration = Duration1;
end

%audiosetup stuff
sampleFreq = 48000;
repetitions = 1;
startCue = 0;
waitForDeviceStart = 1;
NumberChannels = 2;
pahandle = PsychPortAudio('Open', [], 1, 1, sampleFreq, NumberChannels, [], [], [], []);
PsychPortAudio('Volume', pahandle, Volume);
myBeep = MakeBeep(Frequency, Duration, sampleFreq);
PsychPortAudio('FillBuffer', pahandle, [myBeep; myBeep]);

%if this is the first instance of putting something on the monitor
if vbl == 0
    
    %play sound
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    
    %Play stimulus
    Screen('DrawTextures', window, stimulusTexture, [], rectCenter, [], [], [], []);
    vbl = Screen('Flip', window);
    
    %Play stimulus for the rest of the presentation interval (-1
    %frame because we played the fixation point at frame 1)
    for frame = 1:timeFrames - 1       
        %Draw fixation point
        Screen('DrawTextures', window, stimulusTexture, [], rectCenter, [], [], [], []);
        
        %Flip to screen
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        
        if GetResp == true
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
            end
        end
    end
    %otherwise, use previous vbl
else
    PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
    for frame = 1:timeFrames
        Screen('DrawTextures', window, stimulusTexture, [], rectCenter, [], [], [], []);
        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
        if GetResp == true
            %detecting response
            KeyIsDown = KbCheck;
            if KeyIsDown == 1
                respMade = true;
                tEnd = GetSecs;
                rt = tEnd - tStart;
            end
        end
    end
end
PsychPortAudio('Close', pahandle);
end


