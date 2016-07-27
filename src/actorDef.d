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

module actorDef;

import dsfml.graphics;
import gameDefs;
public import player : PlayerPawn;
public import particleSys : Particle, SpriteParticle;

GameObject [] ActorList;
PlayerPawn [] PlayerList;

/++ The class for actor states ++/
struct ActorState {
    void function (void* []) action; /// The action to be executed when the state is entered
    void* [] actionArgs; /// The action's args
    Sprite spr; /// The state's sprite
    int length; /// The state's length
    uint next; /// The next state to go to

    void runAction () {
        if (action !is null)
            action (actionArgs);
    }
}

/++ The base class all actor types derive from ++/
class GameObject {
    // Physics and movement
    accum x, y; /// The actor's X-Y coordinates. These are at the center of the collision rectangle
    accum xVel, yVel; /// The actor's X-Y velocities

    /// Ticks/updates the actor
    void tick () {
        if (xVel != 0)
            x += xVel;
        if (yVel != 0)
            y += yVel;
    }

    this () {
        x = 0; y = 0;
        xVel = 0; yVel = 0;
    }
}

/++ The main actor class ++/
class Actor : GameObject {
    // Physics and movement
    int width, height; /// The actor's collision rectangle size
    int speed; /// The actor's speed
    accum acceleration; /// How fast the actor should accelerate to top speed. 0 means instantly
    int health, spawnHealth; /// The actor's health and default health
    Sprite spr; /// The actor's sprite
    private int state; /// The actor's current state
    private int stTime; /// Tics left until next state

    private ActorState [] states; /// The actor's states
    private int [string] stateLabels; /// The actor's state labels

    @property const (int [string]) getStateLabels () {
        return cast (const (int [string])) stateLabels;
    }

    override void tick () {
        if (xVel != 0) {
            x += xVel;
            if (isColliding ()) {
                accum xVelUndo = this.width / 4.0f * (xVel ? 1.0f : -1.0f);
                while (isColliding ())
                    x -= xVelUndo;
            }
        }
        if (yVel != 0) {
            y += yVel;
            if (isColliding ()) {
                accum yVelUndo = this.height / 4.0f * (yVel ? 1.0f : -1.0f);
                while (isColliding ())
                    y -= yVelUndo;
            }
        }

        doCollisionDetection ();

        stTime--;
        if (!stTime) {
            changeState (states [state].next);

            while (!stTime)
                changeState (states [state].next);
        }
    }

    this (int w = 1, int h = 1) {
        width = w;
        height = h;
        speed = 0;
        spawnHealth = 1000;
        health = spawnHealth;
        stateLabels ["Spawn"] = 0;
    }

    static bool overlaps (Actor A, Actor B) {
        if (abs (A.x - B.x) < (A.width  / 2 + B.width  / 2) &&
            abs (A.y - B.y) < (A.height / 2 + B.height / 2))
            return true;
        else
            return false;
    }

    bool isColliding () {
        if (this.width == 0 || this.height == 0)
            return false;

        foreach (obj; ActorList) {
            if (!obj || !(cast (Actor) obj))
                continue;

            Actor actor = cast (Actor) obj;
            if (actor == this || actor.width == 0 || actor.height == 0)
                continue;

            if (overlaps (this, actor))
                return true;
        }

        return false;
    }

    void doCollisionDetection () {
        if (this.width == 0 || this.height == 0)
            return;

        foreach (obj; ActorList) {
            if (!obj || !(cast (Actor) obj))
                continue;

            Actor actor = cast (Actor) obj;
            if (actor == this || actor.width == 0 || actor.height == 0)
                continue;

            if (overlaps (this, actor)) {
                writeln ("shit");
            }
        }
    }

    void changeState (int stNum) {
        state = stNum;
        spr = states [state].spr;
        stTime = states [state].length;
        states [state].runAction ();
    }

    void changeStateList (ActorState [] newStates, int [string] newStateLabels) {
        states = newStates;
        stateLabels = newStateLabels;

        if ("Spawn" in stateLabels)
            changeState (stateLabels ["Spawn"]);
    }
}

class CameraActor : GameObject {
    View viewport; /// The camera's view
    accum viewXVel, viewYVel; /// The view's x-y velocities

    this (View vport = new View (FloatRect (0, 0, 800, 600))) {
        viewport = vport;
        viewXVel = 0; viewYVel = 0;
    }
}

class Projectile : Actor {

}
