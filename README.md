```markdown
# SaaS Coaches Sell Courses

![Next.js](https://img.shields.io/badge/Next.js-13-blue?logo=next.js)
![FastAPI](https://img.shields.io/badge/FastAPI-0.95-green?logo=fastapi)
![License](https://img.shields.io/badge/License-MIT-red)

A SaaS platform enabling coaches to create and sell online courses.

## Features
- Course creation & management
- Payment integration (Stripe/PayPal)
- Student progress tracking
- Responsive Next.js frontend
- FastAPI backend with JWT auth

## Quick Start
```bash
git clone https://github.com/your-repo/saas-coaches-sell-courses.git
cd saas-coaches-sell-courses
npm install
```

## Environment Setup
Create `.env.local` (frontend) and `.env` (backend) with:
```env
# Frontend
NEXT_PUBLIC_API_URL=http://localhost:8000

# Backend
DATABASE_URL=postgresql://user:pass@localhost:5432/db
SECRET_KEY=your-secret-key
```

## Deployment
1. **Frontend**:
```bash
npm run build
npm start
```

2. **Backend**:
```bash
uvicorn main:app --reload
```

## License
MIT © 2023 Your Name
```