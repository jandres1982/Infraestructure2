rem net use z: \\espwsr0105\g$ /user:admlasherca
rem net use x: \\shhdna0010\esp$\MAA /user:admlasherca
robocopy g:\trabajo \\shhdna0010\esp$\MAA\trabajo /ZB /E /COPYALL /MT:100 /R:1 /W:1 /REG /X /V /MIR
