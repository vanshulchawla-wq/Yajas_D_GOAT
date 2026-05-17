import hashlib
from pymongo import MongoClient

c = MongoClient('mongodb+srv://elda:eldaonboard.streamlit.app@elda.wzcx5kq.mongodb.net/?appName=Elda')
col = c['ycexamprep']['questions']

def add_batch(questions, label):
    for q in questions:
        q['id'] = hashlib.md5(q['text'].encode()).hexdigest()[:12]
        col.update_one({'id': q['id']}, {'$set': q}, upsert=True)
    print(f"  + {len(questions)} questions ({label}). Total in DB: {col.count_documents({})}")

print("="*50)
print("SEEDING 100 QUESTIONS PER SUBJECT")
print("="*50)

# ═══════════ MATHEMATICS BATCH 1 (25) ═══════════
print("\n[MATHEMATICS] Batch 1/4...")
add_batch([
{"subject":"Mathematics","chapter":"Real Numbers","difficulty":"medium","text":"The LCM of two numbers is 182 and their HCF is 13. If one number is 26, the other is:","options":["91","78","65","104"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Real Numbers","difficulty":"hard","text":"Three alarm clocks ring at intervals of 4, 12 and 20 minutes. If they start ringing together, after how many minutes will they ring together again?","options":["60","120","48","240"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Real Numbers","difficulty":"medium","text":"The decimal expansion of 129/(2^2 x 5^7 x 7^5) is:","options":["Terminating","Non-terminating repeating","Non-terminating non-repeating","None"],"correctIndex":1},
{"subject":"Mathematics","chapter":"Polynomials","difficulty":"hard","text":"If the zeroes of polynomial x^3 - 3x^2 + x + 1 are a-b, a, a+b, find a and b:","options":["a=1, b=±√2","a=2, b=±1","a=1, b=±1","a=3, b=±2"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Polynomials","difficulty":"medium","text":"If p(x) = x^2 - 2√2x + 1, then p(2√2) equals:","options":["1","0","-1","2"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Pair of Linear Equations","difficulty":"hard","text":"Places A and B are 100 km apart on a highway. One car starts from A and another from B at same time. If they travel in same direction, they meet in 5 hours. If opposite, in 1 hour. Speeds are:","options":["60 km/h, 40 km/h","50 km/h, 30 km/h","70 km/h, 30 km/h","55 km/h, 45 km/h"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Pair of Linear Equations","difficulty":"medium","text":"The value of k for which the system 2x+3y=5 and 4x+ky=10 has infinite solutions:","options":["6","3","4","8"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Quadratic Equations","difficulty":"hard","text":"The altitude of a right triangle is 7 cm less than its base. If hypotenuse is 13 cm, the other two sides are:","options":["5 cm, 12 cm","6 cm, 11 cm","4 cm, 13 cm","7 cm, 10 cm"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Quadratic Equations","difficulty":"medium","text":"The nature of roots of 2x^2 - 4x + 3 = 0 is:","options":["Real and distinct","Real and equal","No real roots","Cannot determine"],"correctIndex":2},
{"subject":"Mathematics","chapter":"Arithmetic Progressions","difficulty":"medium","text":"The sum of first 15 multiples of 8 is:","options":["960","1020","840","900"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Arithmetic Progressions","difficulty":"hard","text":"If sum of n terms of AP is 3n^2 + 5n, then which of its terms is 164?","options":["27th","26th","28th","25th"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Trigonometry","difficulty":"hard","text":"If sin(A+B) = 1 and cos(A-B) = √3/2, then A and B are:","options":["A=60°, B=30°","A=45°, B=45°","A=90°, B=0°","A=30°, B=60°"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Trigonometry","difficulty":"medium","text":"The value of (sin^2 63° + sin^2 27°)/(cos^2 17° + cos^2 73°) is:","options":["1","0","2","1/2"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Coordinate Geometry","difficulty":"medium","text":"The centroid of triangle with vertices (3,-5), (-7,4), (10,-2) is:","options":["(2,-1)","(1,-2)","(3,-3)","(0,0)"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Coordinate Geometry","difficulty":"hard","text":"If A(1,2), B(4,3) and C(6,6) are three vertices of parallelogram ABCD, then coordinates of D are:","options":["(3,5)","(2,4)","(5,3)","(4,6)"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Triangles","difficulty":"medium","text":"In a triangle, if square of one side equals sum of squares of other two sides, then angle opposite to first side is:","options":["90°","60°","45°","120°"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Triangles","difficulty":"hard","text":"Sides of two similar triangles are in ratio 4:9. Areas of these triangles are in ratio:","options":["16:81","4:9","2:3","8:18"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Circles","difficulty":"medium","text":"The length of tangent from point (5,1) to circle x^2+y^2+6x-4y-3=0 is:","options":["√57","7","√47","9"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Circles","difficulty":"hard","text":"If two tangents inclined at angle 60° are drawn to a circle of radius 3 cm, then length of each tangent is:","options":["3√3 cm","3 cm","6 cm","2√3 cm"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Surface Areas and Volumes","difficulty":"medium","text":"A cone of height 24 cm and radius 6 cm is made up of modelling clay. It is reshaped into a sphere. Radius of sphere is:","options":["6 cm","8 cm","4 cm","12 cm"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Surface Areas and Volumes","difficulty":"hard","text":"Water flows at rate of 10m/min through a pipe of diameter 5mm. Time to fill a conical vessel of diameter 40cm and depth 24cm:","options":["51.2 min","50 min","48 min","55 min"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Statistics","difficulty":"medium","text":"If mean of first n natural numbers is 5n/9, then n equals:","options":["9","5","4","10"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Statistics","difficulty":"hard","text":"The mean of 5 observations is 4.4. If three of them are 1, 2 and 6, and two observations are equal, find them:","options":["6.7 each","5.5 each","4.4 each","3.3 each"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Probability","difficulty":"medium","text":"A die is thrown once. P(getting a number between 2 and 6) is:","options":["3/6","4/6","2/6","5/6"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Probability","difficulty":"hard","text":"A box contains 90 discs numbered 1 to 90. One disc is drawn at random. P(two-digit number) is:","options":["81/90","80/90","9/10","89/90"],"correctIndex":0},
], "Math Batch 1")

# ═══════════ MATHEMATICS BATCH 2 (25) ═══════════
print("[MATHEMATICS] Batch 2/4...")
add_batch([
{"subject":"Mathematics","chapter":"Real Numbers","difficulty":"hard","text":"Show that any positive odd integer is of the form 6q+1, 6q+3, or 6q+5. If n=6q+3, then n is divisible by:","options":["3","6","2","9"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Real Numbers","difficulty":"medium","text":"If a=2^3 x 3, b=2 x 3 x 5, c=3^n x 5, and LCM(a,b,c)=2^3 x 3^2 x 5, then n=","options":["2","1","3","4"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Polynomials","difficulty":"medium","text":"If sum of zeroes of kx^2+2x+3k is equal to their product, then k=","options":["-2/3","2/3","3/2","-3/2"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Polynomials","difficulty":"hard","text":"If zeroes of x^2-kx+6 are in ratio 3:2, then k=","options":["5","-5","±5","6"],"correctIndex":2},
{"subject":"Mathematics","chapter":"Pair of Linear Equations","difficulty":"medium","text":"Father's age is three times the sum of ages of his two children. After 5 years his age will be twice the sum of ages of two children. Father's present age:","options":["45","40","50","35"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Pair of Linear Equations","difficulty":"hard","text":"8 men and 12 boys can finish a piece of work in 10 days while 6 men and 8 boys finish it in 14 days. One man alone takes:","options":["140 days","70 days","100 days","120 days"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Quadratic Equations","difficulty":"medium","text":"If -5 is a root of 2x^2+px-15=0 and p(x^2+x)+k=0 has equal roots, then k=","options":["7/4","4/7","7","4"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Quadratic Equations","difficulty":"hard","text":"A motor boat whose speed is 18 km/h in still water takes 1 hour more to go 24 km upstream than downstream. Speed of stream:","options":["6 km/h","4 km/h","8 km/h","3 km/h"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Arithmetic Progressions","difficulty":"hard","text":"Sum of first q terms of an AP is 63q - 3q^2. If its pth term is -60, find p:","options":["21","20","11","22"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Arithmetic Progressions","difficulty":"medium","text":"Which term of AP 3,15,27,39... will be 132 more than its 54th term?","options":["65th","64th","66th","60th"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Trigonometry","difficulty":"medium","text":"If √3 tan θ = 1, then sin^2 θ - cos^2 θ =","options":["-1/2","1/2","1","-1"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Trigonometry","difficulty":"hard","text":"Evaluate: (sin 25° cos 65° + cos 25° sin 65°) / (tan^2 10° - cot^2 80°)","options":["Undefined (division by 0)","1","0","-1"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Coordinate Geometry","difficulty":"hard","text":"Find the ratio in which the point (-3,p) divides the line segment joining (-5,-4) and (-2,3). Hence find p:","options":["2:1, p=2/3","1:2, p=-1","3:1, p=1","1:1, p=-1/2"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Coordinate Geometry","difficulty":"medium","text":"The area of triangle formed by points (0,0), (3,0) and (0,4) is:","options":["6 sq units","12 sq units","7 sq units","24 sq units"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Triangles","difficulty":"hard","text":"In △ABC, AD⊥BC and AD^2=BD×DC. Then △ABC is:","options":["Right angled at A","Isosceles","Equilateral","Right angled at D"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Circles","difficulty":"medium","text":"A tangent PQ at point P of a circle of radius 5 cm meets a line through centre O at point Q so that OQ=12 cm. Length PQ is:","options":["√119 cm","12 cm","13 cm","√144 cm"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Surface Areas and Volumes","difficulty":"hard","text":"A gulab jamun contains sugar syrup up to about 30% of its volume. Find approximately how much syrup would be found in 45 gulab jamuns, each shaped like a cylinder with two hemispherical ends, length 5cm and diameter 2.8cm:","options":["338 cm³","450 cm³","250 cm³","500 cm³"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Surface Areas and Volumes","difficulty":"medium","text":"The ratio of total surface area of a solid hemisphere to the square of its radius is:","options":["3π","2π","4π","π"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Statistics","difficulty":"hard","text":"The median of following data is 525. Find x if total frequency is 100: CI: 0-100(2), 100-200(5), 200-300(x), 300-400(12), 400-500(17), 500-600(20), 600-700(y), 700-800(9), 800-900(7), 900-1000(4)","options":["x=9","x=12","x=15","x=6"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Statistics","difficulty":"medium","text":"Mode of the data: 15,14,19,20,14,15,16,14,15,18,14,19,15,17,15 is:","options":["15","14","16","19"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Probability","difficulty":"hard","text":"A game consists of tossing a coin 3 times. Hanif wins if all tosses give same result (3H or 3T) and loses otherwise. P(Hanif losing):","options":["3/4","1/4","1/2","7/8"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Probability","difficulty":"medium","text":"Two customers visit a shop. Each can enter one of 3 doors. P(both enter through different doors):","options":["2/3","1/3","4/9","5/9"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Real Numbers","difficulty":"medium","text":"The HCF of 867 and 255 is:","options":["51","3","17","255"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Quadratic Equations","difficulty":"medium","text":"The product of two consecutive positive integers is 306. The quadratic equation for this is:","options":["x^2+x-306=0","x^2-x-306=0","x^2+x+306=0","x^2-306=0"],"correctIndex":0},
{"subject":"Mathematics","chapter":"Arithmetic Progressions","difficulty":"medium","text":"Find the number of terms in AP: 7, 13, 19, ..., 205:","options":["34","33","35","32"],"correctIndex":0},
], "Math Batch 2")

print(f"\n  Mathematics total: {col.count_documents({'subject':'Mathematics'})}")
PYEOF