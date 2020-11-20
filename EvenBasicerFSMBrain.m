classdef EvenBasicerFSMBrain < handle
    properties
       brick %reference to brick obj 
       havePassenger %bool
       speed %general speed for everything
    end
    
    methods
        function obj = EvenBasicerFSMBrain(brick)
            obj.brick = brick;
            obj.havePassenger = false;
            obj.speed = -60;
        end
        
        function s = MoveTilBump(obj)
            atStop = false;
            done = false;
            obj.brick.MoveMotor('AB', obj.speed);
            while ~done
                touch = obj.brick.TouchPressed(1) || obj.brick.TouchPressed(2);
                color = obj.brick.ColorCode(3);
                far = obj.brick.UltrasonicDist('D') > 38;
                if color == 5%red
                    if ~atStop
                        obj.brick.StopMotor('AB', 'Brake');
                        pause(2); %or however long brakes are supposed to be 
                        atStop = true;
                        obj.brick.MoveMotor('AB', obj.speed);
                    end    
                elseif color == 3 %green
                    atStop = false;
                    if obj.havePassenger
                        obj.brick.StopMotor('AB', 'Brake');
                        obj.ManualControl();
                        done = true;
                    end
                elseif color == 4 %yeller
                    atStop = false;
                    if ~obj.havePassenger
                        obj.brick.StopMotor('AB', 'Brake');
                        obj.ManualControl();
                        obj.havePassenger = true;
                        obj.brick.MoveMotor('AB', obj.speed);
                    end
                else
                    atStop = false;
                end
                if touch
                    obj.brick.StopMotor('AB', 'Brake');
                    pause(.1);
                    obj.brick.MoveMotor('AB', -1 * obj.speed); %backup
                    pause(2);
                    obj.brick.StopMotor('AB', 'Brake');
                    pause(.1);
                    obj.brick.MoveMotor('A', 60);
                    obj.brick.MoveMotor('B', 15)
                    pause(6);
                    obj.brick.StopMotor('AB', 'Brake');
                    pause(.1);
                    obj.brick.MoveMotor('AB', -1 * obj.speed); %backup
                    pause(2);
                    obj.brick.StopMotor('AB', 'Brake');
                    pause(.1);
                    obj.RotateLeft(); %flip
                    pause(.1);
                    obj.RotateLeft();
                    pause(.1);
                    obj.brick.MoveMotor('AB', obj.speed);
                elseif far
                    pause(4);
                    obj.brick.StopMotor('AB', 'Brake');
                    pause(1);
                    obj.RotateRight();
                    pause(1);
                    obj.brick.MoveMotor('AB', obj.speed);
                    pause(5);
                end
                
                pause(0.05)
            end
            s = true;
            disp('ALL DONE')
        end
        
        function s = RotateLeft(obj)
            obj.brick.MoveMotor('A', -30)
            %obj.brick.MoveMotor('B', 20)
            pause(9.1); %change val based on realism
            obj.brick.StopMotor('AB', 'Brake');
            s = true;
        end
        
        function s = RotateRight(obj)
            %obj.brick.MoveMotor('A', 30)
            obj.brick.MoveMotor('B', -30)
            pause(9); %change val based on realism
            obj.brick.StopMotor('AB', 'Brake');
            s = true;
        end
        
        function s = ManualControl(obj)
           disp('ENTERED MANUAL')
           s = true;
           turbo = false;
           claw = false;
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
                          claw=false;
                          obj.brick.MoveMotor('C', -100);
                          pause(2.5);
                          obj.brick.StopMotor('C', 'Brake')
                      else
                          claw=true;
                          obj.brick.MoveMotor('C', 100);
                          pause(3.5);
                          obj.brick.StopMotor('C', 'Brake')
                          obj.brick.MoveMotor('C', 20);
                      end
                  case 'f' %fix broken claw
                      obj.brick.MoveMotor('C', -30);
                          pause(1.5);
                          obj.brick.StopMotor('C', 'Brake')
                  case 'q' %quit
                      obj.brick.StopMotor('AB', 'Coast')
                      %obj.brick.StopMotor('C', 'Brake')
                      break;
              end
           end
           CloseKeyboard();
        end
    end
end