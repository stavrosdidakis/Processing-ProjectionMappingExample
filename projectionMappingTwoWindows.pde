import java.awt.*;
import java.awt.image.BufferedImage;
import javax.swing.JFrame;

PImage screenImg1, screenImg2;
Robot robot;
Dimension screenSize;
int captureX1 = 0; // Start X location for first screen capture
int captureY1 = 0; // Start Y location for first screen capture
int captureWidth1 = 800; // Width of first screen capture
int captureHeight1 = 600; // Height of first screen capture
int captureX2 = 200; // Start X location for second screen capture
int captureY2 = 200; // Start Y location for second screen capture
int captureWidth2 = 600; // Width of second screen capture
int captureHeight2 = 400; // Height of second screen capture

// Control points for the first plane
float[] dstX1 = new float[4];
float[] dstY1 = new float[4];

// Control points for the second plane
float[] dstX2 = new float[4];
float[] dstY2 = new float[4];

boolean dragging = false;
int selectedCorner = -1;
boolean fullscreen = false;
boolean secondPlane = false; // Flag to toggle between the two planes

void setup() {
  size(1000, 1000, P2D);
  smooth();

  try {
    robot = new Robot();
    println("Robot initialized successfully");
  } catch (AWTException e) {
    e.printStackTrace();
  }

  // Get screen size
  screenSize = Toolkit.getDefaultToolkit().getScreenSize();

  // Initialize destination points for the first plane
  dstX1[0] = 100;
  dstY1[0] = 100;
  dstX1[1] = width / 2 - 100;
  dstY1[1] = 100;
  dstX1[2] = width / 2 - 100;
  dstY1[2] = height / 2 - 100;
  dstX1[3] = 100;
  dstY1[3] = height / 2 - 100;

  // Initialize destination points for the second plane
  dstX2[0] = width / 2 + 100;
  dstY2[0] = height / 2 + 100;
  dstX2[1] = width - 100;
  dstY2[1] = height / 2 + 100;
  dstX2[2] = width - 100;
  dstY2[2] = height - 100;
  dstX2[3] = width / 2 + 100;
  dstY2[3] = height - 100;

  // Fullscreen toggle setup
  surface.setResizable(true);
  surface.setTitle("Screen Capture Projection Mapping");
}

void draw() {
  background(0);

  // Capture the screen from the defined start location and with the defined dimensions for the first plane
  BufferedImage screenCapture1 = robot.createScreenCapture(new Rectangle(captureX1, captureY1, captureWidth1, captureHeight1));
  screenImg1 = convertToPImage(screenCapture1);

  // Capture the screen from the defined start location and with the defined dimensions for the second plane
  BufferedImage screenCapture2 = robot.createScreenCapture(new Rectangle(captureX2, captureY2, captureWidth2, captureHeight2));
  screenImg2 = convertToPImage(screenCapture2);

  // Display the screen capture on the first plane with custom corners
  beginShape();
  texture(screenImg1);
  vertex(dstX1[0], dstY1[0], 0, 0);
  vertex(dstX1[1], dstY1[1], screenImg1.width, 0);
  vertex(dstX1[2], dstY1[2], screenImg1.width, screenImg1.height);
  vertex(dstX1[3], dstY1[3], 0, screenImg1.height);
  endShape(CLOSE);

  // Display the screen capture on the second plane with custom corners
  beginShape();
  texture(screenImg2);
  vertex(dstX2[0], dstY2[0], 0, 0);
  vertex(dstX2[1], dstY2[1], screenImg2.width, 0);
  vertex(dstX2[2], dstY2[2], screenImg2.width, screenImg2.height);
  vertex(dstX2[3], dstY2[3], 0, screenImg2.height);
  endShape(CLOSE);

  // Draw control points for the first plane
  fill(255);
  for (int i = 0; i < 4; i++) {
    ellipse(dstX1[i], dstY1[i], 10, 10);
  }

  // Draw control points for the second plane
  fill(255, 0, 0);
  for (int i = 0; i < 4; i++) {
    ellipse(dstX2[i], dstY2[i], 10, 10);
  }

  // Display the start coordinates and dimensions for debugging
  fill(255);
  text("Plane 1 - Start X: " + captureX1 + " Start Y: " + captureY1, 10, height - 50);
  text("Plane 1 - Width: " + captureWidth1 + " Height: " + captureHeight1, 10, height - 30);
  text("Plane 2 - Start X: " + captureX2 + " Start Y: " + captureY2, 10, height - 10);
  text("Plane 2 - Width: " + captureWidth2 + " Height: " + captureHeight2, 10, height - 10);
}

