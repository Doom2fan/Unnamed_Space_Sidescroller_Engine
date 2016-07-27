/*
**  ??? - A DSFML game
**  Copyright (C) 2016  Chronos Ouroboros
**
**  This program is free software; you can redistribute it and/or modify
**  it under the terms of the GNU General Public License as published by
**  the Free Software Foundation; either version 2 of the License, or
**  (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License along
**  with this program; if not, write to the Free Software Foundation, Inc.,
**  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

module renderer;

import std.array;
import std.conv : to;
import std.format;
import std.stdio;
import dsfml.system;
import dsfml.graphics;
import dsfml.window;
import chr_tools.stack;
import gameDefs;
import actorDef;
import particleSys;

RenderWindow mainWindow;
Font primaryFont;
bool drawBoundingBoxes = true;
private Text fpsText;
private RectangleShape fpsRect;
private Clock renderTimeClock;
private Clock fpsClock;
private Shader plasmaBG;
private RenderStates plasmaBGStates;
private Clock plasmaClock;

/++ Initializes the video ++/
void videoInit () {
    // Initialize the video here. Load shaders, initialize classes, etc.
    // Any workarounds for weird/broken/shitty GPUs should be started/checked for here

    primaryFont = new Font ();
    fpsText = new Text ();
    fpsRect = new RectangleShape (Vector2f (50.0f, 35.0f));
    renderTimeClock = new Clock ();
    fpsClock = new Clock ();
    particleSystem = new ParticleSystem ();
    plasmaBG = new Shader ();
    plasmaClock = new Clock ();
    nullPointParticles [] = null;
    nullSpriteParticles [] = null;

    writeln ("Loading fonts");
    if (!primaryFont.loadFromFile ("resources/courier_new.ttf")) {
        writeln ("Could not load font courier_new.ttf. Loading agency_fb.ttf instead.");

        if (!primaryFont.loadFromFile ("resources/agency_fb.ttf"))
            writeln ("Could not load font agency_fb.ttf EITHER. What the FUCK did you do? :v");
    }

    writeln ("Loading shaders");
    if (!plasmaBG.loadFromFile ("resources/plasmaBG.vert", "resources/plasmaBG.frag")) {
        // error...
    }
    

    writeln ("Initializing video");
    fpsText.setFont (primaryFont);
    fpsText.setCharacterSize (15);
    fpsText.setColor (Color.White);
    fpsText.position = Vector2f (2.0f, 600.0f - (16 * 2.0f + 4.0f));
    fpsText.origin = Vector2f (0.0f, 0.0f);
    fpsRect.position = Vector2f (0.0f, 600.0f - 35.0f);
    plasmaBGStates = RenderStates.Default;
    plasmaBGStates.shader = plasmaBG;
    plasmaBGQuad = new VertexArray (PrimitiveType.TrianglesStrip, plasmaBGQuadVertices.length);
    for (int i = 0; i < plasmaBGQuadVertices.length; i++)
        plasmaBGQuad [i] = plasmaBGQuadVertices [i];
}

/++ Renders the game to the screen ++/
void renderGame (Duration ticTime, Duration elapsedTime) {
    renderTimeClock.restart ();
    // Clear the window with black color
    mainWindow.clear (Color.Black);

    if (plasmaClock.getElapsedTime ().total!"hnsecs" / 10000000 >= (12 * PI) * 3.5f)
        plasmaClock.restart ();

    if (fpsClock.getElapsedTime ().total!"seconds" >= 1) {
        int avgRT = cast (int) avgRenderTime.total!"msecs" / framesPerSec;
        fpsText.setString (format ("%s\n%s", framesPerSec, framesPerSec > 0 ? to!string (avgRT) : "???"));

        avgRenderTime = Duration.zero;
        framesPerSec = 0;
        fpsClock.restart ();
    }
    
    plasmaBG.setParameter ("u_time", cast (float) (cast (real) (plasmaClock.getElapsedTime ().total!"hnsecs") / 10000000));
    mainWindow.draw (plasmaBGQuad, plasmaBGStates);
    mainWindow.draw (fpsRect);
    mainWindow.draw (fpsText);
    mainWindow.draw (particleSystem);

    Stack!(Sprite *) [const (Texture)] sprListArr;
    foreach (obj; ActorList) {
        if (!obj)
            continue;

        if (cast (Actor) obj) {
            Actor actor = cast (Actor) obj;
            if (!actor.spr || !actor.spr.getTexture ()) {
                writefln ("Error: actor %X has no sprite!", &actor);
                continue;
            }

            RenderStates sprStates = RenderStates ();
            sprStates.transform.translate (cast (float) (actor.x - actor.width / 2.0f), cast (float) (actor.y - actor.height / 2.0f));
            mainWindow.draw (actor.spr, sprStates);
            if (drawBoundingBoxes && actor.width > 0 && actor.height > 0) {
                RectangleShape boundRect = new RectangleShape (Vector2f ((cast (float) actor.width) - 1.0f, (cast (float) actor.height) - 1.0f));
                boundRect.fillColor = Color.Transparent;
                boundRect.outlineColor = Color.Red;
                boundRect.outlineThickness = 1.0f;
                sprStates.transform.translate (cast (float) -(actor.width / 2.0f + 1.0f), cast (float) -(actor.height / 2.0f + 1.0f));
                mainWindow.draw (boundRect, sprStates);
            }
            /*if (!sprListArr [actor.spr.getTexture ()])
                sprListArr [actor.spr.getTexture ()] = new Stack!(Sprite *) (1000);

            if (sprListArr [actor.spr.getTexture ()].isFull)
                sprListArr [actor.spr.getTexture ()].resize (sprListArr [actor.spr.getTexture ()].max * 2);

            sprListArr [actor.spr.getTexture ()].push (&(actor.spr));*/
        }
    }

    /*foreach (Stack!(Sprite *) sprList; sprListArr) {
        while (!sprList.isEmpty) {
            mainWindow.draw (*sprList.pop ());
        }
    }*/

    // End the current frame
    mainWindow.display ();
    avgRenderTime += renderTimeClock.restart ();
    framesPerSec++;
}
static VertexArray plasmaBGQuad;
static Vertex [] plasmaBGQuadVertices = [
    Vector2f (  0,   0),
    Vector2f (  0, 600),
    Vector2f (800,   0),
    Vector2f (800, 600),
];