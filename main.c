#include <allegro.h>
#include <stdio.h>

#include "assembler.h"

void showBottomInfo(BITMAP *info, double cX, double cY, double zoom)
{
    textprintf_ex(info, font, 10, 10, makecol(61, 61, 41), -1, "Zoom: %4.2f [+/-]", zoom);
    textprintf_ex(info, font, 10, 30, makecol(61, 61, 41), -1, "Re(c): %4.4f [LEFT/RIGHT]", cX);
    textprintf_ex(info, font, 10, 50, makecol(61, 61, 41), -1, "Im(c): %4.4f [UP/DOWN]", cY);
    textprintf_ex(info, font, 10, 70, makecol(61, 61, 41), -1, "Poruszanie się: [W/S/A/D]");
    textprintf_ex(info, font, 10, 90, makecol(61, 61, 41), -1, "Screenshot: [SPACE]");
    textprintf_ex(info, font, 10, 110, makecol(61, 61, 41), -1, "Wyjście: [ESC]");
    textprintf_ex(info, font, 10, 130, makecol(61, 61, 41), -1, "Pzdr, KZ");
}

void booting(BITMAP *info, BITMAP *boot)
{
	blit(boot, screen, 0, 0, 10, 10, boot->w, boot->h);
	textprintf_ex(info, font, 100, 70, makecol(61, 61, 41), -1, "Łączenie z serwerem Studia2...");
    blit(info, screen, 0, 0, 10, 480, info->w, info->h);

}


int main(int argc, char *argv[])
{

    // Allegro stuff.
    allegro_init();
    install_keyboard();
    set_color_depth( 24 );
    set_gfx_mode( GFX_AUTODETECT_WINDOWED, 480, 640, 0, 0 );
    clear_to_color( screen, makecol(194, 194, 163) );

	// Boot logo xD.

	BITMAP *boot = load_bitmap("boot.bmp", default_palette);

    // Utworzenie bitmapy na wynik, 24 bitowa - RGB.
    BITMAP *img = create_bitmap_ex(24, 460, 460);

    // Sprawdzenie czy z bitmapa wszystko ok.
    if(!img)
    {
      set_gfx_mode(GFX_TEXT, 0, 0, 0, 0);
      allegro_message("Nie mogę stworzyć obrazka img.");
      allegro_exit();
      return 1;
    }

    // Bitmapa na info.
    BITMAP *info = create_bitmap_ex(24, 460, 150);

    if(!info)
    {
      set_gfx_mode(GFX_TEXT, 0, 0, 0, 0);
      allegro_message("Nie mogę stworzyć obrazka info.");
      allegro_exit();
      return 1;
    }

    // Kolorowanie bitmapy info.
    clear_to_color(info, makecol(163, 163, 117));

    // <Czesc assemblerowa>

    double cX, cY, zoom, moveX, moveY;

    zoom = 1.0;           // zoom
    moveX = 0.0;          // przesuniecie w osi OX
    moveY = 0.0;          // przesuniecie w osi OY
    cX = -0.73;            // stala c - czesc rzeczywsita
    cY = 0.19;             // stala c - czesc urojona
    int maxiter = 1000;   // liczba iteracji - przyblizenie

    // Tablica Kolorowan o rozmiarze maxiter x 3, bo RGB.
    char colors[maxiter * 3];

    // Wypelnienie tablicy Kolorowan.
    int i = 0;
    while(i < maxiter)
    {
      colors[i++] = (i >> 5) * 18;
		  colors[i++] = (i >> 3 & 7) * 36;
		  colors[i++] = (i & 3) * 85;
    }

    //assembler(img->line, img->w, img->h, cX, cY, zoom, moveX, moveY, colors);
    //showBottomInfo(info, cX, cY, zoom);

    booting(info, boot);

    // Petla glowna:
    while(!key[KEY_ESC])
    {
      readkey();

      if(key[KEY_PLUS_PAD])
        zoom++;

      if(key[KEY_MINUS_PAD] && zoom > 1)
        zoom--;

      if(key[KEY_UP])
        cY -= 0.0050;

      if(key[KEY_DOWN])
        cY += 0.0050;

      if(key[KEY_RIGHT])
        cX -= 0.0050;

      if(key[KEY_LEFT])
        cX += 0.0050;

      if(key[KEY_W])
        moveY -= 0.50;

      if(key[KEY_S])
        moveY += 0.50;

      if(key[KEY_A])
        moveX -= 0.50;

      if(key[KEY_D])
        moveX += 0.50;

      if(key[KEY_SPACE])
        save_bitmap("screen.bmp", img, default_palette);

      assembler(img->line, img->w, img->h, cX, cY, zoom, moveX, moveY, colors);

      clear_to_color(info, makecol(163, 163, 117));
      clear_to_color(screen, makecol(194, 194, 163));
      showBottomInfo(info, cX, cY, zoom);
      blit(img, screen, 5, 0, 10, 10, img->w, img->h);
      blit(info, screen, 0, 0, 10, 480, info->w, info->h);

    }

    destroy_bitmap(img);
    allegro_exit();

    return 0;
}
//END_OF_MAIN();
