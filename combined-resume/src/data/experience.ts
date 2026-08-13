export interface ExperienceRole {
  title: string;
  company: string;
  companyUrl?: string;
  period: string;
  location: string;
  bullets: string[];
}

export const experience: ExperienceRole[] = [
  {
    title: "Creative Director",
    company: "Financial Influencer Network (FIN)",
    companyUrl: "https://thefinnetwork.com",
    period: "2024 – Present",
    location: "Remote",
    bullets: [
      "Direct creative strategy across FIN's 4 divisions, activating 30+ vetted financial experts and 10M+ organic reach per launch.",
      "Lead multidisciplinary teams of 15+ designers, copywriters, art directors, and editors.",
      "Compress campaign delivery to 2–4 weeks with full SEC-compliance integrity.",
    ],
  },
  {
    title: "Director of Development",
    company: "Bird's Eye Entertainment, Inc.",
    period: "2016 – Present",
    location: "Brooklyn, NY",
    bullets: [
      "Lead original television, documentary, and branded media development for MTV, Bravo, VH1, and corporate clients.",
      "Created Houston's: Unhindered — docu-series on Gary Michael Houston carrying the Whitney Houston family legacy.",
      "Manage $100K–$500K budgets; secured 3 pilot orders across 12+ TV/digital projects in 18 months.",
    ],
  },
  {
    title: "Assistant Director — Live Broadcast",
    company: "Christian Cultural Center",
    companyUrl: "https://www.cccinfo.org/",
    period: "2023 – Present",
    location: "Brooklyn, NY",
    bullets: [
      "Direct technical operations for 100+ weekly live broadcasts reaching 10,000+ viewers at 99%+ uptime.",
      "Engineer pro audio (Yamaha CL5/QL5, Shure ULX-D); cut troubleshooting incidents by 35%.",
      "Coordinate camera coverage, graphics, playback, and segment timing within 30-second accuracy.",
    ],
  },
  {
    title: "Story Producer — Girls Cruise",
    company: "Big Fish Entertainment / VH1",
    companyUrl: "https://www.vh1.com/shows/girls-cruise",
    period: "2019 – 2022",
    location: "New York, NY",
    bullets: [
      "Built multi-arc storylines for award-winning series starring Lil' Kim, Mýa, and Chilli.",
      "Conducted 200+ on-camera interviews across 11 episodes reaching 700K–1.2M viewers each.",
      "Series won Best Entertainment Show — National Film & TV Awards; featured in Vogue and Glamour.",
    ],
  },
  {
    title: "Producer — MTV True Life",
    company: "Hot Snakes Media / MTV",
    period: "2018 – 2022",
    location: "New York, NY",
    bullets: [
      "Produced True Life: Gun Control across Sandy Hook, Parkland, and Chicago.",
      "Delivered 25+ episodic projects on Avid Media Composer + Frame.io within 9-month broadcast cycles.",
      "Managed production budgets up to $250K end-to-end.",
    ],
  },
  {
    title: "Content Producer",
    company: "Rock The Bells (LL COOL J)",
    companyUrl: "https://rockthebells.com",
    period: "2022",
    location: "New York, NY",
    bullets: [
      "Produced 30+ short-form digital pieces with real-time post pipeline at live festival events.",
      "Built workflow preserving Hip-Hop history while championing next-generation artists.",
    ],
  },
  {
    title: "Segment Producer — One Million Black Women",
    company: "Alongi Media / Goldman Sachs",
    companyUrl: "https://www.goldmansachs.com/our-commitments/sustainability/one-million-black-women",
    period: "2021",
    location: "New York, NY",
    bullets: [
      "Produced B-roll, portrait videography, and location storytelling for $10B social-impact initiative.",
      "Executed under direction of Reginald Hudlin.",
    ],
  },
  {
    title: "Supervising Producer — The Truth with Jeff Johnson",
    company: "BET Networks / Viacom",
    period: "2006 – 2009",
    location: "New York, NY",
    bullets: [
      "Supervised teams of 15+ on BET's flagship news program addressing political and cultural issues.",
      "Directed live and live-to-tape control-room operations; improved efficiency 25%.",
      "Cleared legal, fair-use, and copyright compliance for every broadcast.",
    ],
  },
  {
    title: "Executive Producer · Showrunner — I Married A Baller",
    company: "TV One",
    period: "2005 – 2007",
    location: "Multi-city (OH · TN · GA · CA)",
    bullets: [
      "Created, wrote, produced, and directed TV One's first $1M+ original reality franchise — 9 episodes.",
      "Documented SWV's Taj Johnson-George and NFL Hall of Famer Eddie George across a 3-week charity tour.",
      "Earned Entertainment Weekly coverage (April 20, 2007); anchored TV One's network launch slate.",
    ],
  },
];

export const expertise = [
  "Creative Strategy",
  "Story Architecture",
  "Showrunning",
  "Speechwriting",
  "Live Broadcast",
  "Branded Content",
  "SEC-Compliant Marketing",
  "Post-Production",
  "AI-Forward Workflows",
];

export const awards = [
  {
    title: "Emmy Credit — MTV: True Life",
    detail: "Senior Producer on the Emmy Award–winning True Life franchise.",
  },
  {
    title: "Best Entertainment Show — National Film & TV Awards",
    detail: "Girls Cruise (VH1) as Story Producer; featured in Vogue and Glamour.",
  },
  {
    title: "Entertainment Weekly National Feature",
    detail: "I Married A Baller (TV One), April 20, 2007.",
  },
  {
    title: "Live Broadcast Operations Excellence",
    detail: "Christian Cultural Center — 10,000+ weekly viewers at 99%+ uptime.",
  },
];

export const education = {
  school: "New York University",
  degree: "B.A. Political Science & Africana Studies",
  honors: "Distinguished Honors Graduate",
  year: "2000",
  certification: "Trello for Video Post-Production — LinkedIn Learning, 2018",
};
