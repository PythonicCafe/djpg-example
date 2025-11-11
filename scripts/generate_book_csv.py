import csv
from urllib.request import urlopen


def book_lines(book_id):
    "Download a book from Gutenberg.org and yields its lines, skipping header/footer from Gutenberg"
    url = f"https://www.gutenberg.org/cache/epub/{book_id}/pg{book_id}.txt"
    response = urlopen(url)
    content = response.read().decode("utf-8")
    started = False
    for line in content.splitlines():
        line = line.strip()
        if not line:
            continue
        if line.startswith("*** START OF THE PROJECT GUTENBERG EBOOK"):
            started = True
            continue
        if not started:
            continue
        elif started and line.startswith("*** END OF THE PROJECT GUTENBERG EBOOK"):
            break
        yield line


def main():
    "Download 20 Brazilian/Portuguese books from Gutenberg and save each line as a CSV row (~107k lines total)"

    books = {
        15047: "Bases da ortografia portuguesa by Gonçalves Viana and Abreu",
        16384: "O Mandarim by Eça de Queirós",
        17515: "A Relíquia by Eça de Queirós",
        23620: "Orpheu Nº1 by José de Almada Negreiros et al.",
        23621: "Orpheu Nº2 by Alvaro de Campos et al.",
        27236: "Os Lusíadas by Luís de Camões",
        31347: "Contos by Eça de Queirós",
        42942: "O Primo Bazilio: Episodio Domestico by Eça de Queirós",
        45461: "Ultimatum by Alvaro de Campos",
        53101: "A Mao e A Luva by Machado de Assis",
        54829: "Memorias Posthumas de Braz Cubas by Machado de Assis",
        55682: "Quincas Borba by Machado de Assis",
        55752: "Dom Casmurro by Machado de Assis",
        56737: "Esau e Jacob by Machado de Assis",
        62525: "Historias Brazileiras by Visconde de Alfredo d'Escragnolle Taunay Taunay",
        67162: "Helena by Machado de Assis",
        67725: "O Guarany: romance brazileiro, Vol. 2 (of 2) by José Martiniano de Alencar",
        67740: "Iracema by José Martiniano de Alencar",
        67935: "Reliquias de Casa Velha by Machado de Assis",
        69187: "O Cortiço by Aluísio Azevedo",
    }
    csv_filename = "book-lines.csv"
    with open(csv_filename, mode="w") as fobj:
        writer = csv.DictWriter(fobj, fieldnames=["line"])
        writer.writeheader()
        for book_id, title in books.items():
            print(f"Downloading book {title}")
            for line in book_lines(book_id):
                writer.writerow({"line": line})


if __name__ == "__main__":
    main()
