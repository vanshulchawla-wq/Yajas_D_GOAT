import requests, re, hashlib
from PyPDF2 import PdfReader
from io import BytesIO
from pymongo import MongoClient

headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'}

c = MongoClient('mongodb+srv://elda:eldaonboard.streamlit.app@elda.wzcx5kq.mongodb.net/?appName=Elda')
db = c['ycexamprep']
papers_col = db['cbse_papers']

def extract_text_from_pdf(url):
    try:
        res = requests.get(url, headers=headers, timeout=30)
        if res.status_code != 200:
            return ""
        reader = PdfReader(BytesIO(res.content))
        text = ""
        for page in reader.pages:
            t = page.extract_text()
            if t:
                text += t + "\n"
        return text
    except:
        return ""

def parse_mcqs(text, subject, year):
    questions = []
    # Split by question numbers (1, 2, 3... or Q1, Q2...)
    blocks = re.split(r'\n\s*(\d{1,2})\s+', text)
    
    for i in range(1, len(blocks)-1, 2):
        block = blocks[i+1]
        
        # Look for A. B. C. D. pattern
        match = re.search(r'A\.\s*(.+?)\s*B\.\s*(.+?)\s*C\.\s*(.+?)\s*D\.\s*(.+?)(?:\s*\d{1,2}\s|\s*Section|\s*$)', block, re.DOTALL)
        if not match:
            # Try (a) (b) (c) (d) pattern
            match2 = re.search(r'\(a\)\s*(.+?)\s*\(b\)\s*(.+?)\s*\(c\)\s*(.+?)\s*\(d\)\s*(.+?)(?:\s*\d{1,2}\s|\s*$)', block, re.DOTALL)
            if match2:
                match = match2
        
        if match:
            # Get question text (everything before first option)
            q_text = block[:block.find('A.' if 'A.' in block else '(a)')].strip()
            q_text = re.sub(r'\s+', ' ', q_text).strip()
            q_text = re.sub(r'\s*1\s*$', '', q_text)  # Remove trailing marks
            
            if len(q_text) > 15 and len(q_text) < 500:
                options = []
                for j in range(1, 5):
                    opt = re.sub(r'\s+', ' ', match.group(j)).strip()
                    opt = re.sub(r'\s*1\s*$', '', opt)
                    options.append(opt)
                
                if all(0 < len(o) < 200 for o in options):
                    questions.append({
                        "text": q_text,
                        "options": options,
                        "correctIndex": 0,
                        "difficulty": "medium",
                        "id": hashlib.md5(q_text.encode()).hexdigest()[:12],
                    })
    
    return questions

# Get all sample papers (not marking schemes)
papers = list(papers_col.find({"type": "Sample Paper"}, {"_id": 0}))
print(f"Processing {len(papers)} sample papers...")

total_extracted = 0
updated = 0

for p in papers:
    url = p['url']
    subject = p['subject']
    year = p['year']
    
    print(f"\n  {subject} {year}: {p['filename']}...", end=" ")
    
    text = extract_text_from_pdf(url)
    if not text:
        print("FAILED to download")
        continue
    
    mcqs = parse_mcqs(text, subject, year)
    print(f"{len(mcqs)} MCQs extracted")
    
    if mcqs:
        # Update the paper document with extracted questions
        papers_col.update_one(
            {"url": url},
            {"$set": {"questions": mcqs, "has_live_test": True, "mcq_count": len(mcqs)}}
        )
        total_extracted += len(mcqs)
        updated += 1

print(f"\n\nDone! Extracted {total_extracted} MCQs from {updated} papers")
print(f"Papers with live tests: {papers_col.count_documents({'has_live_test': True})}")
print(f"Papers with PDF only: {papers_col.count_documents({'has_live_test': {'$ne': True}})}")
