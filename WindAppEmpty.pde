import io.socket.*;
import org.json.*;

//for communicating with the wind server we need a socket 
SocketIO socket;
             
//wind speed & direction             
int windSpeed = 0;
String windDirection = "";
String statusStr = "";

// the url server is set in the setup function
String urlServer = "";
boolean isConnected = false;
//turn this to true when connecting to the wifi connection created by the Raspberry Pi
final boolean accessPointWifiMode = false;

// the setup is only executed once at the startup 
void setup() {
  
  size(displayWidth, displayHeight);
  
  if(accessPointWifiMode){
    urlServer = "http://192.168.42.1:8080/";
  }else{
    urlServer = "http://outside.mediawerf.net:443/";
  }
  //we connect to the wind server
  initSockets();

  //initializing graphics
  textSize(18);
  smooth(); 
}


void draw()
{
  //we clean the screen with a background color
  background(60,0,0);
  //we choose the text color 
  fill(200);
  //we print the wind direction and screen on the screen
  statusStr = (isConnected) ? "connected, wind direction="+windDirection + ", speed="+windSpeed : "not connected";
  text(statusStr, 20,40);
}

 
void initSockets(){

//Sockets
  try
  {
    socket = new SocketIO(urlServer);
  }
  catch(Exception ex)
  {
    println("Bad URL");
  }

  socket.connect(new IOCallback() {
    @Override
      public void onMessage(JSONObject json, IOAcknowledge ack) {
    }

    @Override
      public void onMessage(String data, IOAcknowledge ack) {
      System.out.println("Server said: " + data);
    }

    @Override
      public void onError(SocketIOException socketIOException) {
      System.out.println("an Error occured");
         socketIOException.printStackTrace();  
    }

    @Override
      public void onDisconnect() {
      System.out.println("Connection terminated.");
      isConnected = false;
        }

    @Override
      public void onConnect() {
      System.out.println("Connection established");
      isConnected = true;
    }

    @Override
      public void on(String event, IOAcknowledge ack, Object... args) {      

        if ("windDirectionUpdate".equals(event) && args.length > 0) {                
         try{
            JSONObject json = (JSONObject)args[0];
             windDirection = json.getString("value");
             println("windDirection="+windDirection);             
             
     }catch (JSONException e) {                  
           e.printStackTrace();
          println("Exception on!! "+e.getMessage());
        }           
      }
          
      //speed
     if ("windSpeedUpdate".equals(event) && args.length > 0) {                
         try{
            JSONObject json = (JSONObject)args[0];
             windSpeed = json.getInt("value");
           println("windSpeed="+windSpeed);
 
         }catch (JSONException e) {
           e.printStackTrace();
          println("Exception on!! "+e.getMessage());
        }                   
      }                  
    }
  }
  );  

}
