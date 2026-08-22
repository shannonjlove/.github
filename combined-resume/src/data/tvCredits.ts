export interface TvCredit {
  project: string;
  network: string;
  role: string;
  proof: string;
  href: string;
  featured?: boolean;
}

/**
 * Authoritative representative work samples — canonical YouTube links from Shannon J. Love.
 * Visuals on site use official thumbnails from these URLs only.
 */
export const tvCredits: TvCredit[] = [
  {
    project: "Shannon J Love Highlight Reel",
    network: "Showcase",
    role: "Executive Producer · Writer · Director",
    proof: "Curated sizzle across 25 years of network and branded work.",
    href: "https://www.youtube.com/watch?v=bWZ3ENgZyhI",
    featured: true,
  },
  {
    project: "The Truth With Jeff Johnson",
    network: "BET",
    role: "Supervising Producer",
    proof: "Flagship news program — culture, politics, community.",
    href: "https://www.youtube.com/watch?v=4FcOwmbnbbE",
  },
  {
    project: "Monica Still Standing",
    network: "BET",
    role: "Assistant Director",
    proof: "8-episode docuseries following Grammy-winning artist Monica.",
    href: "https://www.youtube.com/watch?v=ze4crC3Kgxk",
  },
  {
    project: "Bounce Back Stories — Earl Cox",
    network: "Branded",
    role: "Producer · Editor",
    proof: "Lynnette Khalfani-Cox book launch campaign.",
    href: "https://www.youtube.com/watch?v=oFSsrLH0XAY",
  },
  {
    project: "Power of You Teens Promo",
    network: "Non-Profit",
    role: "Producer",
    proof: "Youth empowerment organization promo.",
    href: "https://www.youtube.com/watch?v=XXTGyWtVUYs",
  },
  {
    project: "Shannon's Highlight Reel",
    network: "Showcase",
    role: "Executive Producer · Writer · Director",
    proof: "Alternate highlight reel cut — network, branded, and documentary work.",
    href: "https://www.youtube.com/watch?v=TiNkR4_L0KM",
  },
  {
    project: "One Million Black Women",
    network: "Goldman Sachs",
    role: "Segment Producer",
    proof: "$10B initiative · Directed by Reginald Hudlin.",
    href: "https://www.youtube.com/watch?v=D_nwXaYF7Oo",
  },
  {
    project: "Girls Cruise Promo",
    network: "VH1",
    role: "Story Producer",
    proof: "Best Entertainment Show — National Film & TV Awards · Vogue, Glamour.",
    href: "https://www.youtube.com/watch?v=icD-4qEpu_E",
  },
  {
    project: "Famous People — Taj",
    network: "TV One",
    role: "Producer",
    proof: "Celebrity profile special featuring Taj Johnson-George (SWV).",
    href: "https://www.youtube.com/watch?v=uXhoqgSjHQU",
  },
  {
    project: "I Married a Baller",
    network: "TV One",
    role: "Creator · Showrunner · EP · Writer · Director",
    proof: "Network's first $1M reality series · Entertainment Weekly featured.",
    href: "https://www.youtube.com/watch?v=IQs4N6SUoSk",
  },
  {
    project: "Hip Hop vs America",
    network: "BET",
    role: "Producer",
    proof: "Cultural debate special examining hip-hop's impact on America.",
    href: "https://www.youtube.com/watch?v=ToON_QY-nGM",
  },
  {
    project: "Million More Movement",
    network: "BET",
    role: "Producer",
    proof: "Documentary covering the Million More Movement.",
    href: "https://www.youtube.com/watch?v=BgFjNj9M7ko",
  },
  {
    project: "The Truth Series",
    network: "BET",
    role: "Supervising Producer",
    proof: "Extended news and current-events programming.",
    href: "https://www.youtube.com/watch?v=0DCogG7PJCY",
  },
  {
    project: "Graphic Open Montage",
    network: "Branded",
    role: "Producer · Editor",
    proof: "Graphic open montage adopted across multiple promotional rollouts.",
    href: "https://www.youtube.com/watch?v=a_TtlGbu6aQ",
  },
];

export const reelArchiveUrl = "https://shannonjlove.tv";
