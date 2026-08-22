export interface SiteLink {
  label: string;
  href: string;
  description: string;
}

export const contact = {
  name: "Shannon J. Love",
  /** Shannon J. Love is male — use he/him in all third-person copy. */
  pronouns: "he/him",
  gender: "male",
  title: "Creative Problem Solver · Executive Producer · Writer · Showrunner",
  location: "Brooklyn, NY",
  email: "sjlove@shannonjeffreylove.com",
  phone: "718-208-3290",
  tagline:
    "Uniquely crafting our experiences into the stories that allow history to aptly depict what it truly meant to be human.",
  summary:
    "25+ years transforming raw human experience into culture-shaping television, film, editorial, and digital media. From TV One's first $1M+ reality franchise and BET's flagship news desk to VH1's award-winning story arcs, Goldman Sachs impact campaigns, and pandemic-era public-health PSAs — I architect stories that ship: pitch to greenlight, control room to broadcast, blank page to published essay.",
  highlightReelId: "bWZ3ENgZyhI",
  highlightReelUrl: "https://www.youtube.com/watch?v=bWZ3ENgZyhI",
  linkedin: "https://www.linkedin.com/in/shannonjlove-wonderfullymade/",
  imdb: "https://www.imdb.com/name/nm1654311/",
  medium: "https://medium.com/@shannonjeffreylove",
};

export const stats = [
  { value: "25+", label: "Years" },
  { value: "$1M+", label: "Budgets Led" },
  { value: "100+", label: "Live Broadcasts" },
  { value: "8", label: "Major Networks" },
];

export const networks = [
  "TV ONE",
  "VH1",
  "BET",
  "MTV",
  "BRAVO",
  "CMT",
  "HGTV",
  "GOLDMAN SACHS",
  "ROCK THE BELLS",
];

export const ecosystemLinks: SiteLink[] = [
  {
    label: "resume.shannonjeffreylove.com",
    href: "https://resume.shannonjeffreylove.com",
    description: "This combined resume",
  },
  {
    label: "shannonj.love",
    href: "https://shannonj.love",
    description: "Full portfolio + ATS exports",
  },
  {
    label: "shannonjlove.tv",
    href: "https://shannonjlove.tv",
    description: "Video reel hub",
  },
  {
    label: "writingsamples.shannonjeffreylove.com",
    href: "https://writingsamples.shannonjeffreylove.com",
    description: "Full writing archive",
  },
  {
    label: "blog.shannonjeffreylove.com",
    href: "https://blog.shannonjeffreylove.com",
    description: "Inkwell essays",
  },
];

export const navItems = [
  { id: "about", label: "About" },
  { id: "tv-work", label: "TV Work" },
  { id: "writing", label: "Writing" },
  { id: "experience", label: "Experience" },
  { id: "contact", label: "Contact" },
];
