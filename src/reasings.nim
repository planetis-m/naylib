#   A port of Robert Penner's easing equations to C (http://robertpenner.com/easing/)
#
#   Robert Penner License
#   ---------------------------------------------------------------------------------
#   Open source under the BSD License.
#
#   Copyright (c) 2001 Robert Penner. All rights reserved.
#
#   Redistribution and use in source and binary forms, with or without modification,
#   are permitted provided that the following conditions are met:
#
#       - Redistributions of source code must retain the above copyright notice,
#         this list of conditions and the following disclaimer.
#       - Redistributions in binary form must reproduce the above copyright notice,
#         this list of conditions and the following disclaimer in the documentation
#         and/or other materials provided with the distribution.
#       - Neither the name of the author nor the names of contributors may be used
#         to endorse or promote products derived from this software without specific
#         prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
#   ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
#   WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#   IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
#   INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#   BUT NOT LIMITED TO, funcUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
#   LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
#   OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
#   OF THE POSSIBILITY OF SUCH DAMAGE.
#   ---------------------------------------------------------------------------------
#
#   Copyright (c) 2015-2022 Ramon Santamaria (@raysan5)
#
#   This software is provided "as-is", without any express or implied warranty. In no event
#   will the authors be held liable for any damages arising from the use of this software.
#
#   Permission is granted to anyone to use this software for any purpose, including commercial
#   applications, and to alter it and redistribute it freely, subject to the following restrictions:
#
#     1. The origin of this software must not be misrepresented; you must not claim that you
#     wrote the original software. If you use this software in a product, an acknowledgment
#     in the product documentation would be appreciated but is not required.
#
#     2. Altered source versions must be plainly marked as such, and must not be misrepresented
#     as being the original software.
#
#     3. This notice may not be removed or altered from any source distribution.
#
# ********************************************************************************************

## reasings - raylib easings library, based on Robert Penner library
##
## Useful easing functions for values animation
##
## How to use:
## The four inputs t,b,c,d are defined as follows:
## t = current time (in any unit measure, but same unit as duration)
## b = starting value to interpolate
## c = the total change in value of b that needs to occur
## d = total time it should take to complete (duration)
##
## Example:
##
## let currentTime = 0
## let duration = 100
## let startPositionX: float32 = 0.0
## let finalPositionX: float32 = 30.0
## let currentPositionX: float32 = startPositionX
##
## while currentPositionX < finalPositionX:
##   currentPositionX = linearIn(currentTime, startPositionX, finalPositionX - startPositionX, duration)
##   inc currentTime
##

import std/math

## Linear Easing functions
func linearNone*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Linear
  result = c * t / d + b

func linearIn*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Linear In
  result = c * t / d + b

func linearOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Linear Out
  result = c * t / d + b

func linearInOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Linear In Out
  result = c * t / d + b

## Sine Easing functions
func sineIn*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Sine In
  result = -c * cos(t / d * (Pi / 2)) + c + b

func sineOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Sine Out
  result = c * sin(t / d * (Pi / 2)) + b

func sineInOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Sine In Out
  result = -c / 2 * (cos(Pi * t / d) - 1) + b

## Circular Easing functions
func ircIn*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Circular In
  let t = t / d
  result = -c * (sqrt(1 - t * t) - 1) + b

func circOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Circular Out
  let t = t / d - 1
  result = c * sqrt(1 - t * t) + b

func circInOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Circular In Out
  var t = t / d * 2
  if t < 1:
    result = -(c / 2 * (sqrt(1 - t * t) - 1)) + b
  else:
    t = t - 2
    result = c / 2 * (sqrt(1 - t * t) + 1) + b

## Cubic Easing functions
func cubicIn*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Cubic In
  let t = t / d
  result = c * t * t * t + b

func cubicOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Cubic Out
  let t = t / d - 1
  result = c * (t * t * t + 1) + b

func cubicInOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Cubic In Out
  var t = t / d * 2
  if t < 1:
    result = c / 2 * t * t * t + b
  else:
    t = t - 2
    result = c / 2 * (t * t * t + 2) + b

