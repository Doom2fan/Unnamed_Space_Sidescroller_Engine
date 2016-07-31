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

module gameDefs;

public import std.random;
public import std.stdio;
public import dsfml.system;
public import chr_tools.fixedpoint;

alias Fixed!(int,  16) accum;   /// Alias for a fixed-point value with 16 fractional bits
alias Fixed!(int,  24) accumL;  /// Alias for a fixed-point value with 24 fractional bits
alias Fixed!(long, 32) accumLL; /// Alias for a fixed-point value with 32 fractional bits

// Ticker values
static const int ticRate = 40; /// How many times per second the game is rendered.
static const int ticLength = 10000000 / ticRate; /// The amount of time between every tic/update
static const int ticThreshold = cast (int) (ticLength * 3.5f); /// The maximum amount of time between every tic/update
static const Duration ticThresholdDuration = hnsecs (ticThreshold); /// The maximum amount of time between every tic/update as a DSFML Time type
// Renderer values
static const int renderRate = 0; /// How many times per second the game is rendered. 0 means "always render"/"render every game loop cycle"
static if (renderRate > 0)
    static const int renderLength = 10000000 / renderRate; /// The amount of time between every render
else
    static const int renderLength = 0; /// The amount of time between every render

static bool gameFocused = true; /// Is the game focused?
static int framesPerSec = 0; /// Frames per second
static Duration avgRenderTime; /// Average render time per second in ms