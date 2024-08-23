import requests
from bs4 import BeautifulSoup

# URL website yang ingin di-scraping
url = "https://pemilu2024.kpu.go.id/pilpres/hitung-suara/36/3674/367405/3674051003/3674051003007"

# Mengirim permintaan HTTP GET ke URL
response = requests.get(url)

print("imam muhajir")
# Memeriksa status code response
if response.status_code == 200:
    # Parsing HTML response dengan BeautifulSoup
    soup = BeautifulSoup(response.content, "html.parser")
    print(soup)
    # Mencari elemen yang berisi data yang ingin di-scraping
    data_tps = soup.find_all("div", class_="data-tps")

    # Menyimpan data ke dalam list
    data_list = []
    for tps in data_tps:
        data = {
            "tps": tps.find("span", class_="nomor-tps").text,
            "suara_sah": tps.find("span", class_="suara-sah").text,
            "suara_tidak_sah": tps.find("span", class_="suara-tidak-sah").text,
            "paslon01": tps.find("span", class_="paslon01").text,
            "paslon02": tps.find("span", class_="paslon02").text,
        }
        data_list.append(data)

    # Menampilkan data
    for data in data_list:
        print(data)
else:
    print("Error:", response.status_code)
