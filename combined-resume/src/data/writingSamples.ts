export interface WritingSample {
  title: string;
  category: string;
  description: string;
  href: string;
}

export interface PublishedEssay {
  title: string;
  href: string;
  note?: string;
}

export const writingSamples: WritingSample[] = [
  {
    title: "Jaha Howard for Georgia State Senate, District 6",
    category: "Political Copy",
    description:
      "Three campaign video spots for pediatric dentist and education advocate Dr. Jaha Howard.",
    href: "https://writingsamples.shannonjeffreylove.com/samples/jaha-howard-political-spots",
  },
  {
    title: "NYC COVID-19 Vaccination Promos",
    category: "PSA / Public Health",
    description:
      "Three-spot public service campaign for Birds Eye View Productions targeting NYC vaccination uptake.",
    href: "https://writingsamples.shannonjeffreylove.com/samples/nyc-covid-vaccination-psa",
  },
  {
    title: "Love, Let Live, Or Leave It / Lose It",
    category: "Long-Form Essay",
    description:
      "Signature personal essay on time, value, and the test that determines which relationships deserve our investment.",
    href: "https://writingsamples.shannonjeffreylove.com/samples/one-relationship-test-essay",
  },
  {
    title: "NYPD Commendation Letter",
    category: "Civic Correspondence",
    description:
      "Open letter to the Office of the Commissioner commending Officers Sneed, Chavarria, and Morales.",
    href: "https://writingsamples.shannonjeffreylove.com/samples/nypd-commendation-letter",
  },
  {
    title: "Girls Cruise (VH1) Pickup Episodes",
    category: "TV Treatment",
    description:
      "Pickup-episode treatment and scene breakdown — A/B/C story arcs for Lil' Kim, Mýa, and Chilli.",
    href: "https://writingsamples.shannonjeffreylove.com/samples/girls-cruise-vh1-pickup-treatment",
  },
  {
    title: "Stage Play, Speechwriting & Community Writing",
    category: "Stage & Community",
    description:
      "Original stage play, sermons, ceremonial speeches, civic correspondence, and poetry.",
    href: "https://writingsamples.shannonjeffreylove.com/samples/stage-play-and-community-writing",
  },
];

export const publishedEssays: PublishedEssay[] = [
  {
    title: "Pandemic Proliferation: Private Pretense Meets Public Protests",
    href: "https://medium.com/@shannonjeffreylove",
    note: "Medium",
  },
  {
    title: "Dear Coronavirus & COVID-19",
    href: "https://medium.com/@shannonjeffreylove",
    note: "Medium",
  },
  {
    title: "How The NYPD Saved Christmas From The Grinch Who Almost Stole It",
    href: "https://medium.com/@shannonjeffreylove",
    note: "Medium",
  },
  {
    title: "Inkwell — Stories that shape culture",
    href: "https://blog.shannonjeffreylove.com",
    note: "Essays",
  },
];

export const writingArchiveUrl = "https://writingsamples.shannonjeffreylove.com";
