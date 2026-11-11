"""Chemins de la chaine d'outils (un seul endroit a modifier).

SDCC 4.1.0 local (tools/sdcc-4.1.0) : devkitSMS 1.2 n'est pas compatible
avec SDCC >= 4.2 (convention d'appel sdcccall(1)). Surcharge possible par les
variables d'environnement SDCC_BIN et DEVKITSMS.
"""
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SDCC_BIN = os.environ.get("SDCC_BIN", os.path.join(ROOT, "tools", "sdcc-4.1.0", "bin"))
DEVKITSMS = os.environ.get("DEVKITSMS", os.path.join(ROOT, "tools", "devkitSMS", "devkitSMS-1.2"))

SDCC = os.path.join(SDCC_BIN, "sdcc.exe")
SDAS = os.path.join(SDCC_BIN, "sdasz80.exe")
SDLD = os.path.join(SDCC_BIN, "sdldz80.exe")
SMSLIB_INC = os.path.join(DEVKITSMS, "SMSlib", "src")
SMSLIB = os.path.join(DEVKITSMS, "SMSlib", "SMSlib.lib")
CRT0 = os.path.join(DEVKITSMS, "crt0", "crt0_sms.rel")
IHX2SMS = os.path.join(DEVKITSMS, "ihx2sms", "Windows", "ihx2sms.exe")
FOLDER2C = os.path.join(DEVKITSMS, "folder2c", "Windows", "folder2c.exe")
ASSETS2BANKS = os.path.join(DEVKITSMS, "assets2banks", "Windows", "assets2banks.exe")
