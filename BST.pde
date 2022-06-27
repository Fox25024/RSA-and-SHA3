import java.math.BigInteger;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.math.*;
import java.util.*;

int ilu_bitowa_liczba=8;

String szyfruj(String input)
{
  try 
  {
    // Static getInstance method is called with hashing MD5
    MessageDigest md = MessageDigest.getInstance("SHA-256");
    // digest() method is called to calculate message digest 
    //  of an input digest() return array of byte 
    byte[] messageDigest = md.digest(input.getBytes());
    // Convert byte array into signum representation
    BigInteger no = new BigInteger(1, messageDigest);
    // Convert message digest into hex value 
    String hashtext = no.toString(16);
    while (hashtext.length() < 32) 
    {
      hashtext = "0" + hashtext;
    }
    return hashtext;
  } 
  // For specifying wrong message digest algorithms
  catch (NoSuchAlgorithmException e) 
  {
    throw new RuntimeException(e);
  }
}

void setup()
{
  frameRate(10000);
  cam = new Capture(this, "pipeline:autovideosrc");;
  cam.start();
  size(1280,720);
}

String ciag= "";
boolean zahaszowano=false;
String hasz;
int[] liczby =new int[256];

int[] RSA(int xx, int y)
{
  int p, q, n, z, d = 0, e, i;
  // The number to be encrypted and decrypted
  // 1st prime number p
  p = xx;
  // 2nd prime number q
  q = y;
  n = p * q;
  z = (p - 1) * (q - 1);
  for (e = 2; e < z; e++) 
  {
    // e is for public key exponent
    if (gcd(e, z) == 1) 
    {
      break;
    }
  }
  for (i = 0; i <= 9; i++) 
  {
    int x = 1 + (i * z);
    // d is for private key exponent
    if (x % e == 0) {
      d = x / e;
      break;
    }
  }
  int[] temp={e,d,n};
  return temp;
}
int gcd(int e, int z)
{
  if (e == 0)
  return z;
  else
  return gcd(z % e, e);
}

void hasz_to_number()
{
  try
  {
    for(int i=0; i<hasz.length();i++)
    {
      liczby[i] = Character.getNumericValue(hasz.charAt(i));
    }
  }
  catch (NumberFormatException ex)
  {
    ex.printStackTrace();
  }
}
double[] zakodowane=new double[256];
String kod="";
void kodowanie(int e,int n)
{
  for(int i=0; i<hasz.length(); i++)
  {
    zakodowane[i]=(Math.pow(liczby[i], e)) % n;
    int temp=(int)zakodowane[i];
    kod+=temp;
    if(i%16==0 && i>3 )
    {
      kod+="\n";
    }
  }
}

String odkodowane="";
void dekodowanie(int d, int n)
{
  
  BigInteger N = BigInteger.valueOf(n);
  for(int i=0; i<hasz.length(); i++)
  {
    println(i);
    BigInteger C = BigDecimal.valueOf(zakodowane[i]).toBigInteger();
    BigInteger temp=(C.pow(d)).mod(N);
    odkodowane+= temp.toString(16);
  }     
}

boolean czy_pierwsza(int n)
    {
 
        // Check if number is less than
        // equal to 1
        if (n <= 1)
            return false;
 
        // Check if number is 2
        else if (n == 2)
            return true;
 
        // Check if n is a multiple of 2
        else if (n % 2 == 0)
            return false;
 
        // If not, then just check the odds
        for (int i = 3; i <= Math.sqrt(n); i += 2)
        {
            if (n % i == 0)
                return false;
        }
        return true;
    }

