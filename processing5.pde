import oscP5.*;
import netP5.*;
import oscP5.OscMessage;
OscP5 osc;
NetAddress pd;
Table baseD;
int indice = 0;
int tiempoEntreFiguras = 30;
ArrayList<Figura> figuras = new ArrayList<Figura>();

void setup() {
  size(900, 700);
  frameRate(60);
  baseD = loadTable("Sleep_Efficiency.csv", "header");
  osc = new OscP5(this, 12000);
  pd = new NetAddress("127.0.0.1", 11111);
}

void draw() {
  background(20);
  if (frameCount % tiempoEntreFiguras == 0 && indice < baseD.getRowCount()) {
    figuras.add(new Figura(baseD.getRow(indice)));
    indice++;
  }
  for (int i = figuras.size() - 1; i >= 0; i--) {
    Figura f = figuras.get(i);
    f.update();
    f.display();
    if (f.y < -100) figuras.remove(i);
  }
}

class Figura {
  float x, y;
  float vy;
  float s; 
  float rem, deep, duracion;
  int c;            
  String tipo;
  float vibracion = 0;
  float angulo = 0;

  Figura(TableRow row) {

    rem = row.getFloat("REM sleep percentage");
    deep = row.getFloat("Deep sleep percentage");
    duracion = row.getFloat("Sleep duration");

    x = random(100, width - 100);
    y = height + 50;
    s = 50;

    int n = (int) random(3);

    if (n == 0) {
      tipo = "circulo";
      float brillo = map(duracion, 5, 10, 80, 255);
      c = color(brillo, 0, 0);
      vy = -4;
    }
    else if (n == 1) {
      tipo = "cuadrado";
      c = color(0, 120, 255);
      vy = map(rem, 15, 30, -10, -2);
    }
    else {
      tipo = "triangulo";
      c = color(0, 255, 120);
      vibracion = map(deep, 20, 75, 15, 0);
      vy = -4;
    }
    enviarSonido();
  }
  
  void update() {
    y += vy;
    if (tipo.equals("triangulo")) angulo += 0.25f;
  }

  void display() {
    noStroke();
    fill(c);
    if (tipo.equals("circulo")) {
      ellipse(x, y, s, s);
      if (duracion > 8) {
        fill(255, 80);
        ellipse(x, y, s + 20, s + 20);
      }
    }
    else if (tipo.equals("cuadrado")) {
      rectMode(CENTER);
      rect(x, y, s, s);
    }
    else if (tipo.equals("triangulo")) {
      pushMatrix();
      translate(x, y);
      if (vibracion > 0) {
        float ox = sin(angulo) * vibracion;
        float oy = cos(angulo * 1.3f) * vibracion;
        translate(ox, oy);
      }
      float h = s * sqrt(3) / 2;
      triangle(0, -h/2, -s/2, h/2, s/2, h/2);
      popMatrix();
    }
  }

  void enviarSonido() {
    OscMessage m = new OscMessage("/sleepBD");
    m.add(duracion);
    m.add(rem);
    m.add(deep);
    osc.send(m, pd);
  }
}
