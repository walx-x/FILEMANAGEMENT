import os
import asyncio
from telegram import Bot

# ===== Configurazione Telegram =====
TOKEN = "8575236810:AAF-KfFegEk8C2odsHuZxl0hCGn-oHTYkGs"
CHAT_ID = 5114048473

bot = Bot(token=TOKEN)

async def invia_notifica(messaggio):
    await bot.send_message(chat_id=CHAT_ID, text=messaggio)

# ===== Monitoraggio cartella =====
async def monitor_cartella(percorso):
    files_precedenti = set(os.listdir(percorso))
    while True:
        files_attuali = set(os.listdir(percorso))
        nuovi_file = files_attuali - files_precedenti
        if nuovi_file:
            await invia_notifica("Nuovi file nella cartella Downloads:\n" + "\n".join(nuovi_file))
        files_precedenti = files_attuali
        await asyncio.sleep(5)  # controllo ogni 5 secondi

async def main():
    percorso_da_monitorare = os.path.join(os.environ['USERPROFILE'], 'Downloads')
    await monitor_cartella(percorso_da_monitorare)

# ===== Avvio del loop asincrono =====
asyncio.run(main())
