/*
**  ??? - A DSFML game
**  Copyright (C) 2015  Chronos Ouroboros
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

module player;

import actorDef;
import gameDefs;

enum PlayerControls : int {
    Attack = 1,
}

class PlayerPawn : Actor {
    CameraActor camera; /// The player's camera
    PlayerControls controls;
    accum forwardInput;
    accum sidewaysInput;

    uint pID; /// Player id/number

    this (int w = 1, int h = 1) {
        camera = new CameraActor ();
        Actor A = new Actor (), B = new Actor ();
        A.flags = ObjFlags.SOLID; B.flags = ObjFlags.SOLID;
        writeln (Actor.overlaps (A, B));
    }

    bool isControlPressed (PlayerControls ctrl) {
        return cast (bool) (cast (int) controls & ctrl);
    }
}