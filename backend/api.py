"""
YCExamPrep Backend API
======================
MongoDB Collections:
  - questions: All questions (subject, chapter, difficulty, text, options, correctIndex, explanation)
  - results: Test results per user
  - weekly_tests: Auto-generated weekly tests

Endpoints:
  GET  /subjects              - List all subjects with chapter counts
  GET  /questions/{subject}/{chapter}?difficulty=&limit=&exclude_mastered=
  POST /questions/bulk        - Add questions in bulk (for seeding)
  GET  /weekly-test           - Get this week's test (auto-generated)
  POST /submit-test           - Submit test result, returns score + bookmarks wrong answers
  GET  /results/{user_id}     - Get all results for a user
  GET  /stats/{user_id}       - Get performance stats
  GET  /bookmarks/{user_id}   - Get bookmarked (wrong) questions
  DELETE /bookmarks/{user_id}/{question_id} - Remove bookmark
  GET  /health                - Health check
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from pymongo import MongoClient
from datetime import datetime, timedelta
from typing import Optional
import os
import random
import hashlib

app = FastAPI(title="YCExamPrep API")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

MONGO_URI = os.environ.get("MONGO_URI", "mongodb+srv://vanshulchawla:Vanshul1234@cluster0.ixmgo.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")

_client = None
def get_db():
    global _client
    if _client is None:
        _client = MongoClient(MONGO_URI)
    return _client["ycexamprep"]

def questions_col(): return get_db()["questions"]
def results_col(): return get_db()["results"]
def weekly_col(): return get_db()["weekly_tests"]
def bookmarks_col(): return get_db()["bookmarks"]


@app.get("/health")
def health():
    return {"ok": True, "service": "YCExamPrep"}


@app.get("/subjects")
def get_subjects():
    """Get all subjects with chapter list and question counts."""
    pipeline = [
        {"$group": {"_id": {"subject": "$subject", "chapter": "$chapter"}, "count": {"$sum": 1}}},
        {"$group": {"_id": "$_id.subject", "chapters": {"$push": {"name": "$_id.chapter", "count": "$count"}}}},
        {"$sort": {"_id": 1}}
    ]
    result = list(questions_col().aggregate(pipeline))
    subjects = []
    icons = {"Mathematics": "📐", "Science": "🔬", "Social Studies": "🌍", "English": "📖", "French": "🇫🇷"}
    colors = {"Mathematics": 0xFF1565C0, "Science": 0xFF2E7D32, "Social Studies": 0xFFE65100, "English": 0xFF6A1B9A, "French": 0xFFC62828}
    for r in result:
        name = r["_id"]
        subjects.append({
            "name": name,
            "icon": icons.get(name, "📚"),
            "color": colors.get(name, 0xFF424242),
            "chapters": sorted(r["chapters"], key=lambda c: c["name"]),
            "totalQuestions": sum(c["count"] for c in r["chapters"]),
        })
    return subjects


@app.get("/questions/{subject}/{chapter}")
def get_questions(subject: str, chapter: str, difficulty: Optional[str] = None, limit: int = 10, user_id: str = "default"):
    """Get questions for a test. Excludes mastered questions."""
    query = {"subject": subject, "chapter": chapter}
    if difficulty:
        query["difficulty"] = difficulty

    # Get mastered question IDs for this user
    mastered = set()
    user_mastery = get_db()["mastery"].find_one({"user_id": user_id})
    if user_mastery:
        mastered = {qid for qid, count in user_mastery.get("counts", {}).items() if count >= 3}

    all_q = list(questions_col().find(query, {"_id": 0}))
    # Filter out mastered
    filtered = [q for q in all_q if q.get("id", "") not in mastered]
    # If not enough unmastered, include some mastered
    if len(filtered) < limit:
        filtered = all_q

    random.shuffle(filtered)
    return filtered[:limit]


class BulkQuestions(BaseModel):
    questions: list

@app.post("/questions/bulk")
def add_questions_bulk(req: BulkQuestions):
    """Add questions in bulk. Each question needs: subject, chapter, difficulty, text, options, correctIndex."""
    added = 0
    for q in req.questions:
        # Generate ID from text hash
        q["id"] = hashlib.md5(q["text"].encode()).hexdigest()[:12]
        # Upsert to avoid duplicates
        questions_col().update_one({"id": q["id"]}, {"$set": q}, upsert=True)
        added += 1
    return {"ok": True, "added": added, "total": questions_col().count_documents({})}


@app.get("/weekly-test")
def get_weekly_test(user_id: str = "default"):
    """Get this week's test. Auto-generates if not exists."""
    # Week key: year-week
    now = datetime.now()
    week_key = f"{now.year}-W{now.isocalendar()[1]}"

    existing = weekly_col().find_one({"week": week_key}, {"_id": 0})
    if existing:
        return existing

    # Generate: 5 questions per subject, mixed difficulty
    subjects = questions_col().distinct("subject")
    test_questions = []
    for subj in subjects:
        qs = list(questions_col().find({"subject": subj}, {"_id": 0}))
        random.shuffle(qs)
        test_questions.extend(qs[:5])

    random.shuffle(test_questions)
    weekly = {"week": week_key, "title": f"Weekly Test - Week {now.isocalendar()[1]}", "questions": test_questions, "created": now.isoformat()}
    weekly_col().insert_one(weekly)
    weekly.pop("_id", None)
    return weekly


