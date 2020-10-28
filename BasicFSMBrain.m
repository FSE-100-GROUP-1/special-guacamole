classdef BasicFSMBrain < handle
    properties
        % Initialize basic data structures for car behavior
        brick %the originally initialized EV3 brick object
        states %list of enumerated states
        currentState %current state, element of 'states'
        speed %speed of motor rotation
        
        map %2d array of 1x1 cm tiles, mapped by ultrasonic sensor
            %init val is 0, meaning unknown value.
            %val 1 means a wall
            %val 2 means open, unknown color
            %val 3 means open, white color
            %val 4 means open, red color
            %val 5 means open, yellow color
            %val 6 means open, green color
        mapPosition %the bricks position in its mental map
        mapMax %maximum size of the map
        rotation %approx rotation where initial is 0 PI RADIANS (1 rot = 2 pi rads)
    end
    methods
        %Constructor
        function obj = BasicFSMBrain(brick)
            obj.brick = brick;
            obj.states = ["IDLE", "FWD", "BACK", "CW", "CCW"];
            obj.currentState = obj.states(1);
            obj.speed = 30;
            obj.mapMax = 48; %temp val, get info on specs
            obj.map = zeros(obj.mapMax, obj.mapMax);
            obj.mapPosition = [obj.mapMax / 2, obj.mapMax / 2]; %start in center
            obj.rotation = 0; %init to zero
            obj.brick.SetColorMode(3,2)
        end
        
        %Update Motor Behavior based on currentState
        function s = SetMotors(obj, state)
            s = true;
            if(strcmp(state, "IDLE") == 1)
                obj.brick.StopAllMotors();
            elseif(strcmp(state, "FWD") == 1)
                obj.brick.MoveMotor('AB', -1 * obj.speed);
            elseif(strcmp(state, "BACK") == 1)
                obj.brick.StopAllMotors();
            elseif(strcmp(state, "CW") == 1)
                obj.brick.StopAllMotors();
            elseif(strcmp(state, "CCW") == 1)
                obj.brick.StopAllMotors();
            else
                s = false;
            end
        end
        
        function s = UpdateMap(obj)
            s = obj.brick.UltrasonicDist('D');
            mapX = floor(obj.mapPosition(1) + (cos(obj.rotation) * s));
            mapY = floor(obj.mapPosition(2) + (sin(obj.rotation) * s));
            obj.map(mapX, mapY) = 1; %its a wall!
            if(s>2)
               for ii=1:(s-1)
                   tempX = floor(obj.mapPosition(1) + (cos(obj.rotation) * ii));
                   tempY = floor(obj.mapPosition(2) + (sin(obj.rotation) * ii));
                   obj.map(tempX,tempY)=2; %its an unknown open space!
               end
            end
            s = [mapX mapY obj.map(mapX, mapY)];
        end
        
        function s = RotateIncrement(obj)
           s = true;
           obj.brick.MoveMotorAngleRel('A', 30, 388, 'Brake')
           %obj.brick.MoveMotorAngleRel('B', 30, -10, 'Brake')
           obj.brick.WaitForMotor('A')
        end
        
        function s = PollUltrasonic(obj)
           s = true;
           for ii=0:20
              obj.UpdateMap()
              obj.RotateIncrement()
           end
        end
        
        function s = LiftClaw(obj)
           s = true;
           obj.brick.MoveMotor('C', 50)
           obj.brick.WaitForMotor('C')
        end
        
        %function s = PollSensors(obj)
        %    s = true;
        %    (touchL, touchR, color) = (obj.brick.TouchPressed(1), 
        %                                obj.brick.TouchPressed(2),
        %                                obj.brick.ColorCode(3));
        %end
    end
end

