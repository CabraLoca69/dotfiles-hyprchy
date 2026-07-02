#!/usr/bin/env bash

LAT="34.6S"
LON="58.4W"

echo "[Hyprsunset] Esperando al atardecer..."
sunwait wait set $LAT $LON
echo "[Hyprsunset] Atardecer detectado. Encendiendo filtro..."
hyprsunset -t 2500

echo "[Hyprsunset] Esperando al amanecer..."
sunwait wait rise $LAT $LON
echo "[Hyprsunset] Amanecer detectado. Apagando filtro..."
hyprsunset -t 6000