## Quadratic Easing functions
func quadIn*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Quadratic In
  let t = t / d
  result = c * t * t + b

func quadOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Quadratic Out
  let t = t / d
  result = -c * t * (t - 2) + b

func quadInOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Quadratic In Out
  let t = t / d * 2
  if t < 1:
    result = c / 2 * t * t + b
  else:
    result = -c / 2 * ((t - 1) * (t - 3) - 1) + b

## Exponential Easing functions
func expoIn*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Exponential In
  if t == 0: result = b
  else: result = c * pow(2, 10 * (t / d - 1)) + b

func expoOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Exponential Out
  if t == d: result = b + c
  else: result = c * (-pow(2, -(10 * t / d)) + 1) + b

func expoInOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Exponential In Out
  var t = t
  if t == 0:
    result = b
  elif t == d:
    result = b + c
  elif (t = t / d * 2; t) < 1:
    result = c / 2 * pow(2, 10 * (t - 1)) + b
  else:
    result = c / 2 * (-pow(2, -10 * (t - 1)) + 2) + b

## Back Easing functions
func backIn*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Back In
  let s: float32 = 1.70158
  let t = t / d
  result = c * t * t * ((s + 1) * t - s) + b

func backOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Back Out
  let s: float32 = 1.70158
  let t = t / d - 1
  result = c * (t * t * ((s + 1) * t + s) + 1) + b

func backInOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Back In Out
  var s: float32 = 1.70158
  s = s * 1.525'f32
  var t = t / d * 2
  if t < 1:
    result = c / 2 * (t * t * ((s + 1) * t - s)) + b
  else:
    t = t - 2
    result = c / 2 * (t * t * ((s + 1) * t + s) + 2) + b

## Bounce Easing functions
func bounceOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Bounce Out
  var t = t / d
  if t < 1 / 2.75'f32:
    result = c * (7.5625'f32 * t * t) + b
  elif t < 2 / 2.75'f32:
    t = t - 1.5'f32 / 2.75'f32
    result = c * (7.5625'f32 * t * t + 0.75'f32) + b
  elif t < 2.5'f32 / 2.75'f32:
    t = t - 2.25'f32 / 2.75'f32
    result = c * (7.5625'f32 * t * t + 0.9375'f32) + b
  else:
    t = t - 2.625'f32 / 2.75'f32
    result = c * (7.5625'f32 * t * t + 0.984375'f32) + b

func bounceIn*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Bounce In
  result = c - bounceOut(d - t, 0, c, d) + b

func bounceInOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Bounce In Out
  if t < d / 2:
    result = bounceIn(t * 2, 0, c, d) * 0.5'f32 + b
  else:
    result = bounceOut(t * 2 - d, 0, c, d) * 0.5'f32 + c * 0.5'f32 + b

## Elastic Easing functions
func elasticIn*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Elastic In
  var t = t
  if t == 0:
    result = b
  elif (t = t / d; t) == 1:
    result = b + c
  else:
    let p = d * 0.3'f32
    let a = c
    let s = p / 4
    t = t - 1
    result = -(a * pow(2, 10 * t) * sin((t * d - s) * (2 * Pi) / p)) + b

func elasticOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Elastic Out
  var t = t
  if t == 0:
    result = b
  elif (t = t / d; t) == 1:
    result = b + c
  else:
    let p = d * 0.3'f32
    let a = c
    let s = p / 4
    result = a * pow(2, -(10 * t)) * sin((t * d - s) * (2 * Pi) / p) + c + b

func elasticInOut*(t, b, c, d: float32): float32 {.inline.} =
  ## Ease: Elastic In Out
  var t = t
  if t == 0:
    result = b
  elif (t = t / d * 2; t) == 2:
    result = b + c
  else:
    let p = d * (0.3'f32 * 1.5'f32)
    let a = c
    let s = p / 4
    if t < 1:
      t = t - 1
      result = -0.5'f32 * (a * pow(2, 10 * t) * sin((t * d - s) * (2 * Pi) / p)) + b
    else:
      t = t - 1
      result = a * pow(2, -10 * t) * sin((t * d - s) * (2 * Pi) / p) * 0.5'f32 + c + b
