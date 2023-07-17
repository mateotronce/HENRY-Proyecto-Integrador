# Librerias a usar
import yfinance as yf
import pandas as pd


#Codigo
"""
Descargo las cotizaciones del banco galicia
"""

GGAL = yf.download("GGAL")

GGAL.to_csv("GGAL.csv")