import requests, re
from pymongo import MongoClient

headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'}
base = 'https://cbseacademic.nic.in/'

pages = [
    ('2025-26', 'SQP_CLASSX_2025-26.html'),
    ('2024-25', 'SQP_CLASSX_2024-25.html'),
    ('2023-24', 'SQP_CLASSX_2023-24.html'),
    ('2022-23', 'SQP_CLASSX_2022-23.html'),
    ('2021-22', 'SQP_CLASSX_2021-22.html'),
    ('2020-21', 'SQP_CLASSX_2020-21.html'),
    ('2019-20', 'SQP_CLASSX_2019_20.html'),
]

# Order matters - check socialscience before science, homescience excluded
def detect_subject(pdf_lower):
    if 'homescience' in pdf_lower:
        return None  # Skip home science
    if 'socialscience' in pdf_lower or 'social' in pdf_lower:
        return 'Social Studies'
    if 'math' in pdf_lower:
        return 'Mathematics'
    if 'science' in pdf_lower:
        return 'Science'
    if 'english' in pdf_lower:
        return 'English'
    if 'french' in pdf_lower:
        return 'French'
    return None

all_papers = []

for year, page in pages:
    url = base + page
    res = requests.get(url, headers=headers, timeout=15)
    if res.status_code != 200:
        print(f'{year}: FAILED ({res.status_code})')
        continue

    pdf_links = re.findall(r'href=["\']([^"\']*\.pdf)["\']', res.text)
    print(f'{year}: {len(pdf_links)} PDFs')

    for pdf in pdf_links:
        pdf_lower = pdf.lower().replace('-', '').replace('_', '').replace(' ', '')
        full_url = pdf if pdf.startswith('http') else base + pdf

        subject = detect_subject(pdf_lower)
        if not subject:
            continue

        # Skip Hindi versions
        if '_hi' in pdf.lower() or 'hi-' in pdf.lower() or 'hindi' in pdf.lower():
            continue

        is_ms = 'ms' in pdf_lower
        paper_type = 'Marking Scheme' if is_ms else 'Sample Paper'
        print(f'  [{subject}] {paper_type}: {full_url.split("/")[-1]}')
        all_papers.append({
            'year': year,
            'subject': subject,
            'type': paper_type,
            'url': full_url,
            'filename': full_url.split('/')[-1],
        })

print(f'\nTotal papers found: {len(all_papers)}')

# Save to MongoDB
c = MongoClient('mongodb+srv://elda:eldaonboard.streamlit.app@elda.wzcx5kq.mongodb.net/?appName=Elda')
db = c['ycexamprep']
col = db['cbse_papers']
col.drop()

for p in all_papers:
    col.insert_one(p)

print(f'Saved {len(all_papers)} papers to MongoDB')
for subj in sorted(set(p['subject'] for p in all_papers)):
    count = len([p for p in all_papers if p['subject'] == subj])
    print(f'  {subj}: {count} papers')
