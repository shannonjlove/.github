export interface TvCredit {
  project: string;
  network: string;
  role: string;
  proof: string;
  href: string;
  featured?: boolean;
}

export const tvCredits: TvCredit[] = [
  {
    project: "Shannon's Highlight Reel",
    network: "Showcase",
    role: "Executive Producer · Writer · Director",
    proof: "Curated sizzle across 25 years of network and branded work.",
    href: "https://youtu.be/TiNkR4_L0KM",
    featured: true,
  },
  {
    project: "I Married A Baller",
    network: "TV One",
    role: "Creator · Showrunner · EP · Writer · Director",
    proof: "Network's first $1M reality series · Entertainment Weekly featured.",
    href: "https://youtu.be/IQs4N6SUoSk",
  },
  {
    project: "Girls Cruise",
    network: "VH1",
    role: "Story Producer",
    proof: "Best Entertainment Show — National Film & TV Awards · Vogue, Glamour.",
    href: "https://youtu.be/icD-4qEpu_E",
  },
  {
    project: "The Truth with Jeff Johnson",
    network: "BET",
    role: "Supervising Producer",
    proof: "Flagship news program — culture, politics, community.",
    href: "https://youtu.be/4FcOwmbnbbE",
  },
  {
    project: "One Million Black Women",
    network: "Goldman Sachs",
    role: "Segment Producer",
    proof: "$10B initiative · Directed by Reginald Hudlin.",
    href: "https://youtu.be/D_nwXaYF7Oo",
  },
  {
    project: "Hip Hop vs. America",
    network: "BET",
    role: "Producer",
    proof: "Cultural debate special examining hip-hop's impact on America.",
    href: "https://youtu.be/ToON_QY-nGM",
  },
  {
    project: "Million More Movement",
    network: "BET",
    role: "Producer",
    proof: "Documentary covering the Million More Movement.",
    href: "https://youtu.be/BgFjNj9M7ko",
  },
  {
    project: "Monica: Still Standing",
    network: "BET",
    role: "Assistant Director",
    proof: "8-episode docuseries following Grammy-winning artist Monica.",
    href: "https://youtu.be/ze4crC3Kgxk",
  },
  {
    project: "Bounce Back Stories",
    network: "Branded",
    role: "Producer · Editor",
    proof: "Lynnette Khalfani-Cox book launch campaign.",
    href: "https://youtu.be/oFSsrLH0XAY",
  },
  {
    project: "Famous People — Taj (SWV)",
    network: "TV One",
    role: "Producer",
    proof: "Celebrity profile special featuring Taj Johnson-George.",
    href: "https://youtu.be/uXhoqgSjHQU",
  },
  {
    project: "Power of You Teens",
    network: "Non-Profit",
    role: "Producer",
    proof: "Youth empowerment organization promo.",
    href: "https://youtu.be/XXTGyWtVUYs",
  },
  {
    project: "The Truth Series",
    network: "BET",
    role: "Supervising Producer",
    proof: "Extended news and current-events programming.",
    href: "https://youtu.be/0DCogG7PJCY",
  },
];

export const reelArchiveUrl = "https://shannonjlove.tv";
