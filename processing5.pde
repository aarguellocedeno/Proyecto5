import oscP5.*;
import netP5.*;
import oscP5.OscMessage;
OscP5 osc;
NetAddress pd;
Table baseD;
int indice = 0;
int tiempoEntreFiguras = 60;
ArrayList<Figura> figuras = new ArrayList<Figura>();

void setup() {
  size(900, 700);
  frameRate(60);
  baseD = loadTable("Sleep_Efficiency.csv", "header");
  osc = new OscP5(this, 12000);
  pd = new NetAddress("127.0.0.1", 11111);
}

void draw() {
  background(10,10,50);
  if (frameCount % tiempoEntreFiguras == 0 && indice < baseD.getRowCount()) {
    figuras.add(new Figura(baseD.getRow(indice), "circulo"));
    figuras.add(new Figura(baseD.getRow(indice), "cuadrado"));
    figuras.add(new Figura(baseD.getRow(indice), "triangulo"));
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
  
  Figura(TableRow row, String tipoFigura) {
    rem = row.getFloat("REM sleep percentage");
    deep = row.getFloat("Deep sleep percentage");
    duracion = row.getFloat("Sleep duration");
    
    tipo = tipoFigura;
    s = 50;
    
    if (tipo.equals("circulo")) {
      x =width * 0.25;
      y = height + 50;
      float brillo = map(duracion, 5, 10, 80, 255);
      c = color(brillo, 0, 0);
      vy = -4;
    }
    else if (tipo.equals("cuadrado")) {
      x = width * 0.5;
      y = height + 50;
      c = color(0, 120, 255);
      vy = map(rem, 15, 30, -10, -2);
    }
    else if (tipo.equals("triangulo")) {
      x = width * 0.75;
      y = height + 50;
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

