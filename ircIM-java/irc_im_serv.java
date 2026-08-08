import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;
import java.util.Arrays;

public class irc_im_serv {
  private static final int PORT = 21553;

  // universal temporary data storage.
    private static Map<Socket, Boolean> BannedList     = new ConcurrentHashMap<>();
    private static Map<Socket, Boolean> isAdmin        = new ConcurrentHashMap<>();
    private static Map<Socket, String>  wChannel       = new ConcurrentHashMap<>();

  // critical: To track output streams for each socket so ircIM server can broadcast messages instantly
  private static Map<Socket, PrintWriter> clientOutputs = new ConcurrentHashMap<>();

  public static void main(String[] args) {
    // todo: learn threading in depth.
    ExecutorService threadPool = Executors.newCachedThreadPool();

    try (ServerSocket serverSocket = new ServerSocket(PORT)) {
      // for debuggers and on-device mentainers.
      System.out.println("IrcIM Server started on port " + PORT);

      while (true) {
        // lets just accept without any checks.
        // todo: add some checks for spammer and to prevent ddos.
        Socket clientSocket = serverSocket.accept();

        // convert the remote address (or IP) to string.
        String remoteAddr = clientSocket.getRemoteSocketAddress().toString();
        System.out.println("New client connected: " + remoteAddr);

        // Check ban list.
        // todo: fix.
        if (Boolean.TRUE.equals(BannedList.get(clientSocket))) {
          System.out.println(" "+remoteAddr+": is in banned list, so disconnecting.");
          try {
            clientSocket.close();
            System.out.println(" "+remoteAddr+": Client disconnected.");
          } catch (IOException e) {
            System.err.println(" "+remoteAddr+": Failed to close socket: " + e.getMessage());
          }
          continue;
        }

        // lets redirect new users to the "#welcome" channel first.
        wChannel.put(clientSocket, "#welcome");

        // Submit the client connection to the thread pool
        threadPool.execute(new ClientHandler(clientSocket));
      }
    } catch (IOException e) {
      System.err.println("[!!!] Server error: " + e.getMessage());
    } finally {
      threadPool.shutdown();
    }
  }

  private static class ClientHandler implements Runnable {
    private final Socket socket;

    public ClientHandler(Socket socket) {
      this.socket = socket;
    }

    @Override
    public void run() {
      String remoteAddr = this.socket.getRemoteSocketAddress().toString();
      try (
        BufferedReader input = new BufferedReader(new InputStreamReader(socket.getInputStream()));
        PrintWriter output = new PrintWriter(socket.getOutputStream(), true)
      ) {
        // Register this client's output stream so others can send messages to it
        clientOutputs.put(socket, output);

        // first message.
        output.println("Welcome to the IRC Server! You are in channel: " + wChannel.get(socket));

        String line;
        while ((line = input.readLine()) != null) {
          String currentChannel = wChannel.get(socket);

          if (currentChannel == null) {
            output.println("unreacheable-error: not-in-any-channel: You are not in any channel, closing connection...");
            break;
          }

          if (line == null) {
            continue;
          }

          System.out.println("[" + currentChannel + "] " + remoteAddr + ": " + line);

          String[] parts = line.split(" ");
          // Redundant to call .toString() on a String array element, parts[0] is already a String
          String command = parts[0].toLowerCase();

          if (command.startsWith("!")) {
            if (command.equals("!bye")) {
                break;
            } else if (command.equals("!join")) {
              if (parts.length > 1) {
                if (parts[1].startsWith("#")) {
                  wChannel.remove(socket);
                  wChannel.put(socket, parts[1]);
                  line = "user `" + remoteAddr + "` left this server.";
                  output.println(" ircIM: OK: joined channel `"+parts[1]+"`.");
                  System.out.println("debug: user `"+remoteAddr+"` joined channel `"+parts[1]+"`.");
                } else {
                  output.println(" ircIM: channel `" + parts[1] + "` is NOT A CHANNEL. (channels start with #)");
                  continue;
                }
              } else {
                // Handle the case where they just typed "!join" without a channel name
                output.println(" ircIM: Please specify a channel. Usage: !join #channelName");
                continue;
              }
            }
          }

          // Broadcast incoming message to all sockets sharing the same channel
          for (Map.Entry<Socket, String> entry : wChannel.entrySet()) {
            if (currentChannel.equals(entry.getValue())) {
              Socket targetSocket = entry.getKey();
              PrintWriter targetOut = clientOutputs.get(targetSocket);

              if (targetOut != null) {
                // Send the message to the client client
                targetOut.println("[" + currentChannel + "] " + remoteAddr + ": " + line);
              }
            }
          }
        }
      } catch (IOException e) {
        System.err.println("Client " + remoteAddr + ": Handler error: " + e.getMessage());
      } finally {
        // Cleanup maps on disconnection to prevent memory leaks
          wChannel.remove(socket);
          clientOutputs.remove(socket);
          isAdmin.remove(socket);

        try {
          socket.close();
          System.out.println("Client " + remoteAddr + ": disconnected.");
        } catch (IOException e) {
          System.err.println("Client " + remoteAddr + ": Failed to close socket: " + e.getMessage());
        }
      }
    }
  }
}