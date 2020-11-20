javaaddpath("C:\Program Files\MATLAB\R2020b\toolbox\EV3")
brick = Brick('ioType','wifi','wfAddr','127.0.0.1','wfPort',5555,'wfSN','0016533dbaf5');
brick.playTone(100,800,500);
brick.GetBattVoltage()
brain = EvenBasicerFSMBrain(brick);