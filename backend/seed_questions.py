"""
Run this once to seed the database with questions:
  python seed_questions.py
"""
import requests
import json

API_URL = "https://ycexamprep.onrender.com"  # Update after deploy

questions = [
    # ═══════════════ MATHEMATICS ═══════════════
    # Real Numbers
    {"subject": "Mathematics", "chapter": "Real Numbers", "difficulty": "easy", "text": "HCF of 26 and 91 is:", "options": ["13", "26", "7", "91"], "correctIndex": 0, "explanation": "26=2×13, 91=7×13. HCF=13"},
    {"subject": "Mathematics", "chapter": "Real Numbers", "difficulty": "easy", "text": "√2 is:", "options": ["Rational", "Irrational", "Integer", "Natural"], "correctIndex": 1},
    {"subject": "Mathematics", "chapter": "Real Numbers", "difficulty": "easy", "text": "The decimal expansion of 17/8 terminates after how many places?", "options": ["1", "2", "3", "4"], "correctIndex": 2},
    {"subject": "Mathematics", "chapter": "Real Numbers", "difficulty": "medium", "text": "If HCF(a,b)=12 and a×b=1800, then LCM(a,b) is:", "options": ["150", "120", "180", "90"], "correctIndex": 0, "explanation": "HCF×LCM=a×b. LCM=1800/12=150"},
    {"subject": "Mathematics", "chapter": "Real Numbers", "difficulty": "medium", "text": "LCM of 12, 15, 20 is:", "options": ["60", "120", "30", "180"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Real Numbers", "difficulty": "hard", "text": "For any positive integer n, 6ⁿ-5ⁿ always ends with:", "options": ["1", "3", "5", "7"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Real Numbers", "difficulty": "hard", "text": "If p/q is terminating decimal, q must be of form:", "options": ["2ⁿ×5ᵐ", "3ⁿ×5ᵐ", "2ⁿ×3ᵐ", "Any prime"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Real Numbers", "difficulty": "medium", "text": "Product of three consecutive integers is divisible by:", "options": ["4", "6", "8", "10"], "correctIndex": 1},
    # Polynomials
    {"subject": "Mathematics", "chapter": "Polynomials", "difficulty": "easy", "text": "If α,β are zeros of x²-5x+6, then α+β=", "options": ["5", "6", "-5", "-6"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Polynomials", "difficulty": "easy", "text": "Number of zeros of a cubic polynomial is at most:", "options": ["1", "2", "3", "4"], "correctIndex": 2},
    {"subject": "Mathematics", "chapter": "Polynomials", "difficulty": "medium", "text": "Quadratic polynomial with zeros 3 and -2:", "options": ["x²-x-6", "x²+x-6", "x²-x+6", "x²+x+6"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Polynomials", "difficulty": "medium", "text": "If α,β are zeros of x²+7x+12, then 1/α+1/β=", "options": ["-7/12", "7/12", "-12/7", "12/7"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Polynomials", "difficulty": "hard", "text": "If one zero of 2x²-3x+k is reciprocal of other, k=", "options": ["2", "3", "1", "-2"], "correctIndex": 0, "explanation": "Product of zeros=k/2=1, so k=2"},
    # Quadratic Equations
    {"subject": "Mathematics", "chapter": "Quadratic Equations", "difficulty": "easy", "text": "Roots of x²-7x+12=0:", "options": ["3,4", "2,6", "1,12", "-3,-4"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Quadratic Equations", "difficulty": "easy", "text": "Discriminant of 2x²-5x+3=0:", "options": ["1", "5", "7", "-1"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Quadratic Equations", "difficulty": "medium", "text": "For equal roots: b²=", "options": ["4ac", "2ac", "ac", "8ac"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Quadratic Equations", "difficulty": "hard", "text": "Equation with roots 2+√3 and 2-√3:", "options": ["x²-4x+1=0", "x²+4x+1=0", "x²-4x-1=0", "x²+4x-1=0"], "correctIndex": 0},
    # Trigonometry
    {"subject": "Mathematics", "chapter": "Trigonometry", "difficulty": "easy", "text": "sin30°+cos60°=", "options": ["1", "1/2", "√3/2", "0"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Trigonometry", "difficulty": "easy", "text": "sec²θ-tan²θ=", "options": ["0", "1", "-1", "2"], "correctIndex": 1},
    {"subject": "Mathematics", "chapter": "Trigonometry", "difficulty": "easy", "text": "tan45°=", "options": ["0", "1", "√3", "1/√3"], "correctIndex": 1},
    {"subject": "Mathematics", "chapter": "Trigonometry", "difficulty": "medium", "text": "If tanθ=4/3, then sinθ=", "options": ["4/5", "3/5", "3/4", "5/4"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Trigonometry", "difficulty": "medium", "text": "sin(90°-A)=", "options": ["sinA", "cosA", "tanA", "-sinA"], "correctIndex": 1},
    {"subject": "Mathematics", "chapter": "Trigonometry", "difficulty": "hard", "text": "(1+tan²A)/(1+cot²A)=", "options": ["tan²A", "sec²A", "cosec²A", "1"], "correctIndex": 0},
    # Statistics
    {"subject": "Mathematics", "chapter": "Statistics", "difficulty": "easy", "text": "Mean of first 5 natural numbers:", "options": ["2", "3", "4", "5"], "correctIndex": 1},
    {"subject": "Mathematics", "chapter": "Statistics", "difficulty": "easy", "text": "Mode of 2,3,4,4,5,5,5,6:", "options": ["4", "5", "6", "3"], "correctIndex": 1},
    {"subject": "Mathematics", "chapter": "Statistics", "difficulty": "medium", "text": "If mean=15, Σfi=20, then Σfixi=", "options": ["300", "200", "150", "100"], "correctIndex": 0},
    {"subject": "Mathematics", "chapter": "Statistics", "difficulty": "medium", "text": "Median class is determined by:", "options": ["Highest frequency", "n/2 th observation", "Mean", "Mode"], "correctIndex": 1},

    # ═══════════════ SCIENCE ═══════════════
    # Chemical Reactions
    {"subject": "Science", "chapter": "Chemical Reactions", "difficulty": "easy", "text": "Rusting of iron is:", "options": ["Combination", "Decomposition", "Corrosion", "Displacement"], "correctIndex": 2},
    {"subject": "Science", "chapter": "Chemical Reactions", "difficulty": "easy", "text": "Balancing equations satisfies law of:", "options": ["Conservation of mass", "Constant proportions", "Multiple proportions", "Gay-Lussac"], "correctIndex": 0},
    {"subject": "Science", "chapter": "Chemical Reactions", "difficulty": "easy", "text": "AgNO₃+NaCl→AgCl+NaNO₃ is:", "options": ["Combination", "Double displacement", "Decomposition", "Redox"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Chemical Reactions", "difficulty": "medium", "text": "In Zn+CuSO₄→ZnSO₄+Cu, zinc is:", "options": ["Oxidized", "Reduced", "Catalyst", "Unchanged"], "correctIndex": 0},
    {"subject": "Science", "chapter": "Chemical Reactions", "difficulty": "medium", "text": "Endothermic reaction example:", "options": ["Burning coal", "Decomposition of CaCO₃", "Respiration", "Neutralization"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Chemical Reactions", "difficulty": "hard", "text": "In electrolysis of water, volume ratio of H₂:O₂ is:", "options": ["1:1", "2:1", "1:2", "3:1"], "correctIndex": 1},
    # Acids Bases Salts
    {"subject": "Science", "chapter": "Acids Bases Salts", "difficulty": "easy", "text": "pH of pure water:", "options": ["0", "7", "14", "1"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Acids Bases Salts", "difficulty": "easy", "text": "Baking soda formula:", "options": ["NaHCO₃", "Na₂CO₃", "NaCl", "NaOH"], "correctIndex": 0},
    {"subject": "Science", "chapter": "Acids Bases Salts", "difficulty": "easy", "text": "Strong acid example:", "options": ["Acetic acid", "Citric acid", "HCl", "Carbonic acid"], "correctIndex": 2},
    {"subject": "Science", "chapter": "Acids Bases Salts", "difficulty": "medium", "text": "Plaster of Paris formula:", "options": ["CaSO₄.2H₂O", "CaSO₄.½H₂O", "CaSO₄", "Ca(OH)₂"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Acids Bases Salts", "difficulty": "hard", "text": "pH change from 5 to 3 means H⁺ increases by:", "options": ["2x", "10x", "100x", "1000x"], "correctIndex": 2},
    # Light
    {"subject": "Science", "chapter": "Light", "difficulty": "easy", "text": "Image by plane mirror is:", "options": ["Real, inverted", "Virtual, erect", "Real, erect", "Virtual, inverted"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Light", "difficulty": "easy", "text": "Concave mirror focal length 15cm, radius of curvature:", "options": ["15cm", "30cm", "7.5cm", "45cm"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Light", "difficulty": "medium", "text": "Mirror formula:", "options": ["1/v+1/u=1/f", "1/v-1/u=1/f", "v+u=f", "v-u=f"], "correctIndex": 0},
    {"subject": "Science", "chapter": "Light", "difficulty": "medium", "text": "Refractive index of glass is 1.5. Speed of light in glass:", "options": ["2×10⁸ m/s", "3×10⁸ m/s", "1.5×10⁸ m/s", "4.5×10⁸ m/s"], "correctIndex": 0},
    {"subject": "Science", "chapter": "Light", "difficulty": "hard", "text": "Power of lens with f=20cm:", "options": ["+5D", "-5D", "+20D", "+0.5D"], "correctIndex": 0, "explanation": "P=100/f(cm)=100/20=+5D"},
    # Electricity
    {"subject": "Science", "chapter": "Electricity", "difficulty": "easy", "text": "SI unit of current:", "options": ["Volt", "Ohm", "Ampere", "Watt"], "correctIndex": 2},
    {"subject": "Science", "chapter": "Electricity", "difficulty": "easy", "text": "V=IR is:", "options": ["Ohm's law", "Kirchhoff's law", "Faraday's law", "Coulomb's law"], "correctIndex": 0},
    {"subject": "Science", "chapter": "Electricity", "difficulty": "medium", "text": "Three 2Ω resistors in parallel:", "options": ["6Ω", "2/3Ω", "3Ω", "1Ω"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Electricity", "difficulty": "medium", "text": "1 kWh =", "options": ["3.6×10⁶ J", "3.6×10³ J", "36×10⁶ J", "360 J"], "correctIndex": 0},
    {"subject": "Science", "chapter": "Electricity", "difficulty": "hard", "text": "Heater draws 5A from 220V. Energy in 2 hours:", "options": ["2.2 kWh", "1.1 kWh", "0.55 kWh", "4.4 kWh"], "correctIndex": 0},
    # Life Processes
    {"subject": "Science", "chapter": "Life Processes", "difficulty": "easy", "text": "Photosynthesis occurs in:", "options": ["Mitochondria", "Chloroplast", "Ribosome", "Nucleus"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Life Processes", "difficulty": "easy", "text": "Excretory unit of kidney:", "options": ["Neuron", "Nephron", "Glomerulus", "Ureter"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Life Processes", "difficulty": "medium", "text": "Pepsin works in:", "options": ["Acidic medium", "Basic medium", "Neutral", "Any"], "correctIndex": 0},
    {"subject": "Science", "chapter": "Life Processes", "difficulty": "medium", "text": "Blood from heart to lungs via:", "options": ["Pulmonary vein", "Pulmonary artery", "Aorta", "Vena cava"], "correctIndex": 1},
    {"subject": "Science", "chapter": "Life Processes", "difficulty": "hard", "text": "Anaerobic respiration produces:", "options": ["CO₂+H₂O", "Ethanol+CO₂", "Lactic acid only", "O₂+H₂O"], "correctIndex": 1},

    # ═══════════════ SOCIAL STUDIES ═══════════════
    {"subject": "Social Studies", "chapter": "Nationalism in India", "difficulty": "easy", "text": "Who started the Civil Disobedience Movement?", "options": ["Nehru", "Gandhi", "Subhash", "Tilak"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Nationalism in India", "difficulty": "easy", "text": "Jallianwala Bagh massacre year:", "options": ["1919", "1920", "1930", "1942"], "correctIndex": 0},
    {"subject": "Social Studies", "chapter": "Nationalism in India", "difficulty": "medium", "text": "Simon Commission was boycotted because:", "options": ["It was expensive", "No Indian member", "It was delayed", "Wrong recommendations"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Nationalism in India", "difficulty": "medium", "text": "Dandi March was against:", "options": ["Land tax", "Salt law", "Press Act", "Rowlatt Act"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Nationalism in India", "difficulty": "hard", "text": "Poorna Swaraj was declared in:", "options": ["1929", "1930", "1931", "1942"], "correctIndex": 0},
    {"subject": "Social Studies", "chapter": "Rise of Nationalism Europe", "difficulty": "easy", "text": "Founder of Young Italy:", "options": ["Garibaldi", "Mazzini", "Cavour", "Bismarck"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Rise of Nationalism Europe", "difficulty": "easy", "text": "Treaty of Vienna signed in:", "options": ["1815", "1789", "1848", "1871"], "correctIndex": 0},
    {"subject": "Social Studies", "chapter": "Rise of Nationalism Europe", "difficulty": "medium", "text": "Zollverein was a:", "options": ["Military alliance", "Customs union", "Political party", "Treaty"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Resources and Development", "difficulty": "easy", "text": "Black soil is also called:", "options": ["Alluvial", "Regur", "Laterite", "Red soil"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Resources and Development", "difficulty": "medium", "text": "Khadar is:", "options": ["Old alluvial", "New alluvial", "Black soil", "Red soil"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Resources and Development", "difficulty": "hard", "text": "Soil erosion by wind is called:", "options": ["Sheet erosion", "Gully erosion", "Deflation", "Rill erosion"], "correctIndex": 2},
    {"subject": "Social Studies", "chapter": "Democracy and Diversity", "difficulty": "easy", "text": "Sri Lankan civil war was between:", "options": ["Hindus & Muslims", "Sinhalas & Tamils", "Buddhists & Christians", "North & South"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Democracy and Diversity", "difficulty": "medium", "text": "Power sharing reduces:", "options": ["Efficiency", "Conflict", "Growth", "Revenue"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Money and Credit", "difficulty": "easy", "text": "RBI issues currency on behalf of:", "options": ["State govt", "Central govt", "Banks", "Parliament"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Money and Credit", "difficulty": "easy", "text": "Collateral is:", "options": ["Interest rate", "Asset against loan", "Bank profit", "Deposit"], "correctIndex": 1},
    {"subject": "Social Studies", "chapter": "Money and Credit", "difficulty": "medium", "text": "SHG stands for:", "options": ["Self Help Group", "State Help Group", "Social Help Group", "Senior Help Group"], "correctIndex": 0},

    # ═══════════════ ENGLISH ═══════════════
    {"subject": "English", "chapter": "Grammar - Tenses", "difficulty": "easy", "text": "She ___ to school every day.", "options": ["go", "goes", "going", "gone"], "correctIndex": 1},
    {"subject": "English", "chapter": "Grammar - Tenses", "difficulty": "easy", "text": "They ___ the movie yesterday.", "options": ["watch", "watches", "watched", "watching"], "correctIndex": 2},
    {"subject": "English", "chapter": "Grammar - Tenses", "difficulty": "medium", "text": "By next year, I ___ my degree.", "options": ["complete", "will have completed", "completed", "completing"], "correctIndex": 1},
    {"subject": "English", "chapter": "Grammar - Tenses", "difficulty": "medium", "text": "He ___ here since 2010.", "options": ["lives", "lived", "has been living", "is living"], "correctIndex": 2},
    {"subject": "English", "chapter": "Grammar - Tenses", "difficulty": "hard", "text": "If I ___ rich, I would travel.", "options": ["am", "was", "were", "be"], "correctIndex": 2},
    {"subject": "English", "chapter": "Grammar - Voice", "difficulty": "easy", "text": "'The cat caught the mouse' in passive:", "options": ["The mouse was caught by the cat", "The mouse caught the cat", "The cat was caught", "Mouse is caught"], "correctIndex": 0},
    {"subject": "English", "chapter": "Grammar - Voice", "difficulty": "medium", "text": "'Open the door' in passive:", "options": ["The door is opened", "Let the door be opened", "Door was opened", "Opening the door"], "correctIndex": 1},
    {"subject": "English", "chapter": "Grammar - Voice", "difficulty": "hard", "text": "'People say he is honest' in passive:", "options": ["He is said to be honest", "It is said he is honest", "Both A and B", "He was said honest"], "correctIndex": 2},
    {"subject": "English", "chapter": "Reading Comprehension", "difficulty": "easy", "text": "Main idea is usually in:", "options": ["Last paragraph", "First/last sentences", "Middle only", "Title only"], "correctIndex": 1},
    {"subject": "English", "chapter": "Reading Comprehension", "difficulty": "medium", "text": "Antonym of 'benevolent':", "options": ["Kind", "Malevolent", "Generous", "Caring"], "correctIndex": 1},
    {"subject": "English", "chapter": "Reading Comprehension", "difficulty": "medium", "text": "Synonym of 'arduous':", "options": ["Easy", "Difficult", "Quick", "Simple"], "correctIndex": 1},
    {"subject": "English", "chapter": "Writing Skills", "difficulty": "easy", "text": "Formal letter closing:", "options": ["Love", "Yours faithfully", "See ya", "XOXO"], "correctIndex": 1},
    {"subject": "English", "chapter": "Writing Skills", "difficulty": "medium", "text": "Good essay intro should:", "options": ["Summarize all", "Hook the reader", "List points", "Be very long"], "correctIndex": 1},
    {"subject": "English", "chapter": "Literature", "difficulty": "easy", "text": "A sonnet has how many lines?", "options": ["10", "12", "14", "16"], "correctIndex": 2},
    {"subject": "English", "chapter": "Literature", "difficulty": "medium", "text": "'To be or not to be' is from:", "options": ["Macbeth", "Hamlet", "Othello", "King Lear"], "correctIndex": 1},

    # ═══════════════ FRENCH ═══════════════
    {"subject": "French", "chapter": "Greetings and Basics", "difficulty": "easy", "text": "'Bonjour' means:", "options": ["Goodbye", "Hello/Good day", "Thank you", "Please"], "correctIndex": 1},
    {"subject": "French", "chapter": "Greetings and Basics", "difficulty": "easy", "text": "'Comment allez-vous?' means:", "options": ["What is your name?", "How are you?", "Where are you?", "How old are you?"], "correctIndex": 1},
    {"subject": "French", "chapter": "Greetings and Basics", "difficulty": "easy", "text": "'Merci' means:", "options": ["Please", "Thank you", "Sorry", "Hello"], "correctIndex": 1},
    {"subject": "French", "chapter": "Greetings and Basics", "difficulty": "easy", "text": "'Au revoir' means:", "options": ["Hello", "Please", "Goodbye", "Sorry"], "correctIndex": 2},
    {"subject": "French", "chapter": "Articles and Gender", "difficulty": "easy", "text": "Masculine singular definite article:", "options": ["la", "le", "les", "un"], "correctIndex": 1},
    {"subject": "French", "chapter": "Articles and Gender", "difficulty": "easy", "text": "Plural definite article:", "options": ["le", "la", "les", "des"], "correctIndex": 2},
    {"subject": "French", "chapter": "Articles and Gender", "difficulty": "medium", "text": "Before vowel, le/la becomes:", "options": ["les", "l'", "un", "du"], "correctIndex": 1},
    {"subject": "French", "chapter": "Verbs Present Tense", "difficulty": "easy", "text": "'Je suis' means:", "options": ["I have", "I am", "I go", "I want"], "correctIndex": 1},
    {"subject": "French", "chapter": "Verbs Present Tense", "difficulty": "medium", "text": "'Avoir' for 'nous':", "options": ["avons", "avez", "ont", "ai"], "correctIndex": 0},
    {"subject": "French", "chapter": "Verbs Present Tense", "difficulty": "medium", "text": "'Ils parlent' means:", "options": ["He speaks", "They speak", "We speak", "You speak"], "correctIndex": 1},
    {"subject": "French", "chapter": "Verbs Present Tense", "difficulty": "hard", "text": "'Je fais mes devoirs' means:", "options": ["I do my homework", "I make my bed", "I eat food", "I read books"], "correctIndex": 0},
    {"subject": "French", "chapter": "Daily Life", "difficulty": "easy", "text": "'L'école' means:", "options": ["House", "School", "Park", "Shop"], "correctIndex": 1},
    {"subject": "French", "chapter": "Daily Life", "difficulty": "medium", "text": "'Quelle heure est-il?' asks about:", "options": ["Weather", "Time", "Date", "Name"], "correctIndex": 1},
    {"subject": "French", "chapter": "Daily Life", "difficulty": "medium", "text": "'Il fait beau' describes:", "options": ["Cold weather", "Nice weather", "Rain", "Snow"], "correctIndex": 1},
]

if __name__ == "__main__":
    print(f"Seeding {len(questions)} questions...")
    resp = requests.post(f"{API_URL}/questions/bulk", json={"questions": questions})
    print(resp.json())
