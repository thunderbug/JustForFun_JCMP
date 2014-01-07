
CREATE TABLE IF NOT EXISTS `FuelStation` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL,
  `X-` int(11) NOT NULL,
  `X+` int(11) NOT NULL,
  `Z-` int(11) NOT NULL,
  `Z+` int(11) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=3 ;

INSERT INTO `FuelStation` (`ID`, `Name`, `X-`, `X+`, `Z-`, `Z+`) VALUES
(1, 'Texaco City Station #1 Pump 1 & 2', -10725, -10736, -2726, -2729),
(2, 'Texaco City Station #1 Pump 3 & 4', -10725, -10736, -2734, -2738);

CREATE TABLE IF NOT EXISTS `Player` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Name` varchar(255) NOT NULL,
  `SteamID` varchar(32) NOT NULL,
  `X` int(10) NOT NULL,
  `Y` int(10) NOT NULL,
  `Z` int(10) NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;