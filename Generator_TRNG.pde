import processing.video.*;

Capture cam;
PImage img;
PrintWriter output, outputbinary,zamianabit;
boolean generowanie=false;

void na_szare()
{
  img=createImage(cam.width,cam.height,RGB);
  img.loadPixels();
  int x = cam.pixels.length;
  for (int i=0; i<x; i++)
  {
    img.pixels[i]=cam.pixels[i];
  }
  img.updatePixels();
  img.filter(GRAY);
  
}
PImage[] miniaturki= new PImage [10];
int counter=0;
int[] hist = new int[256];
int probki=0;

void binarka(int r)
{
  switch(counter%2)
  {
    case 0:
    {
      if(r%2==0)
      {
        outputbinary.println("0");
      }
      else 
        {
          outputbinary.println("1");
        }
      break;
    }
    case 1:
    {
      if(r%2==0)
      {
        outputbinary.println("1");
      }
      else
      {
        outputbinary.println("0");
      }
      break;
    }
  }
}

void wybor_zdjec()
{
  miniaturki[counter]=createImage(img.width,img.height,RGB);
  miniaturki[counter].loadPixels();
  int x = img.pixels.length;
  for (int i=0; i<x; i++)
  {
    if(int(brightness(img.pixels[i]))>2 && int(brightness(img.pixels[i]))<253)
    {
      miniaturki[counter].pixels[i]=cam.pixels[i];
      int r=int(red(cam.pixels[i]));
      int g=int(green(cam.pixels[i]));
      int b=int(blue(cam.pixels[i]));
      if(r>2&&r<253)
      {
        hist[r]++;
        binarka(r); 
        probki++;
        output.print(r+",");
      }
      if(g>2&&g<253)
      {
        hist[g]++;
        binarka(g);
        probki++;
        output.print(g+",");
      }
      if(b>2&&b<253)
      {
        hist[b]++;
        binarka(b);
        probki++;
        output.print(b+",");
      }
      
      
      
    }
    else 
    {
      miniaturki[counter].pixels[i]=color(255,0,0);
    }
  }
  miniaturki[counter].updatePixels();
}

void zamiana_bit()
{
  zamianabit = createWriter("zmienione_zera_i_jedynki.txt");
  String[] lines = loadStrings("Zera_i_jedynki.txt");
  //print(lines.length);
  int x=int(sqrt(lines.length));
  for(int i=0; i<x; i++)
  {
    for(int j=0; j<x; j++)
    {
      zamianabit.print(lines[i+j*x]);
    }
  }
  zamianabit.flush();
  zamianabit.close();
  
}

void drawTRNG()
{
  if (cam.available() == true) 
  {
    cam.read();
  }
  
  na_szare();
  if(generowanie)
  {
    if( frameCount %30 ==0)
    {
      wybor_zdjec();
      counter++;
      if(counter==10)
      {
        generowanie=false;
        output.flush(); 
        output.close();
        outputbinary.flush();
        outputbinary.close();
        zamiana_bit();
      }
    } 
  }  
}
