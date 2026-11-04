from pathlib import Path   # tool for working with file paths
import pdfplumber          # library that reads PDFs

# Find every PDF inside data/raw
pdf_files = sorted(Path("data/raw").glob("*.pdf"))
print("Found PDFs:", pdf_files)

# Open the first PDF and look inside
with pdfplumber.open(pdf_files[0]) as pdf:
    print("Number of pages:", len(pdf.pages))

    for i, page in enumerate(pdf.pages):        # go through every page
        tables = page.extract_tables()
        print(f"\nPage {i + 1}: {len(tables)} table(s) found")
        if tables:
            print("  First row:", tables[0][0])  # usually the header
            print("  Second row:", tables[0][1]) # first contestant

    page = pdf.pages[0]                # first page only
    text = page.extract_text()         # all the text on that page
    print("\n--- TEXT (first 1500 characters) ---")
    print(text[:1500])

    tables = page.extract_tables()     # try to detect tables
    print("\n--- Tables found on page 1:", len(tables))
    if tables:
        print("First 10 rows of the first table:")
        for row in tables[0][:10]:
            print(row)