# Bolt.new Handoff — Shannon J. Love Combined Resume

> **Purpose:** Paste into [bolt.new](https://bolt.new) to build or refine the combined executive resume site.  
> **Deploy target:** `resume.shannonjeffreylove.com`  
> **Structured data:** [`bolt-handoff.json`](bolt-handoff.json)  
> **Full profile (LLM source):** [`SJL_Professional_Experience_Profile.md`](SJL_Professional_Experience_Profile.md)

---

## Step 1 — Copy this entire prompt into Bolt.new

```
Build a single-page executive resume website for Shannon J. Love using React + Vite + TypeScript + Tailwind CSS.

## CRITICAL RULES (non-negotiable)
1. Shannon J. Love is MALE — display "He/him · Male" in the hero. Use he/him/his in all third-person copy. NEVER use she/her.
2. NO stock photos, AI portraits, or headshot images anywhere on the site.
3. For ALL TV/reel visuals, use ONLY official YouTube thumbnails from linked videos:
   https://img.youtube.com/vi/{VIDEO_ID}/hqdefault.jpg
4. Every TV credit card: thumbnail image → links to its YouTube URL in a new tab.
5. Hero highlight reel: show YouTube thumbnail for video bWZ3ENgZyhI; on click, load YouTube embed with autoplay.

## Design — Dark Editorial Luxury
- Background: #0F172A (charcoal)
- Card background: #1E293B
- Accent gold: #C5A059 → #F1D592 gradient on name headline
- Body text: #E2E8F0 · Muted: #94A3B8
- Fonts: Playfair Display (headlines) + Inter (body) from Google Fonts
- Sticky nav with anchor links: About · TV Work · Writing · Experience · Contact
- Gold hairline section dividers, generous whitespace, mobile-responsive grid
- Print/PDF stylesheet + "Save PDF" button (window.print)

## Page sections (single scrolling page)

### Hero
- Name: Shannon J. Love (large gold gradient serif)
- Subtitle: Creative Problem Solver · Executive Producer · Writer · Showrunner
- Line: He/him · Male
- Meta: Brooklyn, NY · 25 Years · Story-First
- Contact: sjlove@shannonjeffreylove.com · 718-208-3290 · LinkedIn ↗ · IMDb ↗
- Highlight reel: YouTube bWZ3ENgZyhI (thumbnail → click to play embed)

### About (id="about")
- Pull quote: "Uniquely crafting our experiences into the stories that allow history to aptly depict what it truly meant to be human."
- Summary paragraph (25+ years, TV One $1M+ franchise, BET, VH1, Goldman Sachs, FIN)
- Stats strip: 25+ Years · $1M+ Budgets Led · 100+ Live Broadcasts · 8 Major Networks
- Scrolling network marquee: TV ONE · VH1 · BET · MTV · BRAVO · CMT · HGTV · GOLDMAN SACHS · ROCK THE BELLS

### TV & Broadcast Work (id="tv-work")
14 credit cards in this exact order — each with YouTube thumbnail, network badge, role, proof line, "Open on YouTube ↗" link:

1. Shannon J Love Highlight Reel — Showcase — https://www.youtube.com/watch?v=bWZ3ENgZyhI
2. The Truth With Jeff Johnson — BET — https://www.youtube.com/watch?v=4FcOwmbnbbE
3. Monica Still Standing — BET — https://www.youtube.com/watch?v=ze4crC3Kgxk
4. Bounce Back Stories — Earl Cox — Branded — https://www.youtube.com/watch?v=oFSsrLH0XAY
5. Power of You Teens Promo — Non-Profit — https://www.youtube.com/watch?v=XXTGyWtVUYs
6. Shannon's Highlight Reel — Showcase — https://www.youtube.com/watch?v=TiNkR4_L0KM
7. One Million Black Women — Goldman Sachs — https://www.youtube.com/watch?v=D_nwXaYF7Oo
8. Girls Cruise Promo — VH1 — https://www.youtube.com/watch?v=icD-4qEpu_E
9. Famous People — Taj — TV One — https://www.youtube.com/watch?v=uXhoqgSjHQU
10. I Married a Baller — TV One — https://www.youtube.com/watch?v=IQs4N6SUoSk
11. Hip Hop vs America — BET — https://www.youtube.com/watch?v=ToON_QY-nGM
12. Million More Movement — BET — https://www.youtube.com/watch?v=BgFjNj9M7ko
13. The Truth Series — BET — https://www.youtube.com/watch?v=0DCogG7PJCY
14. Graphic Open Montage — Branded — https://www.youtube.com/watch?v=a_TtlGbu6aQ

Footer link: Full Reel Archive — shannonjlove.tv ↗

### The Pen — Writing (id="writing")
6 writing sample cards linking to writingsamples.shannonjeffreylove.com:
- Jaha Howard Political Copy
- NYC COVID-19 Vaccination PSAs
- One Relationship Test essay
- NYPD Commendation Letter
- Girls Cruise VH1 Treatment
- Stage Play & Community Writing

Published essays row: Medium + Inkwell links.
CTA: Browse All Writing Samples ↗

### Experience (id="experience")
Reverse-chronological roles with bullets:
- Creative Director — FIN (2024–Present)
- Director of Development — Bird's Eye Entertainment (2016–Present)
- Assistant Director Live Broadcast — Christian Cultural Center (2023–Present)
- Story Producer — Girls Cruise / VH1 (2019–2022)
- Producer — MTV True Life / Hot Snakes (2018–2022)
- Content Producer — Rock The Bells (2022)
- Segment Producer — Goldman Sachs One Million Black Women (2021)
- Supervising Producer — The Truth with Jeff Johnson / BET (2006–2009)
- Executive Producer · Showrunner — I Married A Baller / TV One (2005–2007)

Expertise chips + Awards + NYU education.

### Contact (id="contact")
- Email, phone, Brooklyn NY, LinkedIn
- Ecosystem links grid: resume.shannonjeffreylove.com · shannonj.love · shannonjlove.tv · writingsamples · Inkwell blog
- Footer: "Words create worlds. Desire to inspire." · © Shannon J. Love

## SEO
Title: Shannon J. Love — Executive Producer, Writer & Creative Problem Solver
Description: 25+ years crafting culture-defining television, film, and digital storytelling. Combined resume with live TV reels and writing samples. Brooklyn, NY. He/him.

## Technical
- Single-page React app, no backend
- External links: target="_blank" rel="noopener noreferrer"
- Lazy-load YouTube thumbnail images
- Accessible alt text on all thumbnails: "{Project title} — video thumbnail"
```

---

## Step 2 — Upload project zip (recommended)

Download **`combined-resume-bolt-handoff.zip`** from this repo (66 KB). It includes:

- Full React + Vite + Tailwind source (`src/`, configs, `index.html`)
- `BOLT_NEW_HANDOFF.md` + `bolt-handoff.json`
- `SJL_Professional_Experience_Profile.md` (master LLM profile)
- Excludes `node_modules/` and `dist/` (run `npm install && npm run dev` after import)

Upload the zip to Bolt.new, then paste the Step 1 prompt to refine or redeploy.

## Step 3 — Attach structured data (optional)

Upload or paste the contents of **`bolt-handoff.json`** into Bolt as reference data. It contains the same content in JSON for programmatic use.

---

## Step 4 — Reference implementation (already built)

If Bolt supports importing an existing repo, point it at:

```
combined-resume/
├── src/
│   ├── components/     Hero, About, TvWork, Writing, ExperienceSection, Footer
│   ├── data/           site.ts, tvCredits.ts, writingSamples.ts, experience.ts
│   └── utils/          youtube.ts (thumbnail + video ID helpers)
├── bolt-handoff.json   ← structured handoff data
└── index.css           ← design tokens
```

**Local preview of reference build:**
```bash
cd combined-resume
npm install
npm run dev
```

---

## Design tokens (CSS)

```css
--color-charcoal: #0f172a;
--color-charcoal-light: #1e293b;
--color-gold: #c5a059;
--color-gold-light: #f1d592;
--font-display: "Playfair Display", Georgia, serif;
--font-body: "Inter", system-ui, sans-serif;
```

---

## YouTube thumbnail helper (implement this)

```typescript
function extractYoutubeVideoId(url: string): string | null {
  const match = url.match(/(?:youtu\.be\/|v=|embed\/)([a-zA-Z0-9_-]{11})/);
  return match?.[1] ?? null;
}

function youtubeThumbnail(url: string): string {
  const id = extractYoutubeVideoId(url);
  return id ? `https://img.youtube.com/vi/${id}/hqdefault.jpg` : "";
}
```

---

## Identity checklist for Bolt output

Before accepting the build, verify:

- [ ] Hero shows **He/him · Male**
- [ ] No portrait/headshot/stock images anywhere
- [ ] All 14 TV cards use real YouTube thumbnails
- [ ] Primary hero reel is `bWZ3ENgZyhI`
- [ ] All writing sample links open writingsamples.shannonjeffreylove.com
- [ ] Mobile nav works; print stylesheet hides nav/embeds
- [ ] Third-person copy uses **he/him** throughout

---

## Related files in this repo

| File | Use |
|---|---|
| `bolt-handoff.json` | Structured JSON for Bolt / APIs |
| `SJL_Professional_Experience_Profile.md` | Full LLM handoff (20 sections, keywords, ATS) |
| `BOLT_NEW_HANDOFF.md` | This document |
| `src/data/*.ts` | Live TypeScript data modules |
| `README.md` | Dev + deploy instructions |

---

## Deploy after Bolt build

1. Export/download project from Bolt.new  
2. `npm run build` → deploy `dist/` to **resume.shannonjeffreylove.com**  
3. Or merge Bolt output back into this repo's `combined-resume/` folder

---

*Prepared for Shannon J. Love · he/him · August 2026*