class TestSubmission(BaseModel):
    user_id: str = "default"
    subject: str
    chapter: str
    difficulty: str
    answers: list  # [{question_id, selected_index}]
    time_taken: int = 0

@app.post("/submit-test")
def submit_test(req: TestSubmission):
    """Submit test, calculate score, bookmark wrong answers, update mastery."""
    score = 0
    total = len(req.answers)
    answer_records = []

    for ans in req.answers:
        q = questions_col().find_one({"id": ans["question_id"]}, {"_id": 0})
        if not q:
            continue
        is_correct = ans.get("selected_index") == q["correctIndex"]
        if is_correct:
            score += 1
        answer_records.append({
            "question_id": ans["question_id"],
            "question_text": q["text"],
            "options": q["options"],
            "correct_index": q["correctIndex"],
            "selected_index": ans.get("selected_index"),
            "is_correct": is_correct,
            "explanation": q.get("explanation"),
        })

    # Save result
    result = {
        "user_id": req.user_id,
        "subject": req.subject,
        "chapter": req.chapter,
        "difficulty": req.difficulty,
        "score": score,
        "total": total,
        "percentage": round(score / total * 100, 1) if total > 0 else 0,
        "time_taken": req.time_taken,
        "date": datetime.now().isoformat(),
        "answers": answer_records,
    }
    results_col().insert_one(result)

    # Update mastery counts
    mastery_doc = get_db()["mastery"].find_one({"user_id": req.user_id}) or {"user_id": req.user_id, "counts": {}}
    counts = mastery_doc.get("counts", {})
    for ar in answer_records:
        if ar["is_correct"]:
            counts[ar["question_id"]] = counts.get(ar["question_id"], 0) + 1
    get_db()["mastery"].update_one({"user_id": req.user_id}, {"$set": {"counts": counts}}, upsert=True)

    # Bookmark wrong answers
    for ar in answer_records:
        if not ar["is_correct"]:
            bookmarks_col().update_one(
                {"user_id": req.user_id, "question_id": ar["question_id"]},
                {"$set": {"user_id": req.user_id, "question_id": ar["question_id"], "question_text": ar["question_text"], "options": ar["options"], "correct_index": ar["correct_index"], "subject": req.subject, "chapter": req.chapter, "date": datetime.now().isoformat()}},
                upsert=True
            )
        else:
            # Remove from bookmarks if now correct
            bookmarks_col().delete_one({"user_id": req.user_id, "question_id": ar["question_id"]})

    result.pop("_id", None)
    return {"ok": True, "score": score, "total": total, "percentage": result["percentage"], "answers": answer_records}


@app.get("/results/{user_id}")
def get_results(user_id: str, limit: int = 50):
    """Get test history for a user."""
    results = list(results_col().find({"user_id": user_id}, {"_id": 0}).sort("date", -1).limit(limit))
    return results


@app.get("/stats/{user_id}")
def get_stats(user_id: str):
    """Get performance analytics."""
    results = list(results_col().find({"user_id": user_id}, {"_id": 0}))
    if not results:
        return {"total_tests": 0, "total_points": 0, "avg_score": 0, "streak": 0, "mastered": 0, "by_subject": {}, "by_date": []}

    # By subject
    by_subject = {}
    for r in results:
        subj = r["subject"]
        if subj not in by_subject:
            by_subject[subj] = {"tests": 0, "total_score": 0, "total_possible": 0}
        by_subject[subj]["tests"] += 1
        by_subject[subj]["total_score"] += r["score"]
        by_subject[subj]["total_possible"] += r["total"]

    for subj in by_subject:
        s = by_subject[subj]
        s["avg_percentage"] = round(s["total_score"] / s["total_possible"] * 100, 1) if s["total_possible"] > 0 else 0

    # By date (last 14 days)
    by_date = []
    for i in range(14):
        day = (datetime.now() - timedelta(days=i)).strftime("%Y-%m-%d")
        day_results = [r for r in results if r["date"][:10] == day]
        if day_results:
            avg = sum(r["percentage"] for r in day_results) / len(day_results)
            by_date.append({"date": day, "tests": len(day_results), "avg": round(avg, 1)})

    # Streak
    streak = 0
    for i in range(30):
        day = (datetime.now() - timedelta(days=i)).strftime("%Y-%m-%d")
        if any(r["date"][:10] == day for r in results):
            streak += 1
        elif i > 0:
            break

    # Mastered count
    mastery = get_db()["mastery"].find_one({"user_id": user_id})
    mastered = sum(1 for v in (mastery or {}).get("counts", {}).values() if v >= 3)

    return {
        "total_tests": len(results),
        "total_points": sum(r["score"] for r in results),
        "avg_score": round(sum(r["percentage"] for r in results) / len(results), 1),
        "streak": streak,
        "mastered": mastered,
        "total_questions": questions_col().count_documents({}),
        "by_subject": by_subject,
        "by_date": by_date,
    }


@app.get("/bookmarks/{user_id}")
def get_bookmarks(user_id: str):
    """Get bookmarked (wrong) questions to revisit."""
    return list(bookmarks_col().find({"user_id": user_id}, {"_id": 0}))


@app.delete("/bookmarks/{user_id}/{question_id}")
def remove_bookmark(user_id: str, question_id: str):
    bookmarks_col().delete_one({"user_id": user_id, "question_id": question_id})
    return {"ok": True}