// Key controls
void keyPressed() {
  if (key == 'f' || key == 'F') {
    fullscreen = !fullscreen;
    JFrame frame = (JFrame) ((processing.awt.PSurfaceAWT.SmoothCanvas) surface.getNative()).getFrame();
    if (fullscreen) {
      frame.setExtendedState(JFrame.MAXIMIZED_BOTH);
      frame.setUndecorated(true);
      surface.setSize(displayWidth, displayHeight);
    } else {
      frame.setUndecorated(false);
      frame.setExtendedState(JFrame.NORMAL);
      surface.setSize(1000, 1000);
      surface.setLocation((displayWidth - 1000) / 2, (displayHeight - 1000) / 2);
    }
  }
  if (key == 'p' || key == 'P') {
    secondPlane = !secondPlane;
  }

  if (!secondPlane) {
    if (key == CODED) {
      if (keyCode == UP) captureY1 -= 10;
      if (keyCode == DOWN) captureY1 += 10;
      if (keyCode == LEFT) captureX1 -= 10;
      if (keyCode == RIGHT) captureX1 += 10;
    }

    // Adjust capture area size for first plane
    if (key == 'q') { // Decrease capture width
      captureWidth1 = max(100, captureWidth1 - 10);
    }
    if (key == 'w') { // Increase capture width
      captureWidth1 = min(screenSize.width, captureWidth1 + 10);
    }
    if (key == 'e') { // Decrease capture height
      captureHeight1 = max(100, captureHeight1 - 10);
    }
    if (key == 'r') { // Increase capture height
      captureHeight1 = min(screenSize.height, captureHeight1 + 10);
    }
  } else {
    if (key == CODED) {
      if (keyCode == UP) captureY2 -= 10;
      if (keyCode == DOWN) captureY2 += 10;
      if (keyCode == LEFT) captureX2 -= 10;
      if (keyCode == RIGHT) captureX2 += 10;
    }

    // Adjust capture area size for second plane
    if (key == 'z') { // Decrease capture width
      captureWidth2 = max(100, captureWidth2 - 10);
    }
    if (key == 'x') { // Increase capture width
      captureWidth2 = min(screenSize.width, captureWidth2 + 10);
    }
    if (key == 'c') { // Decrease capture height
      captureHeight2 = max(100, captureHeight2 - 10);
    }
    if (key == 'v') { // Increase capture height
      captureHeight2 = min(screenSize.height, captureHeight2 + 10);
    }
  }
}

void mousePressed() {
  if (secondPlane) {
    for (int i = 0; i < 4; i++) {
      if (dist(mouseX, mouseY, dstX2[i], dstY2[i]) < 10) {
        dragging = true;
        selectedCorner = i;
        break;
      }
    }
  } else {
    for (int i = 0; i < 4; i++) {
      if (dist(mouseX, mouseY, dstX1[i], dstY1[i]) < 10) {
        dragging = true;
        selectedCorner = i;
        break;
      }
    }
  }
}

void mouseDragged() {
  if (dragging && selectedCorner != -1) {
    if (secondPlane) {
      dstX2[selectedCorner] = mouseX;
      dstY2[selectedCorner] = mouseY;
    } else {
      dstX1[selectedCorner] = mouseX;
      dstY1[selectedCorner] = mouseY;
    }
  }
}

void mouseReleased() {
  dragging = false;
  selectedCorner = -1;
}

PImage convertToPImage(BufferedImage bimg) {
  PImage img = createImage(bimg.getWidth(), bimg.getHeight(), ARGB);
  bimg.getRGB(0, 0, bimg.getWidth(), bimg.getHeight(), img.pixels, 0, bimg.getWidth());
  img.updatePixels();
  return img;
}
