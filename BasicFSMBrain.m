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
            obj.mapMax = 64; %temp val, get info on specs
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
                obj.brick.MoveMotor('AB', obj.speed);
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
                   if(obj.map(tempX,tempY) == 0)
                        obj.map(tempX,tempY)=2; %its an unknown open space!
                   end
               end
            end
            s = [mapX mapY obj.map(mapX, mapY)];
        end
        
        function s = RotateIncrement(obj)
           s = true;
           obj.brick.MoveMotorAngleRel('A', 45, 46, 'Brake')
           obj.brick.MoveMotorAngleRel('B', -45, 46, 'Brake')
           obj.brick.WaitForMotor('AB')
        end
        
        function s = PollUltrasonic(obj)
           s = true;
           
           for ii=0:72
              disp(ii)
              obj.UpdateMap();
              obj.RotateIncrement();
           end
        end
        
        function s = LiftClaw(obj)
           s = true;
           obj.brick.MoveMotorAngleAbs('C', 100, 20, 'Brake');
           obj.brick.WaitForMotor('C');
        end
        
        %function s = PollSensors(obj)
        %    s = true;
        %    (touchL, touchR, color) = (obj.brick.TouchPressed(1), 
        %                                obj.brick.TouchPressed(2),
        %                                obj.brick.ColorCode(3));
        %end
        
        function s = ManualControl(obj)
           s = true;
           turbo = false;
           claw=false;
           global key;
           InitKeyboard();
           while 1
              pause(0.1);
              switch key
                  case 't' %toggle turbo
                      pause(0.5)
                      if(turbo)
                          turbo=false;
                      else
                          turbo=true;
                      end
                      disp(turbo)
                  case 'w' %forward
                      if(turbo)
                          obj.brick.MoveMotor('AB', 100);
                      else
                          obj.brick.MoveMotor('AB', 20);
                      end
                      pause(1);
                      obj.brick.StopMotor('AB', 'Coast')
                  case 's' %backward
                      if(turbo)
                          obj.brick.MoveMotor('AB', -100);
                      else
                          obj.brick.MoveMotor('AB', -20);
                      end
                      pause(1);
                      obj.brick.StopMotor('AB', 'Coast')
                  case 'a' %rotate ccw
                      obj.brick.MoveMotor('A', -20);
                      obj.brick.MoveMotor('B', 20);
                      pause(1);
                      obj.brick.StopMotor('AB', 'Coast')
                  case 'd' %rotate ccw
                      obj.brick.MoveMotor('A', 20);
                      obj.brick.MoveMotor('B', -20);
                      pause(1);
                      obj.brick.StopMotor('AB', 'Coast')
                  case 'space' %the claw
                      if(claw)
                          claw=false
                          obj.brick.MoveMotor('C', -100);
                          pause(2.5);
                          obj.brick.StopMotor('C', 'Brake')
                      else
                          claw=true
                          obj.brick.MoveMotor('C', 100);
                          pause(3.5);
                          obj.brick.StopMotor('C', 'Brake')
                          obj.brick.MoveMotor('C', 20);
                      end
                  case 'q' %quit
                      obj.brick.StopMotor('AB', 'Coast')
                      obj.brick.StopMotor('C', 'Brake')
                      break;
              end
           end
           CloseKeyboard();
        end
        
    end
end

