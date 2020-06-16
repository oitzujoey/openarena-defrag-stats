# openarena-defrag-stats
Record top times and speeds for Defrag maps.
This was designed using OpenArena, but Ioquake3 should work as well.

Top 5 times are listed by typing !times into the console.
Top 5 speeds are listed by typing !speeds into the console.

The most significant bug is that the speed is only recorded if it is higher than the client's speed record. For example, a player could a speed of 2500 U/s on the map Grid2 in single player mode. The player then connects to the server and achieves a speed of 2000 U/s. Even though it is higher than the server's top speed (1500 U/s for example), it is not recorded. The reason for this is that the stats script is only able to know the speeds and times because Defrag prints it for everyone to see. It just so happens that the mod only prints out the client's speed when it breaks the client's record. As a result, only a few speeds are able to be recorded. The stats script does its best with the information it is given.
