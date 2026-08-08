## small immitation of irc servers.
- its my first tiem using java, will never use ever again.

### Update 1:
- Now people get joining notifications too.
```sh
(myenv) debb% telnet 127.0.0.1 21553
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
Welcome to the IRC Server! You are in channel: #welcome
!join #hamz
 ircIM: OK: joined channel `#hamz`.
[#welcome] /127.0.0.1:50024:  user `/127.0.0.1:50024` has joined this channel.
[#welcome] /127.0.0.1:50040:  user `/127.0.0.1:50040` has joined this channel.
```

#### server:
```sh
_*_ Running: `javac /home/dzebra/Work/probe/Programming/hsys25/side-projects/ircIM-java/irc_im_serv.java 2>&1 && java -cp "$(dirname "/home/dzebra/Work/probe/Programming/hsys25/side-projects/ircIM-java/irc_im_serv.java")" "$(basename "/home/dzebra/Work/probe/Programming/hsys25/side-projects/ircIM-java/irc_im_serv.java" .java)"; true` _*_


IrcIM Server started on port 21553
New client connected: /127.0.0.1:44022
[#welcome] /127.0.0.1:44022: hello world
New client connected: /127.0.0.1:44030
[#welcome] /127.0.0.1:44030: !join #hamz
debug: user `/127.0.0.1:44030` joined channel `#hamz`.
[#welcome] /127.0.0.1:44022: !join #hamz
debug: user `/127.0.0.1:44022` joined channel `#hamz`.
[#hamz] /127.0.0.1:44030: uo
[#hamz] /127.0.0.1:44022: hi

Process completed with exit code: -1
```

#### client 1:
```sh
(myenv) debb% telnet 127.0.0.1 21553
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
Welcome to the IRC Server! You are in channel: #welcome
hello world
[#welcome] /127.0.0.1:44022: hello world
[#welcome] /127.0.0.1:44030: user `/127.0.0.1:44030` left this server.
!join #hamz
 ircIM: OK: joined channel `#hamz`.
[#hamz] /127.0.0.1:44030: uo
hi
[#hamz] /127.0.0.1:44022: hi
^AConnection closed by foreign host.
(myenv) debb%
```

#### client 2:
```sh
(myenv) debb% telnet 127.0.0.1 21553
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
Welcome to the IRC Server! You are in channel: #welcome
!join #hamz
 ircIM: OK: joined channel `#hamz`.
uo
[#hamz] /127.0.0.1:44030: uo
[#hamz] /127.0.0.1:44022: hi
Connection closed by foreign host.
```