int[] szukaj_pierwszych()
{
  String[] lines = loadStrings("zmienione_zera_i_jedynki.txt");
  String temp=lines[0];
  int[] pierwsza=new int[2];
  pierwsza[0]=0;
  pierwsza[1]=0;
  println(temp.length());
  fill(255);
  for(int i=0; i<temp.length()-ilu_bitowa_liczba; i++)
  {
    String temp2="";
    for(int j=0; j<ilu_bitowa_liczba; j++)
    {
      temp2+= temp.charAt(i+j);
    }
    
    int liczba=Integer.parseInt(temp2,2);
    if(czy_pierwsza(liczba))
    {
      if(liczba>=pierwsza[0] && liczba!=pierwszee[0]&&liczba!=pierwszee[1])
      {
        pierwsza[0]=liczba;
      }
      else if(liczba>=pierwsza[1]&& liczba!=pierwszee[1]&&liczba!=pierwszee[0]) pierwsza[1]=liczba;
      
    }
  }
  println(pierwsza[0]);
  println(pierwsza[1]);
  println(temp.length());
  
  return pierwsza;
}
int[] pierwszee={0,0};

void draw()
{
  if (cam.available() == true) 
  {
    cam.read();
  }
  na_szare();
  if(generowanie)
  {
    fill(255);
    
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
        pierwszee=szukaj_pierwszych();
        int[] temp=RSA(pierwszee[0],pierwszee[1]);
        kluczpubliczny=temp[0];
        kluczprywatny=temp[1];
        n=temp[2];
        klucze=true;
      }
    } 
  } 
  background(0);
  fill(255);
  textSize(32);
  text("Wpisz wiadomość:",30,30);
  text(ciag,30,70);
  rect(30,180,200,70);
  fill(0);
  textSize(20);
  text("Haszuj wiadomość",40,220);
  
  if(zahaszowano)
  {
    fill(255);
    text("Hasz wiadomości SHA-256:",250,210);
    text(hasz,250,250);
    hasz_to_number();
  }
  fill(255);
  rect(30,270,200,70);
  fill(0);
  text("Generuj klucze",40,310);
  if(klucze && !generowanie)
  {
    fill(255);
    text("Klucz publiczny:",250,300);
    text(kluczpubliczny,450,300);
    text("Klucz prywatny:",250,330);
    text(kluczprywatny,450,330);
  }
  else if(generowanie)
  {
    fill(255);
    text("Trwa Generowanie liczb losowych z generatora TRNG oraz ustalenie wartości kluczy",250,300);
  }
  fill(255);
  rect(30,360,200,70);
  fill(0);
  text("Koduj wiadomość",40,400);
  if(koduj_wiadomosc)
  {
    fill(255);
    text("Zakodowana wiadomość",40,460);
    text(kod,40,490);
  }
  fill(255);
  rect(660,360,220,70);
  fill(0);
  text("Dekoduj wiadomość",670,400);
  fill(255);
  textSize(16);
  text(odkodowane,660,460);
  
  
  
  
  
}
void keyPressed()
{
  if((key >= 'A' && key <= 'Z') || (key >= 'a' && key <= 'z'))
  {
    char temp=key;
    ciag+=temp;
  }
  else if(key==8)
  {
    String temp2="";
    for(int i=0; i<ciag.length()-1;i++)
    {
      temp2+= ciag.charAt(i);
    }
    ciag=temp2;
  }
  else if(key==32)
  {
    ciag+=" ";
  }
}
boolean klucze=false;
boolean koduj_wiadomosc=false;
int kluczpubliczny, kluczprywatny,n;

String bity="";

void mousePressed()
{
  if(mouseX<230 && mouseX>30 && mouseY>180 && mouseY<250)
  {
    hasz=szyfruj(ciag);
    zahaszowano=true;
  }
  else if(mouseX<230 && mouseX>30 && mouseY>270 && mouseY<340)
  {
    output = createWriter("wejscie.txt"); 
    outputbinary = createWriter("Zera_i_jedynki.txt");
    generowanie=true;
    counter=0;
    
  }
  else if(mouseX<230 && mouseX>30 && mouseY>360 && mouseY<430)
  {
    if(klucze)
    {
      kod="";
      koduj_wiadomosc=true;
      hasz_to_number();
      kodowanie(kluczpubliczny,n);
    }
  }
  else if(mouseX<880 && mouseX>660 && mouseY>360 && mouseY<430)
  {
    if(koduj_wiadomosc)
    {
      odkodowane="";
      dekodowanie(kluczprywatny, n);
    }
  }
}
