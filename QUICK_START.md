# JobMatch AI - Quick Start Guide

This guide will walk you through using JobMatch AI's features with practical examples.

## Table of Contents

1. [First Launch](#first-launch)
2. [Semantic Search](#semantic-search)
3. [Resume Upload & Matching](#resume-upload--matching)
4. [Knowledge Graph Exploration](#knowledge-graph-exploration)
5. [API Usage](#api-usage)
6. [Advanced Features](#advanced-features)

---

## First Launch

### Step 1: Verify Installation

After running the installer, verify all services are running:

```bash
# Check service status
docker compose ps

# Should show all services as "Up" and "healthy"
```

### Step 2: Access the Frontend

Open your browser to: **http://localhost:3001**

You should see the JobMatch AI home page with:
- Search bar
- Resume upload button
- Navigation menu

### Step 3: Verify Backend

Visit: **http://localhost:8000/health**

You should see:
```json
{
  "status": "healthy",
  "elasticsearch": "connected",
  "neo4j": "connected"
}
```

---

## Semantic Search

JobMatch AI understands natural language, not just keywords.

### Basic Search

**Try these queries:**

1. **By Technology:**
   ```
   python machine learning engineer
   ```
   - Returns jobs requiring Python and ML skills
   - Understands synonyms (ML = machine learning)

2. **By Role:**
   ```
   senior full stack developer
   ```
   - Finds jobs matching seniority level
   - Includes both frontend and backend roles

3. **By Domain:**
   ```
   data scientist natural language processing
   ```
   - Semantic understanding of domain
   - Matches related skills (NLP, text mining, etc.)

### Advanced Search Queries

**Complex Requirements:**
```
backend engineer with kubernetes and microservices experience
```
- Understands compound requirements
- Finds related technologies (Docker, cloud platforms)

**Location-Based:**
```
remote software engineer blockchain
```
- Filters by work arrangement
- Matches domain expertise

**Experience Level:**
```
entry level frontend developer react
```
- Considers experience requirements
- Matches appropriate roles

### Understanding Results

Each search result shows:
- **Job Title** - The role name
- **Match Score** - Relevance percentage
- **Required Skills** - Key technologies
- **Description** - Job details
- **Explanation** (with API key) - Why this job matches

---

## Resume Upload & Matching

Get personalized job recommendations based on your resume.

### Step 1: Prepare Resume

**Supported formats:**
- PDF (recommended)
- DOCX

**Resume should include:**
- Skills (technical and soft)
- Work experience
- Education
- Projects (optional)

### Step 2: Upload

1. Click **"Upload Resume"** button
2. Select your resume file
3. Wait for processing (10-30 seconds)

### Step 3: View Results

The system will:
1. **Extract Skills** - Identifies your technical abilities
2. **Match Jobs** - Finds relevant opportunities
3. **Explain Matches** - Shows why each job fits
4. **Rank Results** - Orders by relevance

### Example Results

```
Match Score: 95%
Job: Senior Python Developer

Matched Skills:
✓ Python (5 years)
✓ FastAPI (2 years)
✓ PostgreSQL (3 years)
✓ Docker (2 years)

Missing Skills:
- Kubernetes (recommended)
- AWS (nice to have)

Why this matches:
Your extensive Python experience and FastAPI knowledge
align perfectly with this role. Consider learning
Kubernetes to strengthen your DevOps skills.
```

---

## Knowledge Graph Exploration

Explore job and skill relationships visually.

### Access Neo4j Browser

1. Open: **http://localhost:7474**
2. Login:
   - Username: `neo4j`
   - Password: `password`
3. Click **"Connect"**

### Example Queries

#### 1. View All Jobs

```cypher
MATCH (j:Job)
RETURN j
LIMIT 25
```

This shows all job nodes in the graph.

#### 2. Job-Skill Relationships

```cypher
MATCH (j:Job)-[r:REQUIRES]->(s:Skill)
RETURN j, r, s
LIMIT 50
```

Visualizes which jobs require which skills.

#### 3. Find Similar Jobs

```cypher
MATCH (j1:Job {title: "Python Developer"})-[:SIMILAR_TO]-(j2:Job)
RETURN j1, j2
```

Shows jobs similar to "Python Developer".

#### 4. Skill Clusters

```cypher
MATCH (s1:Skill)-[:RELATED_TO]-(s2:Skill)
WHERE s1.name = "Python"
RETURN s1, s2
```

Find skills related to Python.

#### 5. Job by Seniority

```cypher
MATCH (j:Job)
WHERE j.seniority = "Senior"
RETURN j
LIMIT 10
```

Filter jobs by experience level.

#### 6. Most In-Demand Skills

```cypher
MATCH (s:Skill)<-[:REQUIRES]-(j:Job)
RETURN s.name AS skill, COUNT(j) AS demand
ORDER BY demand DESC
LIMIT 10
```

Shows top 10 most requested skills.

### Visualization Tips

- **Click nodes** to see properties
- **Drag nodes** to rearrange
- **Double-click** to expand connections
- **Use mouse wheel** to zoom

---

## API Usage

Interact with the backend API programmatically.

### Interactive Documentation

Visit: **http://localhost:8000/docs**

- Try all endpoints interactively
- See request/response schemas
- Test with sample data

### Common API Calls

#### 1. Search Jobs

```bash
curl "http://localhost:8000/api/v1/search?query=python%20developer&limit=5"
```

Response:
```json
{
  "results": [
    {
      "id": "123",
      "title": "Python Developer",
      "company": "Tech Corp",
      "score": 0.95,
      "skills": ["Python", "Django", "PostgreSQL"]
    }
  ]
}
```

#### 2. Get Job Details

```bash
curl "http://localhost:8000/api/v1/jobs/123"
```

#### 3. Upload Resume

```bash
curl -X POST "http://localhost:8000/api/v1/resume/analyze" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@resume.pdf"
```

Response:
```json
{
  "extracted_skills": ["Python", "FastAPI", "Docker"],
  "experience_years": 5,
  "matched_jobs": [...]
}
```

#### 4. Get Recommendations

```bash
curl -X POST "http://localhost:8000/api/v1/recommend" \
  -H "Content-Type: application/json" \
  -d '{
    "skills": ["Python", "Machine Learning", "TensorFlow"],
    "experience_years": 3
  }'
```

#### 5. Health Check

```bash
curl "http://localhost:8000/api/v1/health"
```

### Python Client Example

```python
import requests

# Search for jobs
response = requests.get(
    "http://localhost:8000/api/v1/search",
    params={"query": "data scientist", "limit": 10}
)
jobs = response.json()

# Upload resume
with open("resume.pdf", "rb") as f:
    response = requests.post(
        "http://localhost:8000/api/v1/resume/analyze",
        files={"file": f}
    )
results = response.json()
```

### JavaScript/TypeScript Example

```javascript
// Search jobs
const searchJobs = async (query) => {
  const response = await fetch(
    `http://localhost:8000/api/v1/search?query=${encodeURIComponent(query)}`
  );
  return await response.json();
};

// Upload resume
const uploadResume = async (file) => {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch(
    'http://localhost:8000/api/v1/resume/analyze',
    {
      method: 'POST',
      body: formData
    }
  );
  return await response.json();
};
```

---

## Advanced Features

### 1. AI-Powered Reranking

**Requires:** `ANTHROPIC_API_KEY` in `.env`

When enabled, the system provides:
- Detailed match explanations
- Intelligent job scoring
- Personalized recommendations

**How to enable:**
1. Get API key from: https://console.anthropic.com/
2. Add to `.env`:
   ```env
   ANTHROPIC_API_KEY=sk-ant-xxx
   ```
3. Restart services:
   ```bash
   docker compose restart
   ```

### 2. Custom Job Data

**Load your own jobs:**

1. Create `jobs.json`:
```json
[
  {
    "title": "Senior Python Engineer",
    "company": "My Company",
    "description": "We're looking for...",
    "skills": ["Python", "FastAPI", "PostgreSQL"],
    "location": "Remote",
    "salary_range": "$120k-$160k"
  }
]
```

2. Copy to container:
```bash
docker cp jobs.json jobmatch_backend:/app/
```

3. Load data:
```bash
docker exec jobmatch_backend python -c "
from app.services.job_loader import load_jobs
load_jobs('/app/jobs.json')
"
```

### 3. Bulk Resume Processing

Process multiple resumes:

```bash
# Create script
cat > process_resumes.sh << 'EOF'
#!/bin/bash
for resume in resumes/*.pdf; do
  echo "Processing: $resume"
  curl -X POST "http://localhost:8000/api/v1/resume/analyze" \
    -F "file=@$resume" \
    -o "results/$(basename $resume .pdf).json"
done
EOF

chmod +x process_resumes.sh
./process_resumes.sh
```

### 4. Export Search Results

```bash
# Search and save results
curl "http://localhost:8000/api/v1/search?query=python%20developer" \
  | jq '.' > search_results.json

# Convert to CSV
cat search_results.json | jq -r '
  .results[] |
  [.id, .title, .company, .score] |
  @csv
' > results.csv
```

### 5. Monitor Performance

```bash
# Backend metrics
curl "http://localhost:8000/metrics"

# Elasticsearch stats
curl "http://localhost:9200/_stats"

# Neo4j stats
docker exec jobmatch_neo4j cypher-shell -u neo4j -p password \
  "CALL dbms.queryJmx('org.neo4j:*')"
```

---

## Usage Scenarios

### Scenario 1: Job Board Integration

Use the API to power a job board:

```javascript
// Search page
const jobs = await searchJobs(userQuery);
displayResults(jobs);

// Job detail page
const job = await getJobById(jobId);
const similarJobs = await getSimilarJobs(jobId);
```

### Scenario 2: Resume Screening

Automatically screen candidate resumes:

```python
for resume_path in resumes:
    results = upload_resume(resume_path)
    if results['match_score'] > 0.8:
        shortlist.append(results)
```

### Scenario 3: Skill Gap Analysis

Identify missing skills for a role:

```python
user_skills = ["Python", "Django"]
job = get_job(job_id)
required_skills = job['skills']
missing = set(required_skills) - set(user_skills)
```

### Scenario 4: Market Research

Analyze job market trends:

```cypher
// Most demanded skills in last month
MATCH (j:Job)-[:REQUIRES]->(s:Skill)
WHERE j.posted_date > date() - duration({months: 1})
RETURN s.name, COUNT(j) as demand
ORDER BY demand DESC
```

---

## Tips & Best Practices

### Search Tips

1. **Use specific terms** - "React developer" better than "developer"
2. **Include experience level** - "junior", "senior", "lead"
3. **Add location if relevant** - "remote", "New York", "hybrid"
4. **Combine skills** - "python fastapi postgresql"

### Resume Tips

1. **List skills clearly** - Use bullet points
2. **Include years of experience** - Helps matching
3. **Use standard job titles** - Improves recognition
4. **Keep format simple** - Avoid complex layouts

### Performance Tips

1. **Limit results** - Use `limit` parameter in searches
2. **Cache responses** - Store frequent queries
3. **Batch uploads** - Process resumes in groups
4. **Use filters** - Narrow search before semantic matching

---

## Troubleshooting

### No Search Results

**Check:**
1. Elasticsearch has data: `curl http://localhost:9200/jobs/_count`
2. Query is not too specific
3. Try broader terms

**Fix:**
```bash
# Reindex data
docker exec jobmatch_backend python -m app.scripts.reindex
```

### Resume Upload Fails

**Common issues:**
1. File too large (>10MB)
2. Corrupt PDF
3. Password-protected PDF

**Test:**
```bash
# Try via API
curl -X POST "http://localhost:8000/api/v1/resume/analyze" \
  -F "file=@test_resume.pdf" \
  -v
```

### Slow Searches

**Optimize:**
1. Reduce result limit
2. Use more specific queries
3. Check system resources

**Monitor:**
```bash
# Check Elasticsearch response time
curl "http://localhost:9200/jobs/_search?q=python" -w "\nTime: %{time_total}s\n"
```

---

## Next Steps

1. **Customize the UI** - Modify frontend in `frontend/src`
2. **Add more data** - Load your job listings
3. **Integrate with existing systems** - Use the API
4. **Explore the graph** - Discover skill relationships
5. **Enable AI features** - Add Anthropic API key

---

**Need more help?** Check the [main README](./README.md) or view the logs:

```bash
docker compose logs -f
```

Happy job matching! 🎯
